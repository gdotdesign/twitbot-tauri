component Main {
  connect Application exposing { page, setPage, openLink }
  connect Ui exposing { mobile, darkMode, toggleDarkMode }

  style base {
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }

  get darkModeToggle : Ui.NavItem {
    if (mobile) {
      try {
        label =
          if (darkMode) {
            "Light Mode"
          } else {
            "Dark Mode"
          }

        iconBefore =
          if (darkMode) {
            Ui.Icons:SUN
          } else {
            Ui.Icons:MOON
          }

        Ui.NavItem::Item(
          action = (event : Html.Event) { toggleDarkMode() },
          iconBefore = iconBefore,
          iconAfter = <></>,
          label = label)
      }
    } else {
      Ui.NavItem::Html(<Ui.DarkModeToggle/>)
    }
  }

  fun render : Html {
    if (page == Page::Initial) {
      <></>
    } else {
      try {
        header =
          <Ui.Header
            items=[
              Ui.NavItem::Link(
                iconBefore = @svg(../assets/icons/users.svg),
                iconAfter = <></>,
                href = "/follow-bot",
                target = "",
                label = "Follow Bot"),
              Ui.NavItem::Link(
                iconBefore = @svg(../assets/icons/comment.svg),
                iconAfter = <></>,
                label = "Retweet Bot",
                href = "/retweet-bot",
                target = ""),
              Ui.NavItem::Link(
                href = "/settings",
                target = "",
                iconBefore = @svg(../assets/icons/settings.svg),
                iconAfter = <></>,
                label = "Settings"),
              Ui.NavItem::Divider,
              Ui.NavItem::Link(
                href = "https://twitbot.netlify.app/",
                target = "_blank",
                iconBefore = @svg(../assets/icons/help.svg),
                iconAfter = <></>,
                label = "Help"),
              Ui.NavItem::Divider,
              darkModeToggle
            ]
            brand={
              <Ui.Brand
                icon={Ui.Icons:RADIO_TOWER}
                name="Twitbot"/>
            }/>

        content =
          case (page) {
            Page::FollowBot => <Pages.FollowBot/>
            Page::Settings => <Pages.Settings/>
            Page::TweetBot => <Pages.Tweets/>
            Page::Initial => <></>
          }

        <Ui.Theme.Root
          fontConfiguration={Ui:DEFAULT_FONT_CONFIGURATION}
          tokens={
            Array.concat(
              [
                Ui:DEFAULT_TOKENS,
                [
                  Ui.Token::Simple(name = "primary-link", value = "rgb(255, 105, 250)"),
                  Ui.Token::Simple(name = "primary-hover", value = "#CC2CB8"),
                  Ui.Token::Simple(name = "primary-color", value = "#f40fd7")
                ]
              ])
          }>

          <div::base>
            <Ui.Layout.Website
              content={content}
              centered={false}
              header={header}/>
          </div>

        </Ui.Theme.Root>
      }
    }
  }
}