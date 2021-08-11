/* Represents an agent / bot. */
record Agent {
  running : Bool,
  stat : Number
}

/* Represents a user. */
record User {
  profileImage : String using "profile_image_url_https",
  followersCount : Number using "followers_count",
  screenName : String using "screen_name",
  id : String using "id_str",
  description : String,
  verified : Bool,
  name : String
}

/* Represents a tweet. */
record Tweet {
  id : String using "id_str",
  text : String,
  user : User
}

/* Represents the settings. */
record Settings {
  accessTokenSecret : String,
  accessToken : String,
  consumerSecret : String,
  consumerKey : String,
  valid : Bool
}

/* Represents a cursor. */
record Cursor {
  head : String,
  tail : String
}

/* Represents the status of a tweet. */
record TweetStatus {
  tweet : Tweet,
  time : Time
}

/* Represents the status of a follow. */
record UserStatus {
  time : Time,
  user : User
}

/* Represents the state of the application. */
record TwitBot.Data {
  retweetedTweets : Array(TweetStatus),
  retweetCursors : Map(String, Cursor),
  retweetSources : Array(String),
  retweetBotEnabled : Bool,
  retweets : Array(Tweet),
  retweetCount : Number,
  followCursors : Map(String, String),
  followedUsers : Array(UserStatus),
  followSources : Array(String),
  followBotEnabled : Bool,
  followCount : Number,
  follows : Array(User),
  settings : Settings
}

/* Represents the pages of the application. */
enum Page {
  FollowBot
  TweetBot
  Settings
  Initial
}
