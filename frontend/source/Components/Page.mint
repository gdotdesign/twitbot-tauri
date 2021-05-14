component Page {
  connect Ui exposing { mobile }

  property children : Array(Html) = []
  property type : String = ""

  style base {
    grid-template-columns: #{columns};
    grid-gap: 30px;
    display: grid;
  }

  get columns {
    if (mobile) {
      "1fr"
    } else if (type == "settings") {
      "600px 1fr"
    } else {
      "300px 1fr"
    }
  }

  fun render : Html {
    <div::base>
      <{ children }>
    </div>
  }
}
