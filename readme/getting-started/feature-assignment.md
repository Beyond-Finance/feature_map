---
title: Getting Started - Feature Assignment
---

There are multiple ways to assign the feature for a source file using this gem.  The [`bin/featuremap apply_assignments`]({{ '/public-interface/apply-assignments' | relative_url }}) command can aid in applying new assignments across a codebase.

# Directory-Based Assignment
Directory based assignment allows for all files in that directory and all its sub-directories to be assigned to a single feature. To define this, add a `.feature` file inside that directory with the name of the feature as the contents of that file.

```
echo "Onboarding" > .feature
```

# File-Annotation Based Assignment
File annotations go at the top of your file, and look like any of these:

```
# @feature Onboarding
```

```
// @feature Onboarding
```

```
/*
 * @feature Onboarding
 * ...Additional heading documentation
 */
```

```
<!-- @feature Onboarding -->
```

```
''' @feature Onboarding '''
```
