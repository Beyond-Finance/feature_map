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

  - `repo`: the repository name. The organization comes from `repository.url`.
  - `display_name`: optional. The name shown in the message header. Defaults to `repo`.
  - `github_token`: a token that can read the repository's releases.
  - `release_ref`: the release tag, as `refs/tags/<tag>`.
  - `teams`: each team's name, exactly as CodeOwnership names it, and its Slack webhook URL.

# Input

The command reads the git history of the checked-out repository, so check out the repository before running it. It loads up to 100 commits of history.
