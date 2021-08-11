module Twitbot {
  /* Follows the next followable user. */
  fun followNext (data : TwitBot.Data) {
    case (data.follows[0]) {
      Maybe::Just(item) =>
        try {
          updatedFollows =
            Array.delete(item, data.follows)

          sequence {
            Twitter.User.friendshipsCreate(
              data.settings,
              [
                {"screen_name", item.screenName}
              ])

            Ui.Notifications.notifyDefault(<{ "Followed User: @#{item.screenName}" }>)

            Promise.resolve(
              { data |
                followCount = data.followCount + 1,
                follows = updatedFollows,
                followedUsers =
                  Array.push(
                    {
                      time = Time.now(),
                      user = item
                    },
                    data.followedUsers)
              })
          } catch String => error {
            try {
              Debug.log(error)
              Promise.resolve({ data | follows = updatedFollows })
            }
          }
        }

      Maybe::Nothing =>
        sequence {
          Ui.Notifications.notifyDefault(<{ "Getting new users to follow." }>)
          getNewFollows(0, data)
        } catch String => error {
          try {
            Debug.log(error)
            Promise.resolve(data)
          }
        }
    }
  }

  /* Unfollows the next followed user. */
  fun unFollowNext (data : TwitBot.Data) {
    try {
      tweet =
        data.followedUsers
        |> Array.select((item : UserStatus) { `#{Time.now()} - #{item.time} > #{App:UNDO_INTERVAL}` })
        |> Array.first

      case (tweet) {
        Maybe::Just(item) =>
          try {
            updatedData =
              { data | followedUsers = Array.delete(item, data.followedUsers) }

            sequence {
              Twitter.User.friendshipsDestroy(
                data.settings,
                [
                  {"screen_name", item.user.screenName}
                ])

              Ui.Notifications.notifyDefault(<{ "Unfollowed User: @#{item.user.screenName}" }>)

              Promise.resolve(updatedData)
            } catch String => error {
              try {
                Debug.log(error)
                Promise.resolve(updatedData)
              }
            }
          }

        Maybe::Nothing => Promise.resolve(data)
      }
    }
  }

  /* Retweets the next tweet. */
  fun retweetNext (data : TwitBot.Data) {
    case (data.retweets[0]) {
      Maybe::Just(item) =>
        try {
          updatedRetweets =
            Array.delete(item, data.retweets)

          sequence {
            Twitter.Statuses.retweet(item.id, data.settings, [])
            Ui.Notifications.notifyDefault(<{ "Retweeted tweet:\n#{item.text}" }>)

            Promise.resolve(
              { data |
                retweetCount = data.retweetCount + 1,
                retweets = updatedRetweets,
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
              Promise.resolve({ data | retweets = updatedRetweets })
            }
          }
        }

      Maybe::Nothing =>
        sequence {
          Ui.Notifications.notifyDefault(<{ "Getting new tweets to retweet." }>)
          getNewTweets(0, data)
        } catch {
          Promise.resolve(data)
        }
    }
  }

  /* Unretweets the next retweeted tweet. */
  fun unRetweetNext (data : TwitBot.Data) {
    try {
      tweet =
        data.retweetedTweets
        |> Array.select((item : TweetStatus) { `#{Time.now()} - #{item.time} > #{App:UNDO_INTERVAL}` })
        |> Array.first

      case (tweet) {
        Maybe::Just(item) =>
          try {
            updatedData =
              { data | retweetedTweets = Array.delete(item, data.retweetedTweets) }

            sequence {
              Twitter.Statuses.unretweet(item.tweet.id, data.settings, [])
              Ui.Notifications.notifyDefault(<{ "Unretweeted tweet: #{item.tweet.text}" }>)

              Promise.resolve(updatedData)
            } catch String => error {
              try {
                Debug.log(error)
                Promise.resolve(updatedData)
              }
            }
          }

        Maybe::Nothing => Promise.resolve(data)
      }
    }
  }

  /* Deletes a tweet. */
  fun deleteTweet (id : String, data : TwitBot.Data) {
    sequence {
      { data | retweets = Array.reject((tweet : Tweet) { tweet.id == id }, data.retweets) }
    }
  }

  /* Deletes a follow. */
  fun deleteFollow (id : String, data : TwitBot.Data) {
    sequence {
      { data | follows = Array.reject((user : User) { user.id == id }, data.follows) }
    }
  }

  /* Updates the settings. */
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

  /* Deletes a tweet source. */
  fun deleteTweetSource (screenName : String, data : TwitBot.Data) {
    Promise.resolve({ data | retweetSources = Array.delete(screenName, data.retweetSources) })
  }

  /* Adds a tweet source. */
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

  /* Get new tweets for a given user at the given index. */
  fun getNewTweets (index : Number, data : TwitBot.Data) {
    case (data.retweetSources[index]) {
      Maybe::Just(source) =>
        sequence {
          newData =
            getTweetsOfUser(source, data)

          getNewTweets(index + 1, newData)
        }

      Maybe::Nothing => Promise.resolve(data)
    }
  }

  /* Gets the tweets of a user by screen name. */
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
        retweetCursors = Map.set(screenName, newCursors, data.retweetCursors),
        retweets = Array.concat([data.retweets, headTweets, tailTweets])
      }
    }
  }

  /* Deletes a follow source. */
  fun deleteFollowSource (screenName : String, data : TwitBot.Data) {
    Promise.resolve({ data | followSources = Array.delete(screenName, data.followSources) })
  }

  /* Adds a follow source. */
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

  /* Get new follows for a given user at the given index. */
  fun getNewFollows (index : Number, data : TwitBot.Data) {
    case (data.followSources[index]) {
      Maybe::Just(source) =>
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

  /* Get the new followers of a user. */
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
          followCursors = Map.set(screenName, newCursor, data.followCursors),
          follows = Array.concat([data.follows, response.users])
        })
    } catch String => error {
      try {
        Debug.log(error)
        Promise.reject("")
      }
    }
  }

  /* Saves the data to disk. */
  fun save (data : TwitBot.Data) : Promise(Never, Void) {
    sequence {
      path =
        Tauri.Path.resolvePath("twitbot/database.json")

      json =
        Json.stringify(encode data)

      Tauri.Fs.writeFile(path, json)
    }
  }

  /* Loads the data from the disk. */
  fun load : Promise(String, TwitBot.Data) {
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
      Promise.reject("Could not load database!")
    }
  }
}
