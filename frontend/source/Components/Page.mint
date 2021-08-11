component Page {
  connect Ui exposing { mobile }

  /* The children to render. */
  property children : Array(Html) = []

  /* The type of the page. */
  property type : String = ""

  /* Styles for the base element. */
  style base {
    grid-template-columns: #{columns};
    grid-gap: 30px;
    display: grid;
  }

  /* Value for the gird columns. */
  get columns : String {
    if (mobile) {
      "1fr"
    } else if (type == "settings") {
      "600px 1fr"
    } else {
      "300px 1fr"
    }
  }

  /* Renders the component. */
  fun render : Html {
    <div::base>
      <{ children }>
    </div>
  }
}
