record Agent {
  running : Bool,
  stat : Number
}

record User {
  profileImage : String using "profile_image_url_https",
  followersCount : Number using "followers_count",
  screenName : String using "screen_name",
  id : String using "id_str",
  description : String,
  verified : Bool,
  name : String
}

record Tweet {
  id : String using "id_str",
  text : String,
  user : User
}

record Settings {
  accessTokenSecret : String,
  accessToken : String,
  consumerSecret : String,
  consumerKey : String,
  valid : Bool
}

record State {
  tweetSources : Array(String),
  userSources : Array(String),
  tweets : Array(Tweet),
  users : Array(User),
  settings : Settings,
  followAgent : Agent,
  tweetAgent : Agent
}

record Cursor {
  head : String,
  tail : String
}

record TweetStatus {
  time : Time,
  tweet : Tweet
}

record UserStatus {
  time : Time,
  user : User
}

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
