component Stat {
  /* The count to display. */
  property count : Html = <{  }>

  /* The label to display. */
  property label : Html = <{  }>

  /* Styles for the base element. */
  style base {
    strong {
      font-size: 3em;
      line-height: 1;
    }

    span {
      margin-left: 0.5em;
      opacity: 0.75;
    }
  }

  /* Renders the component. */
  fun render : Html {
    <div::base>
      <strong>
        <{ count }>
      </strong>

      <span>
        <{ label }>
      </span>
    </div>
  }
}
