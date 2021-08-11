component SourceList {
  /* The delete event handler. */
  property onDelete : Function(String, Promise(Never, Void)) = Promise.never1

  /* The sources to display. */
  property sources : Array(String) = []

  /* Styles for the base element. */
  style base {
    line-height: 26px;
    font-weight: bold;
    grid-gap: 10px;
    display: grid;

    > div {
      grid-template-columns: 1fr min-content;
      align-items: center;
      display: grid;
    }
  }

  /* Renders the component. */
  fun render : Html {
    <Ui.Column>
      for (source of sources) {
        <Ui.Row justify="space-between">
          <div>"@#{source}"</div>

          <Ui.Icon
            onClick={(event : Html.Event) { onDelete(source) }}
            icon={@svg(../../assets/icons/delete.svg)}
            size={Ui.Size::Em(1.25)}
            interactive={true}/>
        </Ui.Row>
      }
    </Ui.Column>
  }
}
