store Application {
  state page : Page = Page::Initial

  state settings =
    {
      accessTokenSecret = "",
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

      next { settings = settings }
    } catch {
      next
        {
          settings =
            {
              accessTokenSecret = "",
              accessToken = "",
              consumerSecret = "",
              consumerKey = "",
              valid = false
            }
        }
    }
  }

  get valid : Bool {
    settings.valid
  }

  fun setPage (page : Page) {
    next { page = page }
  }

  fun openLink (url : String) {
    Window.open(url)
  }
}
