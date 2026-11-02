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

  - `repo` (required): the repository name. The organization comes from `repository.url`.
  - `display_name`: optional. The name shown in the message header. Defaults to `repo`.
  - `github_token` (required): a token that can read the repository's releases.
  - `slack_api_token`: the Slack app's token. When it, `slack_channel` or `slack_thread_parent_ts` is empty, the command prints the message it would have posted and posts nothing.
  - `slack_app_user_id`: the Slack app's user ID. When empty, messages from earlier releases are not cleaned up.
  - `slack_channel` and `slack_thread_parent_ts`: where to post. The channel can be a name (`#release-log`) or a channel ID.

A command with a required key left empty stops with an error naming the key.

The command also needs these top-level keys in `.feature_map/config.yml`:

  - `repository.url` and `documentation_site_url` (both required, and the command stops with an error if either is missing).
  - `repository.main_branch`: the branch whose commits are listed. Defaults to `main`.

Quote the values as shown. YAML reads an unquoted `1234567890.100000` as a number and drops the trailing zeros.

# Slack setup

  - The Slack app must be a member of the channel it posts to.
  - To delete messages from earlier releases, the command reads the thread, so the app needs the history permission for the channel type (`channels:history` for public channels, `groups:history` for private ones). A name like `#release-log` is only resolved for public channels, so use the channel ID for a private channel.

See [Continuous Integration - Release Notification]({{ '/continuous-integration/release-notification' | relative_url }}) for a GitHub Actions workflow that runs this command.

# Input

The command reads the git history of the checked-out repository, so check out the repository before running it. It loads up to 100 commits of history. Commits are read from `repository.main_branch`, which defaults to `main`.
