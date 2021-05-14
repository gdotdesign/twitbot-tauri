component FormattedText {
  property text : String = ""

  style base {
    background: var(--input-color);
    border-radius: 0.375em;
    white-space: normal;
    line-height: 1.5;
    padding: 1em;

    &:empty {
      display: none;
    }
  }

  fun render : Html {
    <div::base>
      <{ text }>
    </div>
  }
}
