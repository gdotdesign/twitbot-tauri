component FormattedText {
  /* The text to display. */
  property text : String = ""

  /* Styles for the base element. */
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

  /* Renders the component. */
  fun render : Html {
    <div::base>
      <{ text }>
    </div>
  }
}
