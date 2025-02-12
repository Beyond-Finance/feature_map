---
title: Feature Definition
---

# What is a Feature?

The set of features that compose your application must be defined before they can be used in assignment.  We think of a "feature" of an application as a way to decompose its overall function into discrete, coherent units.  Our formal, working definition is as follows:

> A feature is an internal component of the system that performs a well defined and relatively isolated set of responsibilities.

It's also helpful to understand what articulating the features of a system _does_:

  - Allows useful conversations about the operation of a given function of the system (e.g., authentication, payment processing)
  - Allows folks without deep, firsthand knowledge of the details of a given set of source files, to understand the value that they provide as a whole
  - Allows for extension, refactoring, or other planning activities to consider specific, but holistic units of the system without delving into individual files
  - In systems where files are organized by type (e.g., models, controllers, views, service classes), allows for source files to be grouped by function without clumsy in-code namespacing

**Here are a few examples of poorly-constructed features**

| Feature | Reason|
Program Management | Too big
API Endpoints | Supports many use cases; not well isolated
Slow Jobs | No well defined responsibilities
Blueprints | Code construct used by multiple features

In short, a feature is well-defined if it can be used to reason about a distinct part of a system at a level more abstract that a few source files.

# Where are Features defined?

All features are defined within a single CSV file located at `.feature_map/feature_definitions.csv`.  That file may optionally begin with one or more `#` denoted, sequential comments that describe the file and the strategy used to manage the feature list.  Then it must have a single header row with following headings -- followed by corresponding values.  Only the `Name` must be populated with a value for each row.
  - Name:  Canonical name of the Feature.  May include spaces or other punctuation.
  - Description:  A text description of the feature for reference.
  - Documentation Link:  A URL that points to more comprehensive, external documentation if available.

**Here's an example of what that file might look like**

```
# Comment explaining the purpose of this file and how it should be managed.
# Perhaps directly modifying this file in the repository, or exporting it from elsewhere.

Name,Description,
Onboarding,"Lorem ipsum dolor sit amet, consectetur adipiscing elit.",https://www.notion.so/onboarding-feature-abcd1234
User Management,"Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation",
```
