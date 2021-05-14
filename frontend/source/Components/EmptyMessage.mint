component EmptyMessage {
  property subtitle : Html = <{  }>
  property actions : Html = <{  }>
  property title : Html = <{  }>
  property image : String

  style base {
    display: grid;

    > * > * {
      place-content: center;
      display: grid;
    }
  }

  fun render : Html {
    <div::base>
      <Ui.Box>
        <Ui.IllustratedMessage
          subtitle=<{ subtitle }>
          title=<{ title }>
          image={
            <Ui.Image
              height={Ui.Size::Em(30)}
              width={Ui.Size::Em(25)}
              objectFit="contain"
              transparent={true}
              src={image}/>
          }/>
      </Ui.Box>
    </div>
  }
}
