---
title: Continuous Integration - PR Tags
---

Once FeatureMap has been integrated into an application, the knowledge of which files are assigned to a given feature may be used during the pull request review process.  The specific implementation depends largely on the structure of a given application, but broadly you may consider the following steps:

- Inspect the files that have been modified as part of a pull request
- Use FeatureMap's [`for_file`](({{ '/public-interface/for-file' | relative_url }})) public interface to retrieve feature assignment data for each of those files
- Collect and group changes to each associated feature
  - This process can be aided by the [`group_commits`](https://github.com/Beyond-Finance/feature_map/blob/8592afe515649ccf936b539e9419070c6daced7f/lib/feature_map.rb#L212) method exposed by FeatureMap
- Publish the changes back to GitHub via a label or comment on the PR

The [`github_pr_annotation`]({{ '/public-interface/github-pr-annotation' | relative_url }}) command does this for GitHub pull requests.

# Example GitHub Actions workflow

The annotation compares the pull request's metrics with the base branch's, so the workflow generates both.  `ACCESS_TOKEN_GITHUB` is a secret holding a token that can read the pull request and write comments and labels.

{% raw %}
```yaml
name: Annotate Pull Request with Features
on:
  pull_request:
    types: [opened, synchronize, reopened]
permissions:
  contents: read
  pull-requests: write
jobs:
  annotate:
    runs-on: ubuntu-latest
    env:
      REPO: ${{ github.event.repository.name }}
      PR_NUMBER: ${{ github.event.pull_request.number }}
      ACCESS_TOKEN_GITHUB: ${{ secrets.ACCESS_TOKEN_GITHUB }}
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.base_ref }}
      - uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      - run: bundle exec featuremap validate || true
      - if: ${{ hashFiles('.feature_map/metrics.yml') != '' }}
        run: mv .feature_map/metrics.yml ${{ runner.temp }}/base_metrics.yml
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      - run: bundle exec featuremap validate || true
      - if: ${{ hashFiles('.feature_map/metrics.yml') != '' }}
        env:
          BASE_METRICS_PATH: ${{ runner.temp }}/base_metrics.yml
        run: bundle exec featuremap github_pr_annotation
```
{% endraw %}
