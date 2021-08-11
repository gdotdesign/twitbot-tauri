module Twitter.User {
  /* Verifies the given twitter credentials. */
  fun verifyCredentials (settings : Settings) : Promise(String, Http.Response) {
    "https://api.twitter.com/1.1/account/verify_credentials.json"
    |> Http.get
    |> Twitter.Utils.prepareRequest(settings, [])
    |> Twitter.Utils.sendRequest
  }

  /* Follows a user. */
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

  /* Unfollows a user. */
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

  /* Gets the list of followers of a user. */
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
        decode object as Twitter.FollowersListResponse

      Promise.resolve(decoded)
    } catch String => error {
      Promise.reject(error)
    } catch Object.Error => error {
      Promise.reject("Could not decode JSON.")
    }
  }
}
