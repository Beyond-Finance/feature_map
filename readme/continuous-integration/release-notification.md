---
title: Continuous Integration - Release Notification
---

Once FeatureMap has been integrated into an application, the knowledge of which files are assigned to a given feature may be used during the publication of a release (or upon the merge to a main branch).  The specific implementation depends largely on the structure of a given application, but broadly you may consider the following steps:

- Inspect the files that have been modified as part of a given release
- Use FeatureMap's [`for_file`](({{ '/public-interface/for-file' | relative_url }})) public interface to retrieve feature assignment data for each of those files
- Collect and group changes to each associated feature
  - This process can be aided by the [`group_commits`](https://github.com/Beyond-Finance/feature_map/blob/8592afe515649ccf936b539e9419070c6daced7f/lib/feature_map.rb#L212) and [`generate_release_notification`](https://github.com/Beyond-Finance/feature_map/blob/8592afe515649ccf936b539e9419070c6daced7f/lib/feature_map.rb#L243C7-L243C36) methods exposed by FeatureMap
- Publish the change to a shared space, like Slack

The [`slack_release_log`]({{ '/public-interface/slack-release-log' | relative_url }}) and [`slack_team_notifications`]({{ '/public-interface/slack-team-notifications' | relative_url }}) commands do this for Slack.

# Example GitHub Actions workflows

Both commands read the git history of the checkout and need `ACCESS_TOKEN_GITHUB`, a secret holding a token that can read the repository's releases.

Post the changes since the last release to a Slack thread whenever the main branch changes:

{% raw %}
```yaml
name: Publish Changes to Release Log
on:
  push:
    branches: [main]
jobs:
  release_log:
    runs-on: ubuntu-latest
    env:
      REPO: ${{ github.event.repository.name }}
      ACCESS_TOKEN_GITHUB: ${{ secrets.ACCESS_TOKEN_GITHUB }}
      RELEASE_LOG_SLACK_API_TOKEN: ${{ secrets.RELEASE_LOG_SLACK_API_TOKEN }}
      RELEASE_LOG_SLACK_APP_USER_ID: ${{ vars.RELEASE_LOG_SLACK_APP_USER_ID }}
      RELEASE_LOG_SLACK_CHANNEL_NAME: '#release-log'
      RELEASE_LOG_SLACK_THREAD_PARENT_TS: ${{ vars.RELEASE_LOG_SLACK_THREAD_PARENT_TS }}
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      - run: bundle exec featuremap slack_release_log
```
{% endraw %}

Notify each team when a release is published:

{% raw %}
```yaml
name: Deliver Team Release Notifications
on:
  release:
    types: [published]
jobs:
  team_notifications:
    runs-on: ubuntu-latest
    env:
      REPO: ${{ github.event.repository.name }}
      RELEASE_REF: ${{ github.ref }}
      ACCESS_TOKEN_GITHUB: ${{ secrets.ACCESS_TOKEN_GITHUB }}
      ONBOARDING_SLACK_WEBHOOK: ${{ secrets.ONBOARDING_SLACK_WEBHOOK }}
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      - run: bundle exec featuremap slack_team_notifications
```
{% endraw %}

To try either command without posting, leave the Slack token or webhooks unset.  The command prints the message it would have sent.
