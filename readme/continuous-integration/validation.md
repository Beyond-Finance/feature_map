---
title: Validation
---

Once FeatureMap has been integrated into an application, it's important to keep feature annotations up-to-date.  This is best done via an existing continuous integration pipeline (e.g., GitHub Actions, or CircleCI).

In order to validate that all required files have annotations, you might orchestrate the execution of [`bin/featuremap validate`]({{ '/interface/validate' | relative_url }}), which will return a non-zero exit code if some files are missing annotations.  This can be used within a CI build to fail that build and block the proposed pull request from merging until annotations have been resolved.  This occurs most frequently when new source files have been added to an application without being assigned to a feature.

You might also ensure that existing annotations do not change without review by checking-in the the `.feature_map/assignments.yml` which is generated when `bin/featuremap validate` is run locally.  Once checked in, and after `bin/featuremap validate` is run in CI, that same `assignments.yml` can be checked for changes.  This ensure that, if a given source files feature annotation _changes_, that it is made explicit by a corresponding change to the checked-in `assignments.yml`.  _Note_:  Checking in this file is optional.
