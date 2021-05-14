component AddSource {
  property onSubmit : Function(String, Promise(Never, Void)) = Promise.never1

  state value : String = ""

  fun handleClick (event : Html.Event) : Promise(Never, Void) {
    sequence {
      onSubmit(value)
      next { value = "" }
    }
  }

  fun handleChange (value : String) {
    next { value = value }
  }

  fun render : Html {
    <Ui.Container
      orientation="vertical"
      align="stretch">

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

    </Ui.Container>
  }
}
