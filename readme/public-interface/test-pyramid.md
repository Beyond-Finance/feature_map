---
title: Public Interface - Test Pyramid
---

The feature map gem supports reporting on the [test pyramid](https://martinfowler.com/bliki/TestPyramid.html) coverage of the application and its constituent features.  It works, broadly, by:  accepting test execution reports (e.g., rspec's `json` format) for unit, integration, and regression tests -- and then matches those tests to their corresponding features as follows:
  - Unit:  Uses tech stack conventions or optional direct assignment.
    - For example, rspec tests in `spec/models/user_spec.rb` are resolved to the `app/models/user.rb` implementation file, which may be matched with its feature annotation.
  - Integration:  Integration tests do not correspond to a single implementation file (though generally live within the same codebase), so they must be directly annotated with the feature they support.
  - Regression:  Regression tests do not correspond to a single implementation file, and may live in a given codebase or in a separate repository.  They must both be tagged with the feature that they support, and a reference to the assignments of regression tests must be passed to the test pyramid generation command.

Once test pyramid data has been generated for a give project, it's automatically included in that project's doc site.

# Command

> `bin/featuremap test_pyramid [unit_examples_file] [integration_examples_file] [regression_examples_file] [regression_assignments_file]`

# Input

FeatureMap currently supports _examples files_ in rspec's `json` format (--format json) or jest's `json` format (`--json`).  Example files are parsed based on their file extension:

  - `some-test.rspec`:  indicates examples in rspec's format
  - `some-test.jest`:  indicates examples in jest's format

The regression assignments file is optional.  When not provided, regression assignments will be made using the project's own assignments file ([Artifacts - Assignments]({{ '/artifacts/assignments' | relative_url }})).  When provided, it should point to another repository's assignments where regression tests are executed.

## Skipping Coverage

Some repositories may be missing unit, integration, or regression testing.  Passing any filename with the `.skip`, e.g., `anything.skip`.  Note:  this file does not need to actually exist in the filesystem.

# Output

This command results in the generation of `.feature_map/test-pyramid.yml`.  More information regarding this artifact can be found at [Artifacts - Test Pyramid]({{ '/artifacts/test-pyramid' | relative_url }}).
