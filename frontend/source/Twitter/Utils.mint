module Twitter.Utils {
  /* Sends an HTTP request using Tauri. */
  fun sendRequest (request : Http.Request) : Promise(String, Http.Response) {
    `
    new Promise(async (resolve, reject) => {
      const headers = {}

      #{request.headers}.map((item) => {
        headers[item.key] = item.value
      })

      try {
        const response =
          await Tauri.http.fetch(#{request.url}, {
            method: #{request.method},
            headers: headers,
            responseType: 2
          })

        resolve(#{fromResponse(`response`)})
      } catch (error) {
        reject(error.message)
      }
    })
    `
  }

  /* Converts the response object ot a response record. */
  fun fromResponse (response : Object) : Http.Response {
    {
      status = `#{response}.status`,
      body = `#{response}.data`
    }
  }

  /* Prepares a request by signing it. */
  fun prepareRequest (
    settings : Settings,
    params : Array(Tuple(String, String)),
    request : Http.Request
  ) : Http.Request {
    try {
      nonce =
        Uid.generate()

      timestamp =
        `Date.parse(new Date()) / 1000 | 0`

      parameters =
        Array.concat(
          [
            [
              {"oauth_consumer_key", settings.consumerKey},
              {"oauth_nonce", nonce},
              {"oauth_signature_method", "HMAC-SHA1"},
              {"oauth_timestamp", timestamp},
              {"oauth_token", settings.accessToken},
              {"oauth_version", "1.0"}
            ],
            params
          ])

      encodedParameters =
        for (item of parameters) {
          {percentEncode(item[0]), percentEncode(item[1])}
        }

      parameterString =
        encodedParameters
        |> Array.sortBy((item : Tuple(String, String)) { item[0] })
        |> Array.map((item : Tuple(String, String)) { "#{item[0]}=#{item[1]}" })
        |> String.join("&")

      signatureBase =
        request.method + "&" + percentEncode(request.url) + "&" + percentEncode(parameterString)

      signingKey =
        percentEncode(settings.consumerSecret) + "&" + percentEncode(settings.accessTokenSecret)

      signature =
        `
        (() => {
          const shaObj = new jsSHA("SHA-1", "TEXT", {
            hmacKey: { value: #{signingKey}, format: "TEXT" },
          });
          shaObj.update(#{signatureBase});
          return shaObj.getHash("B64")
        })()
        `

      header =
        "OAuth oauth_consumer_key=\"#{settings.consumerKey}\", oauth_nonce=\"#{nonce}\", oauth_signature=\"#{percentEncode(signature)}\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"#{timestamp}\", oauth_token=\"#{settings.accessToken}\", oauth_version=\"1.0\""

      queryParams =
        Array.reduce(
          SearchParams.empty(),
          (memo : SearchParams, item : Tuple(String, String)) {
            SearchParams.append(item[0], item[1], memo)
          },
          params)
        |> SearchParams.toString()

      { Http.header("Authorization", header, request) | url = request.url + "?" + queryParams }
    }
  }

  /* Percent encodes the given string according to Twitter docs. */
  fun percentEncode (string : String) : String {
    `
    encodeURIComponent(#{string})
      .replace(/!/g, '%21')
      .replace(/'/g, '%27')
      .replace(/\(/g, '%28')
      .replace(/\)/g, '%29')
      .replace(/\*/g, '%2A')
    `
  }
}
