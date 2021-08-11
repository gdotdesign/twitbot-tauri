module Twitter.Statuses {
  /* Retweets the tweet with the given ID. */
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

  /* Unretweets the tweet with the given ID. */
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

  /* Gets the tweets of a user. */
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
