---
title: Public Interface - Slack Release Log
---

Posts the changes merged since the previous GitHub release, with the features each commit affects, as a reply in a Slack thread. Release log messages posted by the Slack app more than one day ago are deleted from that thread.

This command posts to Slack when a Slack API token, channel and thread timestamp are all set. With any of them empty it prints the message it would have posted and posts nothing.

# Command

> `bin/featuremap slack_release_log`

The command takes no arguments. All of its settings come from the `slack_release_log` section of `.feature_map/config.yml`. Without that section, the command prints that it is not configured and exits successfully.

# Configuration

```
slack_release_log:
  repo: '<%= ENV.fetch('REPO', '') %>'
  display_name: Example
  github_token: '<%= ENV.fetch('ACCESS_TOKEN_GITHUB', '') %>'
  slack_api_token: '<%= ENV.fetch('RELEASE_LOG_SLACK_API_TOKEN', '') %>'
  slack_app_user_id: '<%= ENV.fetch('RELEASE_LOG_SLACK_APP_USER_ID', '') %>'
  slack_channel: '<%= ENV.fetch('RELEASE_LOG_SLACK_CHANNEL_NAME', '') %>'
  slack_thread_parent_ts: '<%= ENV.fetch('RELEASE_LOG_SLACK_THREAD_PARENT_TS', '') %>'
```

  - `repo`: the repository name. The organization comes from `repository.url`.
  - `display_name`: optional. The name shown in the message header. Defaults to `repo`.
  - `github_token`: a token that can read the repository's releases.
  - `slack_api_token`: the Slack app's token.
  - `slack_app_user_id`: the Slack app's user ID. Without it, past messages are not cleaned up.
  - `slack_channel` and `slack_thread_parent_ts`: where to post.

Quote the values as shown. YAML reads an unquoted `1234567890.100000` as a number and drops the trailing zeros.

# Input

The command reads the git history of the checked-out repository, so check out the repository before running it. It loads up to 100 commits of history.
