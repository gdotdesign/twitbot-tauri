component Stat {
  property count : Html = <{  }>
  property label : Html = <{  }>

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
