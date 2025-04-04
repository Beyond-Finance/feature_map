---
title: Artifacts - Assignments
---

The assignments file holds a mapping of files and their assigned feature &mdash; as well as features and their assigned files.  This file may be found:  `.feature_map/assignments.yml`

# Generation

The assignments file is generated by the [`bin/featuremap validate`]({{ '/public-interface/validate' | relative_url }}) command.

# Structure

```
---
files:
  src/auth/controllers/login_controller.rb:
    feature: Authentication
    mapper: Annotations at the top of file
  src/auth/services/oauth_service.rb:
    feature: Authentication
    mapper: Annotations at the top of file
  src/payments/**/**:
    feature: Payment Processing
    mapper: Feature Assigned in .feature
features:
  Authentication:
    files:
    - src/auth/controllers/login_controller.rb
    - src/auth/services/oauth_service.rb
    teams:
    - Core
  Payment Processing:
    files:
    - src/payments/payments.js
    - src/payments/style.css
    - src/payments/index.html
  - teams:
    - Payments
    - Core
```
