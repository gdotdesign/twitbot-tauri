component Pages.FollowBot {
  connect App exposing { data, update }

  fun deleteSource (screenName : String) {
    data
    |> Twitbot.deleteFollowSource(screenName)
    |> update()
  }

  fun addSource (screenName : String) {
    data
    |> Twitbot.addFollowSource(screenName)
    |> update()
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

          <Ui.Box title=<{ "Follow Bot" }>>
            <p>" Automatically follow followers of the sources sepcified below."</p>

            <BotStatus
              onStart={() { update(Promise.resolve({ data | followBotEnabled = true })) }}
              onStop={() { update(Promise.resolve({ data | followBotEnabled = false })) }}
              running={data.followBotEnabled}/>
          </Ui.Box>

          if (data.followCount > 0) {
            <Ui.Box title=<{ "Stats" }>>
              <Stat
                label=<{ "Follows" }>
                count=<{ "#{data.followCount}" }>/>
            </Ui.Box>
          }

          if (Array.size(data.followSources) > 0) {
            <Ui.Box title=<{ "Sources" }>>
              <p>"Users are automatically loaded from these sources when needed."</p>

              <SourceList
                sources={data.followSources}
                onDelete={deleteSource}/>
            </Ui.Box>
          }

          <Ui.Box title=<{ "Add Source" }>>
            <AddSource onSubmit={addSource}/>
          </Ui.Box>

        </Ui.Container>

        if (Array.size(data.follows) > 0) {
          <Ui.Box title=<{ "Follow Queue" }>>
            <p>"One of the following users will be followed every 5 minutes (in display order)."</p>

            try {
              headers =
                [
                  {
                    sortKey = "user",
                    sortable = false,
                    label = "User",
                    shrink = true
                  },
                  {
                    sortKey = "description",
                    sortable = false,
                    label = "Description",
                    shrink = false
                  },
                  {
                    sortKey = "followers",
                    sortable = false,
                    label = "Followers",
                    shrink = true
                  },
                  {
                    sortKey = "actions",
                    sortable = false,
                    label = "Actions",
                    shrink = true
                  }
                ]

              rows =
                for (user of data.follows) {
                  {
                    "@#{user.screenName}", [
                      Ui.Cell::Html(<User user={user}/>),
                      Ui.Cell::Html(<FormattedText text={user.description}/>),
                      Ui.Cell::Html(
                        <div::centered>
                          <{ Number.toString(user.followersCount) }>
                        </div>),
                      Ui.Cell::Html(
                        <div::centered>
                          <Ui.Icon
                            icon={@svg(../../assets/icons/delete.svg)}
                            size={Ui.Size::Em(1.25)}
                            interactive={true}
                            onClick={
                              (event : Html.Event) {
                                Application.send("DELETE_USER", Maybe::Just(encode { id = user.id }))
                              }
                            }/>
                        </div>)
                    ]
                  }
                }

              <Ui.Table
                headers={headers}
                bordered={false}
                breakpoint={500}
                rows={rows}/>
            }
          </Ui.Box>
        } else {
          <EmptyMessage
            subtitle=<{ "You can add sources to get users from with the form on the left." }>
            image={@asset(../../assets/images/robot-empty-state.png)}
            title=<{ "There are no users to follow!" }>/>
        }
      </Page>
    </>
  }
}
