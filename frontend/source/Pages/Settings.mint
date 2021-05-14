component Pages.Settings {
  connect Application exposing {openLink}
  connect App exposing { data, update }

  state consumerSecret : Maybe(String) = Maybe::Nothing
  state consumerKey : Maybe(String) = Maybe::Nothing

  state accessTokenSecret : Maybe(String) = Maybe::Nothing
  state accessToken : Maybe(String) = Maybe::Nothing

  style field {
    label {
      margin-bottom: 7px;
      font-weight: 500;
      display: block;
    }
  }

  style fields {
    > * + * {
      margin-top: 20px;
    }
  }

  style status {
    border-radius: 0.375em;
    font-weight: bold;
    padding: 1em;
    color: white;

    justify-content: start;
    grid-auto-flow: column;
    align-items: center;
    grid-gap: 10px;
    display: grid;

    if (data.settings.valid) {
      background: var(--success-color);
      color: var(--success-text);
    } else {
      background: var(--danger-color);
      color: var(--danger-text);
    }
  }

  fun save (event : Html.Event) {
    data
    |> Twitbot.updateSettings({
      consumerSecret = Maybe.withDefault(data.settings.consumerSecret, consumerSecret),
      consumerKey = Maybe.withDefault(data.settings.consumerKey, consumerKey),
      accessTokenSecret = Maybe.withDefault(data.settings.accessTokenSecret, accessTokenSecret),
      accessToken = Maybe.withDefault(data.settings.accessToken, accessToken),
      valid = false
    })
    |> update
  }

  fun setConsumerKey (value : String) {
    next { consumerKey = Maybe::Just(value) }
  }

  fun setConsumerSecret (value : String) {
    next { consumerSecret = Maybe::Just(value) }
  }

  fun setAccessTokenSecret (value : String) {
    next { accessTokenSecret = Maybe::Just(value) }
  }

  fun setAccessToken (value : String) {
    next { accessToken = Maybe::Just(value) }
  }

  fun render : Html {
    <Page type="settings">
      <Ui.Box title=<{ "Settings" }>>
        <p>"You can configure TwitBot here."</p>

        <Ui.Container
          orientation="vertical"
          gap={Ui.Size::Em(1.5)}
          justify="start"
          align="stretch">

          <Ui.Field label="Consumer Key:">
            <Ui.Input
              value={Maybe.withDefault(data.settings.consumerKey, consumerKey)}
              onChange={setConsumerKey}/>
          </Ui.Field>

          <Ui.Field label="Consumer Secret:">
            <Ui.Input
              value={Maybe.withDefault(data.settings.consumerSecret, consumerSecret)}
              onChange={setConsumerSecret}/>
          </Ui.Field>

          <Ui.Field label="Access Token:">
            <Ui.Input
              value={Maybe.withDefault(data.settings.accessToken, accessToken)}
              onChange={setAccessToken}/>
          </Ui.Field>

          <Ui.Field label="Access Token Secret:">
            <Ui.Input
              value={Maybe.withDefault(data.settings.accessTokenSecret, accessTokenSecret)}
              onChange={setAccessTokenSecret}/>
          </Ui.Field>

          <div::status>
            if (data.settings.valid) {
              <>
                <Ui.Icon
                  icon={@svg(../../assets/icons/circle-check.svg)}
                  size={Ui.Size::Em(1.25)}/>

                "Your configuration is valid!"
              </>
            } else {
              <>
                <Ui.Icon
                  icon={@svg(../../assets/icons/circle-warning.svg)}
                  size={Ui.Size::Em(1.25)}/>

                "Your configuration is invalid!"
              </>
            }
          </div>

          <Ui.Button
            iconBefore={@svg(../../assets/icons/check.svg)}
            onClick={save}
            label="Save"/>

        </Ui.Container>
      </Ui.Box>

      <EmptyMessage
        image={@asset(../../assets/images/robot-hi.png)}
        title=<{ "Configure TwitBot" }>
        subtitle=<{
          "TwitBot needs a Twitter Application to operate."

          <div>
            "To set up a twitter application follow instuctions on the "
            <a>"help page."</a>
          </div>
        }>
        actions={
          <Ui.Button
            onClick={(event : Html.Event) { openLink("https://twitbot.netlify.app/") }}
            label="Go to the Help Page"/>
        }/>
    </Page>
  }
}
