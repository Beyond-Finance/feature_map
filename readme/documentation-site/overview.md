---
title: Overview
---

The documentation site provides a visual representation of the set of features that an application is composed of, as well as details on those features' description, composition, health, and test coverage.

[You can view an example of the documentation site at right here]({{ '/example-docs-site.html' | relative_url }}){:target="_blank"}.

More information on the generation of this site can be found in [Public Interface - Docs]({{ '/public-interface/docs' | relative_url }})

**Example screenshot**
![Feature Map Docs Dashboard]({{ '/images/feature-map-docs-dashboard.png' | relative_url }})

# Pages
The documentation site is composed of three primary pages:
  - The "Index" page, which displays high-level project metrics for features, as well as a table view index of all features.
  - The feature "Show" page, accessed by click an individual feature in the Index Page's table, which displays details of the given feature, including a link to additional documentation, an overview of its composition, and other details.
  - The "Digest" page, accessed at the [/#Digest]({{ '/example-docs-site.html/#Digest' | relative_url }}) route, which displays details about features that could use improvement, as well as a picture of the project's "[Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html){:target="_blank"}."

# Requirements
Successful generation of the documentation site depends on the existence of a handful of artifacts.  For more, see the [docs interface]({{ '/public-interface/docs' | relative_url }}) documentation.

# Publication

The output artifacts may be uploaded to any system, e.g., GitHub Pages, that serves HTML sites, so that the documentation site may be published and available for use by your organization.
