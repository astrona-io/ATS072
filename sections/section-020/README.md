---
draft: true
exam_objectives:
- Customizing Backstage plugins
---
# Customizing Backstage plugins

This section covers customizing Backstage plugins without forking them. The first module changes plugin behavior with configuration: layered `app-config` files, environment substitution, a `config.d.ts` schema with visibility tags, and reading values through `coreServices.rootConfig` and `configApiRef`. The second module extends plugins with backend modules, frontend extension overrides and permission policies, and keeps the result upgradable.

Each module has a playground and a hands-on lab that you solve by editing files in a small virtual machine. The section ends with a capstone lab and a quiz.

## Learning Outcomes

- Choose between configuration and supported extension mechanisms.
- Explain compatibility and ownership risks of private modifications.
- Reason about permission and response contracts when extending a feature.
- Edit configuration, schemas, backend modules and permission policies and have the result graded by checks.
