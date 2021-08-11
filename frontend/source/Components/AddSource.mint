component AddSource {
  /* The submit event handler. */
  property onSubmit : Function(String, Promise(Never, Void)) = Promise.never1

  /* The value of the input. */
  state value : String = ""

  /* Handles the click event of the button. */
  fun handleClick (event : Html.Event) : Promise(Never, Void) {
    sequence {
      onSubmit(value)
      next { value = "" }
    }
  }

  /* Handles the change event of the input. */
  fun handleChange (value : String) {
    next { value = value }
  }

  /* Renders the component. */
  fun render : Html {
    <Ui.Column gap={Ui.Size::Em(1)}>
      <Ui.Field label="Twitter Handle:">
        <Ui.Input
          onChange={handleChange}
          placeholder="Twitter"
          value={value}/>
      </Ui.Field>

      <Ui.Button
        iconBefore={@svg(../../assets/icons/user-add.svg)}
        onClick={handleClick}
        type="secondary"
        label="Add"/>
    </Ui.Column>
  }
}
