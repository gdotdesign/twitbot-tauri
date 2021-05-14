record FollowersList.Response {
  nextCursor : String using "next_cursor_str",
  users : Array(User)
}

module Twitter.User {
  fun verifyCredentials (settings : Settings) : Promise(String, Http.Response) {
    "https://api.twitter.com/1.1/account/verify_credentials.json"
    |> Http.get
    |> Twitter.Utils.prepareRequest(settings, [])
    |> Twitter.Utils.sendRequest
  }

  fun friendshipsCreate (
    settings : Settings,
    parameters : Array(Tuple(String, String))
  ) : Promise(String, Void) {
    sequence {
      response =
        "https://api.twitter.com/1.1/friendships/create.json"
        |> Http.post
        |> Twitter.Utils.prepareRequest(settings, parameters)
        |> Twitter.Utils.sendRequest

      Promise.resolve(void)
    } catch String => error {
      Promise.reject(error)
    }
  }

  fun friendshipsDestroy (
    settings : Settings,
    parameters : Array(Tuple(String, String))
  ) : Promise(String, Void) {
    sequence {
      response =
        "https://api.twitter.com/1.1/friendships/destroy.json"
        |> Http.post
        |> Twitter.Utils.prepareRequest(settings, parameters)
        |> Twitter.Utils.sendRequest

      Promise.resolve(void)
    } catch String => error {
      Promise.reject(error)
    }
  }

  fun followersList (
    settings : Settings,
    parameters : Array(Tuple(String, String))
  ) {
    sequence {
      response =
        "https://api.twitter.com/1.1/followers/list.json"
        |> Http.get
        |> Twitter.Utils.prepareRequest(settings, parameters)
        |> Twitter.Utils.sendRequest

      object =
        Json.parse(response.body)
        |> Maybe.toResult("Could not parse JSON!")

      decoded =
        decode object as FollowersList.Response

      Promise.resolve(decoded)
    } catch String => error {
      Promise.reject(error)
    } catch Object.Error => error {
      Promise.reject("Could not decode JSON.")
    }
  }
}

module Twitter.Statuses {
  fun retweet (
    id : String,
    settings : Settings,
    parameters : Array(Tuple(String, String))
  ) : Promise(String, Void) {
    sequence {
      response =
        "https://api.twitter.com/1.1/statuses/retweet/#{id}.json"
        |> Http.post
        |> Twitter.Utils.prepareRequest(settings, parameters)
        |> Twitter.Utils.sendRequest

      Promise.resolve(void)
    } catch String => error {
      Promise.reject(error)
    }
  }

  fun unretweet (
    id : String,
    settings : Settings,
    parameters : Array(Tuple(String, String))
  ) : Promise(String, Void) {
    sequence {
      response =
        "https://api.twitter.com/1.1/statuses/unretweet/#{id}.json"
        |> Http.post
        |> Twitter.Utils.prepareRequest(settings, parameters)
        |> Twitter.Utils.sendRequest

      Promise.resolve(void)
    } catch String => error {
      Promise.reject(error)
    }
  }

  fun userTimeline (
    settings : Settings,
    parameters : Array(Tuple(String, String))
  ) : Promise(String, Array(Tweet)) {
    sequence {
      response =
        "https://api.twitter.com/1.1/statuses/user_timeline.json"
        |> Http.get
        |> Twitter.Utils.prepareRequest(settings, parameters)
        |> Twitter.Utils.sendRequest

      object =
        Json.parse(response.body)
        |> Maybe.toResult("Could not parse JSON!")

      decoded =
        decode object as Array(Tweet)

      Promise.resolve(decoded)
    } catch String => error {
      Promise.reject(error)
    } catch Object.Error => error {
      Promise.reject("Could not decode JSON.")
    }
  }
}

module Twitter.Utils {
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
        reject(error.toString())
      }
    })
    `
  }

  fun fromResponse (response : Object) : Http.Response {
    {
      status = `#{response}.status`,
      body = `#{response}.data`
    }
  }

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
        ]
        |> Array.concat

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
