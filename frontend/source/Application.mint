enum Page {
  FollowBot
  TweetBot
  Settings
  Initial
}

store Application {
  state page : Page = Page::Initial

  const DEFAULT_STATUS =
    {
      settings =
        {
          accessTokenSecret = "SOMETHING WENT WRONG",
          accessToken = "",
          consumerSecret = "",
          consumerKey = "",
          valid = false
        },
      followAgent =
        {
          running = false,
          stat = 0
        },
      tweetAgent =
        {
          running = false,
          stat = 0
        },
      tweetSources = [],
      userSources = [],
      tweets = [],
      users = []
    }

  state settings =
    {
      accessTokenSecret = "SOMETHING WENT WRONG",
      accessToken = "",
      consumerSecret = "",
      consumerKey = "",
      valid = false
    }

  fun saveSettings (newSettings : Settings) : Promise(Never, Void) {
    sequence {
      sequence {
        response =
          Twitter.User.verifyCredentials(newSettings)

        next { settings = { newSettings | valid = true } }
      } catch String => error {
        next { settings = { newSettings | valid = false } }
      }

      path =
        Tauri.Path.resolvePath("twitbot/config.json")

      json =
        (encode settings)
        |> Json.stringify()

      Tauri.Fs.writeFile(path, json)
    }
  }

  fun loadSettings : Promise(Never, Void) {
    sequence {
      path =
        Tauri.Path.resolvePath("twitbot/config.json")

      json =
        Tauri.Fs.readTextFile(path)

      object =
        Json.parse(json)
        |> Maybe.toResult("")

      settings =
        decode object as Settings

      next
        {
          settings = settings,
          status = DEFAULT_STATUS
        }
    } catch {
      next
        {
          status = DEFAULT_STATUS,
          settings =
            {
              accessTokenSecret = "SOMETHING WENT WRONG",
              accessToken = "",
              consumerSecret = "",
              consumerKey = "",
              valid = false
            }
        }
    }
  }

  state status : State = DEFAULT_STATUS

  get valid : Bool {
    settings.valid
  }

  fun setPage (page : Page) {
    next { page = page }
  }

  fun openLink (url : String) {
    if (@SERVER == "YES") {
      Window.open(url)
    } else {
      send("OPEN_LINK", Maybe::Just(encode { url = url }))
    }
  }

  fun send (action : String, payload : Maybe(Object)) {
    try {
      encoded =
        encode {
          payload = payload,
          action = action
        }

      if (@SERVER == "YES") {
        sequence {
          response =
            Http.post("/action")
            |> Http.jsonBody(encoded)
            |> Http.send()

          object =
            Json.parse(response.body)
            |> Maybe.toResult("")

          status =
            decode object as State

          next { status = status }
        } catch {
          next { status = DEFAULT_STATUS }
        }
      } else {
        sequence {
          object =
            `window.bridge(#{encoded})`

          status =
            decode object as State

          next { status = status }
        } catch {
          next { status = DEFAULT_STATUS }
        }
      }
    }
  }
}
