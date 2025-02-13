---
title: Docs
---

The feature map gem captures valuable insights about the features of your application (e.g. metrics like ABC size, lines of code, and cyclomatic complexity). To review this information locally, you can run `bin/featuremap docs` to produce a single, self contained HTML file that includes a fully functional documentation site with useful diagrams and details about the features of your application. This file is created within the `.feature_map/docs` directory and the `index.html` file can loaded in the browser of your choice by running `open .feature_map/docs/index.html`.

**Example screenshot**
![Feature Map Docs Dashboard]({{ '/images/feature-map-docs-dashboard.png' | relative_url }})
