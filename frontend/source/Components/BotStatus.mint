component BotStatus {
  property onStart : Function(Promise(Never, Void)) = Promise.never
  property onStop : Function(Promise(Never, Void)) = Promise.never
  property running : Bool = false

  style status {
    justify-content: start;
    grid-auto-flow: column;
    align-items: center;
    grid-gap: 0.5em;
    display: grid;

    margin-bottom: 1em;
    font-weight: bold;

    &::before {
      border: 2px solid var(--input-border);
      border-radius: 50%;
      display: block;
      height: 20px;
      width: 20px;
      content: "";

      if (running) {
        background: #1add1a;
      } else {
        background: #ee3c3c;
      }
    }
  }

  fun handleStart (event : Html.Event) : Promise(Never, Void) {
    sequence {
      onStart()
      Ui.Notifications.notifyDefault(<{ "The bot has been started!" }>)
    }
  }

  fun handleStop (event : Html.Event) : Promise(Never, Void) {
    sequence {
      onStop()
      Ui.Notifications.notifyDefault(<{ "The bot has been stopped!" }>)
    }
  }

  fun render : Html {
    <Ui.Container
      orientation="vertical"
      align="stretch">

      if (running) {
        <>
          <div::status>
            <span>"RUNNING"</span>
          </div>

          <Ui.Button
            iconBefore={@svg(../../assets/icons/stop.svg)}
            onClick={handleStop}
            type="danger"
            label="Stop"/>
        </>
      } else {
        <>
          <div::status>
            <span>"STOPPED"</span>
          </div>

          <Ui.Button
            iconBefore={@svg(../../assets/icons/play.svg)}
            onClick={handleStart}
            label="Start"/>
        </>
      }

    </Ui.Container>
  }
}
