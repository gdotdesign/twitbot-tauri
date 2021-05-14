component SourceList {
  property onDelete : Function(String, Promise(Never, Void)) = Promise.never1
  property sources : Array(String) = []

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

  fun render : Html {
    <Ui.Container
      orientation="vertical"
      align="stretch">

      for (source of sources) {
        <Ui.Container justify="space-between">
          <div>"@#{source}"</div>

          <Ui.Icon
            onClick={(event : Html.Event) { onDelete(source) }}
            icon={@svg(../../assets/icons/delete.svg)}
            size={Ui.Size::Em(1.25)}
            interactive={true}/>
        </Ui.Container>
      }

    </Ui.Container>
  }
}
