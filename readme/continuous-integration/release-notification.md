---
title: Release Notification
---

Once FeatureMap has been integrated into an application, the knowledge of which files are assigned to a given feature may be used during the publication of a release (or upon the merge to a main branch).  The specific implementation depends largely on the structure of a given application, but broadly you may consider the following steps:

- Inspect the files that have been modified as part of a given release
- Use FeatureMap's [`for_file`](({{ '/public-interface/for-file' | relative_url }})) public interface to retrieve feature assignment data for each of those files
- Collect and group changes to each associated feature
  - This process can be aided by the [`group_commits`](https://github.com/Beyond-Finance/feature_map/blob/8592afe515649ccf936b539e9419070c6daced7f/lib/feature_map.rb#L212) and [`generate_release_notification`](https://github.com/Beyond-Finance/feature_map/blob/8592afe515649ccf936b539e9419070c6daced7f/lib/feature_map.rb#L243C7-L243C36) methods exposed by FeatureMap
- Publish the change to a shared space, like Slack
