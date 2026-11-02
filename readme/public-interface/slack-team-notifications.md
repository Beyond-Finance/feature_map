---
title: Public Interface - Slack Team Notifications
---

For a release tag, posts each team a Slack message listing the features it is responsible for that the release changed, with the pull requests that changed them. Teams come from [CodeOwnership]({{ '/getting-started/with-code-ownership' | relative_url }}).

This command posts to Slack for every team that has a webhook and affected features. A team with an empty webhook gets a printed message instead of a post.

# Command

> `bin/featuremap slack_team_notifications`

The command takes no arguments. All of its settings come from the `slack_team_notifications` section of `.feature_map/config.yml`. Without that section, the command prints that it is not configured and exits successfully.

# Configuration

```
slack_team_notifications:
  repo: '<%= ENV.fetch('REPO', '') %>'
  display_name: Example
  github_token: '<%= ENV.fetch('ACCESS_TOKEN_GITHUB', '') %>'
  release_ref: '<%= ENV.fetch('RELEASE_REF', '') %>'
  teams:
    Onboarding: '<%= ENV.fetch('ONBOARDING_SLACK_WEBHOOK', '') %>'
```

  - `repo` (required): the repository name. The organization comes from `repository.url`.
  - `display_name`: optional. The name shown in the message header. Defaults to `repo`.
  - `github_token` (required): a token that can read the repository's releases.
  - `release_ref` (required): the release tag, as `refs/tags/<tag>`. Any other value stops the command with an error.
  - `teams`: each team's name, exactly as CodeOwnership names it, and its Slack webhook URL. A team with an empty webhook is skipped.

A command with a required key left empty stops with an error naming the key.

The command also needs `repository.url` in `.feature_map/config.yml`, and stops with an error if it is missing. When `documentation_site_url` is set, each feature in a message links to its page on the documentation site.

# Setting it up

See [Continuous Integration - Release Notification]({{ '/continuous-integration/release-notification' | relative_url }}) for a GitHub Actions workflow that runs this command.

# Input

The command reads the git history of the checked-out repository, so check out the repository before running it. It loads up to 100 commits of history.
