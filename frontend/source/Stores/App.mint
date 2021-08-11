store App {
  /* The interval to retweet content and follow users. */
  const TICK_INTERVAL = 300000

  /* The interval to unretweet content and unfollow users. */
  const UNDO_INTERVAL = 300000

  /* Wheter or not the app is initialized. */
  state initialized : Bool = false

  /* The full current state of the application. */
  state data : TwitBot.Data =
    {
      retweetCursors = Map.empty(),
      retweetBotEnabled = false,
      retweetedTweets = [],
      retweetSources = [],
      retweetCount = 0,
      retweets = [],
      followCursors = Map.empty(),
      followBotEnabled = false,
      followedUsers = [],
      followSources = [],
      followCount = 0,
      follows = [],
      settings =
        {
          accessTokenSecret = "",
          accessToken = "",
          consumerSecret = "",
          consumerKey = "",
          valid = false
        }
    }

  /* Initializes the store. */
  fun initialize : Promise(Never, Void) {
    if (initialized) {
      next { }
    } else {
      sequence {
        data =
          Twitbot.load()

        next
          {
            initialized = true,
            data = data
          }

        `setInterval(#{tick}, #{TICK_INTERVAL})`
      } catch {
        next { }
      }
    }
  }

  /* The function which runs the tasks. */
  fun tick : Promise(Never, Void) {
    sequence {
      if (data.retweetBotEnabled) {
        sequence {
          update(Twitbot.retweetNext(data))
          update(Twitbot.unRetweetNext(data))
        }
      } else {
        next { }
      }

      if (data.followBotEnabled) {
        sequence {
          update(Twitbot.followNext(data))
          update(Twitbot.unFollowNext(data))
        }
      } else {
        next { }
      }
    }
  }

  /* Updates the data and saves it to disk. */
  fun update (data : Promise(a, TwitBot.Data)) : Promise(Never, Void) {
    sequence {
      newData =
        data

      next { data = newData }
      Twitbot.save(newData)
    } catch {
      next { }
    }
  }
}
