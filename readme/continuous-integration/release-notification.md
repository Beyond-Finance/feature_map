---
title: Release Notification
---

Once FeatureMap has been integrated into an application, the knowledge of which files are assigned to a given Feature may be used during the publication of a release (or upon the merge to a main branch).  The specific implementation depends largely on the structure of a given application, but broadly you may consider:

  - Inspect the files that have been modified as part of a given release
  - Use FeatureMap's [`for_file`](({{ '/public-interface/for-file' | relative_url }})) public interface to retrieve Feature assignment data for each of those files
  - Collect and group changes to each associated Feature
  - Publish the change to a shared space, like Slack
