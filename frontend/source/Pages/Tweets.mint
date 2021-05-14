component Pages.Tweets {
  connect App exposing { data, update }

  fun deleteSource (screenName : String) {
    data
    |> Twitbot.deleteTweetSource(screenName)
    |> update
  }

  fun addSource (screenName : String) {
    data
    |> Twitbot.addTweetSource(screenName)
    |> update
  }

  style centered {
    text-align: center;
  }

  fun render : Html {
    <>
      <Page type="two-column">
        <Ui.Container
          orientation="vertical"
          gap={Ui.Size::Em(2)}
          justify="start"
          align="stretch">

          <Ui.Box title=<{ "Retweet Bot" }>>
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
            <Ui.Box title=<{ "Stats" }>>
              <Stat
                label=<{ "Rewteets" }>
                count=<{ "#{data.retweetCount}" }>/>
            </Ui.Box>
          }

          if (Array.size(data.retweetSources) > 0) {
            <Ui.Box title=<{ "Sources" }>>
              <p>"Tweets are automatically loaded from these sources when needed."</p>

              <SourceList
                sources={data.retweetSources}
                onDelete={deleteSource}/>
            </Ui.Box>
          }

          <Ui.Box title=<{ "Add Source" }>>
            <AddSource onSubmit={addSource}/>
          </Ui.Box>

        </Ui.Container>

        if (Array.size(data.retweets) > 0) {
          <Ui.Box title=<{ "Retweet Queue" }>>
            <p>"One of the following tweets will be retweeted every 5 minutes (in display order)."</p>

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
            title=<{ "There are no teweets to retweet!" }>/>
        }
      </Page>
    </>
  }
}
