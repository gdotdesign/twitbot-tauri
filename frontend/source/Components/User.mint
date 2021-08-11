component User {
  /* The user to display. */
  property user : User

  /* Styles for the base element. */
  style base {
    grid-template-columns: min-content 1fr;
    grid-gap: 0.5em;
    line-height: 1;
    display: grid;

    > *:first-child {
      grid-row: span 2;
    }
  }

  /* Styles for the name. */
  style name {
    white-space: nowrap;
    font-size: 14px;
    align-self: end;
    display: block;
  }

  /* Styles for the link. */
  style link {
    color: var(--primary-link);
    text-decoration: none;
    font-size: 12px;
    opacity: 0.75;
  }

  /* Renders the component. */
  fun render : Html {
    <div::base>
      <Ui.Image
        src={user.profileImage}
        height={Ui.Size::Em(3)}
        width={Ui.Size::Em(3)}
        borderRadius="50%"/>

      <strong::name>
        <{ user.name }>
      </strong>

      <a::link>"@#{user.screenName}"</a>
    </div>
  }
}
