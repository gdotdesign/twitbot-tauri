routes {
  /settings {
    sequence {
      App.initialize()
      Application.loadSettings()
      Application.setPage(Page::Settings)
    }
  }

  /follow-bot {
    sequence {
      App.initialize()
      Application.loadSettings()
      Application.setPage(Page::FollowBot)
    }
  }

  /retweet-bot {
    sequence {
      App.initialize()
      Application.loadSettings()
      Application.setPage(Page::TweetBot)
    }
  }

  * {
    sequence {
      App.initialize()
      Application.loadSettings()
      Application.setPage(Page::TweetBot)
    }
  }
}
