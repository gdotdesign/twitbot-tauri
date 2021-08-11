global component Overlay {
  connect Application exposing { page }
  connect Ui exposing { mobile }
  connect App exposing { data }

  /* Styles for the base element. */
  style base {
    background: rgba(0,0,0,0.75);
    position: fixed;
    z-index: 100;
    bottom: 0;
    right: 0;
    left: 0;
    top: 0;

    place-content: center;
    display: grid;

    > * > * {
      padding: 0 100px;

      if (mobile) {
        padding: 0;
      }
    }
  }

  /* Renders the component. */
  fun render {
    if (data.settings.valid || page == Page::Settings) {
      <></>
    } else {
      <div::base>
        <Ui.Box>
          <Ui.IllustratedMessage
            subtitle=<{ "You can configure TwitBot on to the settings page." }>
            title=<{ "Twitbot is not configured!" }>
            image={
              <Ui.Image
                src={@asset(../../assets/images/robot-hi.png)}
                height={Ui.Size::Em(25)}
                width={Ui.Size::Em(25)}
                transparent={true}/>
            }
            actions={
              <Ui.Button
                iconBefore={@svg(../../assets/icons/settings.svg)}
                label="Go to Settings"
                href="/settings"/>
            }/>
        </Ui.Box>
      </div>
    }
  }
}
