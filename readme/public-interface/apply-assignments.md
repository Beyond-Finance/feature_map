---
title: Apply Assignments
---

When first integrating FeatureMap into a new codebase, there will often be many files that must be assigned to a feature at once.

We've found it helpful to start this process in a spreadsheet, since it's easy to review and modify file or directory assignments.

Once this is done, you can export that sheet for use in automatically applying those assignments with `bin/featuremap apply_assignments [assignments.csv]`

# Command

> `bin/featuremap apply_assignments [assignments.csv]`

# Input

The provided `assignments.csv` should be a CSV with two fields and **no header row**.  The first field is a file or directory path relative to the root of your project.  The second field is the feature to be assigned.

**Example:**
```
src/auth/controllers/login_controller.rb, Authentication
src/auth/services/oauth_service.rb, Authentication
src/payments, Payment Processing
```

# Output

The `apply_assignments` command will process each assignment, annotating near the top of the file with the language-appropriate comment for those languages that FeaturteMap supports.  When provided a directory, it will create the `.feature` file with the given feature instead.

The `apply_assignments` script will attempt not to duplicate assignments when run repeatedly, but be sure to check your results before committing the assignments.  When in doubt, clean up the changes (`git clean -df`), and then apply again.
