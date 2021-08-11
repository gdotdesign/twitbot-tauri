record Twitter.FollowersListResponse {
  nextCursor : String using "next_cursor_str",
  users : Array(User)
}
