component EmptyMessage {
  /* The subtitle to display. */
  property subtitle : Html = <></>

  /* The actions to display. */
  property actions : Html = <></>

  /* The title to display. */
  property title : Html = <></>

  /* The image to display. */
  property image : String

  fun render : Html {
    <Ui.Box fitContent={true}>
      <Ui.IllustratedMessage
        subtitle=<{ subtitle }>
        title=<{ title }>
        actions=<{ actions }>
        image={
          <Ui.Image
            height={Ui.Size::Em(30)}
            width={Ui.Size::Em(25)}
            objectFit="contain"
            transparent={true}
            src={image}/>
        }/>
    </Ui.Box>
  }
}
