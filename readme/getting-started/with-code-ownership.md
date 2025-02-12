---
title: Code Ownership
---

FeatureMap delegates to the [CodeOwnership](https://github.com/rubyatscale/code_ownership) gem in order to enforce its `require_assignment_for_teams` configuration directive.  In order to specify team-based assignment in FeatureMap, those same teams must exist and be configured via CodeOwnership's config files.

Because CodeOwnership is executed by FeatureMap (e.g., via [inline bundling](/getting-started/inline-execution)), team assignment and FeatureMap team enforcement will function in any environment that this library is installed in -- with the following caveats:

  - Any environment may describe team ownership via CodeOwnership's glob pattern, or `.codeowner` file-based team assignment.
  - Only environments that support `#`-style commments may include inline `# @team Foo` style team assignments.
