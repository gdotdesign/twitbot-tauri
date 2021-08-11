component Pages.Settings {
  connect Application exposing { openLink }
  connect App exposing { data, update }

  /* The state for the consumer secret. */
  state consumerSecret : Maybe(String) = Maybe::Nothing

  /* The state for the consumer key. */
  state consumerKey : Maybe(String) = Maybe::Nothing

  /* The state for the access token secret. */
  state accessTokenSecret : Maybe(String) = Maybe::Nothing

  /* The state for the access token. */
  state accessToken : Maybe(String) = Maybe::Nothing

  /* Styles for the status box. */
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

  /* Saves the settings. */
  fun save (event : Html.Event) {
    data
    |> Twitbot.updateSettings(
      {
        consumerSecret = consumerSecret or data.settings.consumerSecret,
        consumerKey = consumerKey or data.settings.consumerKey,
        accessTokenSecret = accessTokenSecret or data.settings.accessTokenSecret,
        accessToken = accessToken or data.settings.accessToken,
        valid = false
      })
    |> update
  }

  /* Sets the consumer key. */
  fun setConsumerKey (value : String) {
    next { consumerKey = Maybe::Just(value) }
  }

  /* Sets the consumer secret. */
  fun setConsumerSecret (value : String) {
    next { consumerSecret = Maybe::Just(value) }
  }

  /* Sets the access token secret. */
  fun setAccessTokenSecret (value : String) {
    next { accessTokenSecret = Maybe::Just(value) }
  }

  /* Sets the access token. */
  fun setAccessToken (value : String) {
    next { accessToken = Maybe::Just(value) }
  }

  /* Renders the component. */
  fun render : Html {
    <Page type="settings">
      <Ui.Box>
        <p>"You can configure TwitBot here."</p>

        <Ui.Column
          gap={Ui.Size::Em(1.5)}
          justify="start">

          <Ui.Field label="Consumer Key:">
            <Ui.Input
              value={consumerKey or data.settings.consumerKey}
              onChange={setConsumerKey}/>
          </Ui.Field>

          <Ui.Field label="Consumer Secret:">
            <Ui.Input
              value={consumerSecret or data.settings.consumerSecret}
              onChange={setConsumerSecret}/>
          </Ui.Field>

          <Ui.Field label="Access Token:">
            <Ui.Input
              value={accessToken or data.settings.accessToken}
              onChange={setAccessToken}/>
          </Ui.Field>

          <Ui.Field label="Access Token Secret:">
            <Ui.Input
              value={accessTokenSecret or data.settings.accessTokenSecret}
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

        </Ui.Column>
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
