store App {
  const TICK_INTERVAL = 300000
  const UNDO_INTERVAL = 300000

  state initialized = false

  state data =
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

  fun initialize {
    if (initialized) {
      next {  }
    } else {
      sequence {
        data =
          Twitbot.load()

        next
          {
            data = data,
            initialized = true
          }

        `setInterval(#{tick}, #{TICK_INTERVAL})`
      } catch {
        next {  }
      }
    }
  }

  fun tick {
    sequence {
      if (data.retweetBotEnabled) {
        sequence {
          update(Twitbot.retweetNext(data))
          update(Twitbot.unRetweetNext(data))
        }
      } else {
        next {  }
      }

      if (data.followBotEnabled) {
        sequence {
          update(Twitbot.followNext(data))
          update(Twitbot.unFollowNext(data))
        }
      } else {
        next {  }
      }
    }
  }

  fun update (data : Promise(a, TwitBot.Data)) {
    sequence {
      newData =
        data

      next { data = newData }
      Twitbot.save(newData)
    } catch {
      next {  }
    }
  }
}

module Twitbot {
  fun followNext (data : TwitBot.Data) {
    try {
      user =
        data.follows[0]

      case (user) {
        Maybe::Just item =>
          sequence {
            Twitter.User.friendshipsCreate(data.settings, [{"screen_name", item.screenName}])
            Tauri.Notification.sendNotification("Twitbot", "Followed User: @#{item.screenName}", "")

            Promise.resolve(
              { data |
                follows = Array.delete(item, data.follows),
                followCount = data.followCount + 1,
                followedUsers =
                  Array.push(
                    {
                      time = Time.now(),
                      user = item
                    },
                    data.followedUsers)
              })
          } catch {
            Promise.resolve(data)
          }

        Maybe::Nothing =>
          sequence {
            Tauri.Notification.sendNotification("Twitbot", "Getting new users to follow.", "")
            getNewFollows(0, data)
          } catch String => error {
            try {
              Debug.log(error)
              Promise.resolve(data)
            }
          }
      }
    }
  }

  fun unFollowNext (data : TwitBot.Data) {
    try {
      tweet =
        data.followedUsers
        |> Array.select((item : UserStatus) { `#{Time.now()} - #{item.time} > #{App:UNDO_INTERVAL}` })
        |> Array.first

      case (tweet) {
        Maybe::Just item =>
          sequence {
            Twitter.User.friendshipsDestroy(data.settings, [{"screen_name", item.user.screenName}])
            Tauri.Notification.sendNotification("Twitbot", "Unfollowed User: @#{item.user.screenName}", "")

            Promise.resolve(
              { data | followedUsers = Array.delete(item, data.followedUsers) })
          } catch String => error {
            try {
              Debug.log(error)
              Promise.resolve(data)
            }
          }

        Maybe::Nothing => Promise.resolve(data)
      }
    }
  }

  fun retweetNext (data : TwitBot.Data) {
    try {
      tweet =
        data.retweets[0]

      case (tweet) {
        Maybe::Just item =>
          sequence {
            Twitter.Statuses.retweet(item.id, data.settings, [])
            Tauri.Notification.sendNotification("Twitbot", "Retweeted tweet:\n#{item.text}", "")

            Promise.resolve(
              { data |
                retweets = Array.delete(item, data.retweets),
                retweetCount = data.retweetCount + 1,
                retweetedTweets =
                  Array.push(
                    {
                      time = Time.now(),
                      tweet = item
                    },
                    data.retweetedTweets)
              })
          } catch String => error {
            try {
              Debug.log(error)
              Promise.resolve(data)
            }
          }

        Maybe::Nothing =>
          sequence {
            Tauri.Notification.sendNotification("Twitbot", "Getting new tweets to retweet.", "")
            getNewTweets(0, data)
          } catch {
            Promise.resolve(data)
          }
      }
    }
  }

  fun unRetweetNext (data : TwitBot.Data) {
    try {
      tweet =
        data.retweetedTweets
        |> Array.select((item : TweetStatus) { `#{Time.now()} - #{item.time} > #{App:UNDO_INTERVAL}` })
        |> Array.first

      case (tweet) {
        Maybe::Just item =>
          sequence {
            Twitter.Statuses.unretweet(item.tweet.id, data.settings, [])
            Tauri.Notification.sendNotification("Twitbot", "Unretweeted tweet: #{item.tweet.text}", "")

            Promise.resolve(
              { data | retweetedTweets = Array.delete(item, data.retweetedTweets) })
          } catch String => error {
            try {
              Debug.log(error)
              Promise.resolve(data)
            }
          }

        Maybe::Nothing => Promise.resolve(data)
      }
    }
  }

  fun deleteTweet (id : String, data : TwitBot.Data) {
    sequence {
      { data | retweets = Array.reject((tweet : Tweet) { tweet.id == id }, data.retweets) }
    }
  }

  fun updateSettings (newSettings : Settings, data : TwitBot.Data) {
    sequence {
      settings =
        data.settings

      sequence {
        response =
          Twitter.User.verifyCredentials(newSettings)

        { data | settings = { newSettings | valid = true } }
      } catch String => error {
        { data | settings = { newSettings | valid = false } }
      }
    }
  }

  fun deleteTweetSource (screenName : String, data : TwitBot.Data) {
    Promise.resolve({ data | retweetSources = Array.delete(screenName, data.retweetSources) })
  }

  fun addTweetSource (screenName : String, data : TwitBot.Data) {
    if (Array.contains(screenName, data.retweetSources)) {
      Promise.resolve(data)
    } else {
      sequence {
        newData =
          { data | retweetSources = Array.push(screenName, data.retweetSources) }

        getTweetsOfUser(screenName, newData)
      }
    }
  }

  fun getNewTweets (index : Number, data : TwitBot.Data) {
    case (data.retweetSources[index]) {
      Maybe::Just source =>
        sequence {
          newData =
            getTweetsOfUser(source, data)

          getNewTweets(index + 1, newData)
        }

      Maybe::Nothing => Promise.resolve(data)
    }
  }

  fun getNewFollows (index : Number, data : TwitBot.Data) {
    case (data.followSources[index]) {
      Maybe::Just source =>
        sequence {
          newData =
            getFollowersOfUser(source, data)

          getNewFollows(index + 1, newData)
        } catch {
          Promise.resolve(data)
        }

      Maybe::Nothing => Promise.resolve(data)
    }
  }

  fun getTweetsOfUser (screenName : String, data : TwitBot.Data) {
    sequence {
      cursors =
        Map.getWithDefault(
          screenName,
          {
            head = "",
            tail = ""
          },
          data.retweetCursors)

      tweets =
        parallel {
          headTweets =
            if (String.isBlank(cursors.head)) {
              Twitter.Statuses.userTimeline(
                data.settings,
                [
                  {"screen_name", screenName},
                  {"count", "2"}
                ])
            } else {
              Twitter.Statuses.userTimeline(
                data.settings,
                [
                  {"screen_name", screenName},
                  {"since_id", cursors.head},
                  {"count", "2"}
                ])
            }

          tailTweets =
            if (String.isBlank(cursors.tail)) {
              Promise.resolve([])
            } else {
              try {
                parsedId =
                  `BigInt(#{cursors.tail})`

                maxId =
                  (parsedId - `BigInt(1)`)
                  |> Number.toString()

                Twitter.Statuses.userTimeline(
                  data.settings,
                  [
                    {"screen_name", screenName},
                    {"max_id", maxId},
                    {"count", "2"}
                  ])
              }
            }
        } then {
          {headTweets, tailTweets}
        } catch {
          {[], []}
        }

      {headTweets, tailTweets} =
        tweets

      newCursors =
        if (String.isNotBlank(cursors.head) && String.isNotBlank(cursors.tail)) {
          try {
            headCursor =
              headTweets
              |> Array.first()
              |> Maybe.map(.id)
              |> Maybe.withDefault(cursors.head)

            tailCursor =
              tailTweets
              |> Array.last()
              |> Maybe.map(.id)
              |> Maybe.withDefault(cursors.tail)

            {
              head = headCursor,
              tail = tailCursor
            }
          }
        } else {
          try {
            headCursor =
              headTweets
              |> Array.first()
              |> Maybe.map(.id)
              |> Maybe.withDefault("")

            tailCursor =
              headTweets
              |> Array.last()
              |> Maybe.map(.id)
              |> Maybe.withDefault("")

            {
              head = headCursor,
              tail = tailCursor
            }
          }
        }

      { data |
        retweets = Array.concat([data.retweets, headTweets, tailTweets]),
        retweetCursors = Map.set(screenName, newCursors, data.retweetCursors)
      }
    }
  }

  fun deleteFollowSource (screenName : String, data : TwitBot.Data) {
    Promise.resolve({ data | followSources = Array.delete(screenName, data.followSources) })
  }

  fun addFollowSource (screenName : String, data : TwitBot.Data) {
    if (Array.contains(screenName, data.followSources)) {
      Promise.resolve(data)
    } else {
      sequence {
        newData =
          { data | followSources = Array.push(screenName, data.followSources) }

        getFollowersOfUser(screenName, newData)
      } catch {
        Promise.resolve(data)
      }
    }
  }

  fun getFollowersOfUser (screenName : String, data : TwitBot.Data) {
    sequence {
      cursor =
        Map.getWithDefault(
          screenName,
          "",
          data.followCursors)

      response =
        if (String.isBlank(cursor)) {
          Twitter.User.followersList(
            data.settings,
            [
              {"screen_name", screenName}
            ])
        } else {
          Twitter.User.followersList(
            data.settings,
            [
              {"screen_name", screenName},
              {"cursor", cursor}
            ])
        }

      newCursor =
        response.nextCursor

      Promise.resolve(
        { data |
          follows = Array.concat([data.follows, response.users]),
          followCursors = Map.set(screenName, newCursor, data.followCursors)
        })
    } catch String => error {
      try {
        Debug.log(error)
        Promise.reject("")
      }
    }
  }

  fun save (data : TwitBot.Data) {
    sequence {
      path =
        Tauri.Path.resolvePath("twitbot/database.json")

      json =
        Json.stringify(encode data)

      Tauri.Fs.writeFile(path, json)
    }
  }

  fun load {
    sequence {
      path =
        Tauri.Path.resolvePath("twitbot/database.json")

      json =
        Tauri.Fs.readTextFile(path)

      object =
        Json.parse(json)
        |> Maybe.toResult("")

      data =
        decode object as TwitBot.Data

      Promise.resolve(data)
    } catch {
      Promise.reject("")
    }
  }
}
