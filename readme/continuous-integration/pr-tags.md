---
title: Release Notification
---

Once FeatureMap has been integrated into an application, the knowledge of which files are assigned to a given feature may be used during the pull request review process.  The specific implementation depends largely on the structure of a given application, but broadly you may consider the following steps:

- Inspect the files that have been modified as part of a pull request
- Use FeatureMap's [`for_file`](({{ '/public-interface/for-file' | relative_url }})) public interface to retrieve feature assignment data for each of those files
- Collect and group changes to each associated feature
  - This process can be aided by the [`group_commits`](https://github.com/Beyond-Finance/feature_map/blob/8592afe515649ccf936b539e9419070c6daced7f/lib/feature_map.rb#L212) method exposed by FeatureMap
- Publish the changes back to GitHub via a label or comment on the PR
