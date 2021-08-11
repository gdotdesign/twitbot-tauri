component Pages.Tweets {
  connect App exposing { data, update }

  /* Deletes a source by the given name. */
  fun deleteSource (screenName : String) {
    data
    |> Twitbot.deleteTweetSource(screenName)
    |> update
  }

  /* Adds a source by the given name. */
  fun addSource (screenName : String) {
    data
    |> Twitbot.addTweetSource(screenName)
    |> update
  }

  /* Style for the icon. */
  style centered {
    text-align: center;
  }

  /* Renders the component. */
  fun render : Html {
    <>
      <Page type="two-column">
        <Ui.Column
          gap={Ui.Size::Em(2)}
          justify="start">

          <Ui.Box>
            <p>"Automatically retweet tweets of the sources sepcified below."</p>

            <BotStatus
              onStart={
                () {
                  update(Promise.resolve({ data | retweetBotEnabled = true }))
                }
              }
              onStop={() { update(Promise.resolve({ data | retweetBotEnabled = false })) }}
              running={data.retweetBotEnabled}/>
          </Ui.Box>

          if (data.retweetCount > 0) {
            <Ui.Box label=<{ "Stats" }>>
              <Stat
                label=<{ "Rewteets" }>
                count=<{ "#{data.retweetCount}" }>/>
            </Ui.Box>
          }

          if (Array.size(data.retweetSources) > 0) {
            <Ui.Box label=<{ "Sources" }>>
              <p>"Tweets are automatically loaded from these sources when needed."</p>

              <SourceList
                sources={data.retweetSources}
                onDelete={deleteSource}/>
            </Ui.Box>
          }

          <Ui.Box label=<{ "Add Source" }>>
            <AddSource onSubmit={addSource}/>
          </Ui.Box>

        </Ui.Column>

        if (Array.size(data.retweets) > 0) {
          <Ui.Box label=<{ "Retweet Queue" }>>
            <p>"One of the following tweets will be retweeted every 5 minutes (in display order)."</p>

            <Ui.Icon
              icon={Ui.Icons:REPLY}
              size={Ui.Size::Em(1.25)}
              interactive={true}
              onClick={
                (event : Html.Event) {
                  data
                  |> Twitbot.retweetNext
                  |> update
                }
              }/>

            <Ui.Icon
              icon={Ui.Icons:DASH}
              size={Ui.Size::Em(1.25)}
              interactive={true}
              onClick={
                (event : Html.Event) {
                  data
                  |> Twitbot.unRetweetNext
                  |> update
                }
              }/>

            try {
              headers =
                [
                  {
                    sortable = false,
                    sortKey = "user",
                    label = "User",
                    shrink = true
                  },
                  {
                    sortKey = "tweet",
                    sortable = false,
                    label = "tweet",
                    shrink = false
                  },
                  {
                    sortKey = "actions",
                    sortable = false,
                    label = "Actions",
                    shrink = true
                  }
                ]

              rows =
                for (tweet of data.retweets) {
                  {
                    tweet.text, [
                      Ui.Cell::Html(<User user={tweet.user}/>),
                      Ui.Cell::Html(<FormattedText text={tweet.text}/>),
                      Ui.Cell::Html(
                        <div::centered>
                          <Ui.Icon
                            icon={@svg(../../assets/icons/delete.svg)}
                            size={Ui.Size::Em(1.25)}
                            interactive={true}
                            onClick={
                              (event : Html.Event) {
                                data
                                |> Twitbot.deleteTweet(tweet.id)
                                |> update
                              }
                            }/>
                        </div>)
                    ]
                  }
                }

              <Ui.Table
                headers={headers}
                breakpoint={500}
                bordered={false}
                rows={rows}/>
            }
          </Ui.Box>
        } else {
          <EmptyMessage
            subtitle=<{ "You can add sources to get tweets from with the form on the left." }>
            image={@asset(../../assets/images/robot-empty-state.png)}
            title=<{ "There are no teweets to retweet!" }>
            actions=<{
              if (!Array.isEmpty(data.retweetSources)) {
                <Ui.Button
                  label="Get more Tweets!"
                  onClick={
                    (event : Html.Event) {
                      data
                      |> Twitbot.getNewTweets(0)
                      |> update
                    }
                  }/>
              } else {
                <{  }>
              }
            }>/>
        }
      </Page>
    </>
  }
}
