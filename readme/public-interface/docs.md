---
title: Docs
---

The feature map gem captures valuable insights about the features of your application (e.g. metrics like ABC size, lines of code, and cyclomatic complexity). To review this information locally, you can run `bin/featuremap docs` to produce a single, self contained HTML file that includes a fully functional documentation site with useful diagrams and details about the features of your application. This file is created within the `.feature_map/docs` directory and the `index.html` file can loaded in the browser of your choice by running `open .feature_map/docs/index.html`.

[You can view an example of the documentation site at right here]({{ '/example-docs-site.html' | relative_url }}){:target="_blank"}.

More information on the structure of this site can be found in the [Documentation Site - Overview]({{ '/documentation-site/overview' | 
}}).

**Example screenshot**
![Feature Map Docs Dashboard]({{ '/images/feature-map-docs-dashboard.png' | relative_url }})

# Command

> `bin/featuremap docs`

# Input

Successful generation of the documentation site depends on a handful of artifacts that must be generated first.

- [`.feature_map/metrics.yml`]({{ '/artifacts/metrics' | relative_url }}) (required)
- [`.feature_map/test-coverage.yml`]({{ '/artifacts/test-coverage' | relative_url }}) (optional)
- [`.feature_map/test-pyramid.yml`]({{ '/artifacts/test-pyramid' | relative_url }}) (optional)

# Output

The generation of the Documentation Site results in the creation of two files:
  - `.feature_map/docs/index.html`
  - `.feature_map/docs/feature-map-config.js`

More details on their composition and use can be found at:  [Artifacts - Docs]({{ '/artifacts/docs' | relative_url}})
