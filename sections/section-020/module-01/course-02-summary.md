---
draft: true
exam_objectives:
- Customizing Backstage plugins
---
# Summary

Customization should use the narrowest supported contract that meets the user need: configuration, frontend composition or a backend extension point. Public APIs and explicit version compatibility make changes maintainable. A visual override does not alter server authorization, and a backend extension still needs validated inputs and limited authority. Forking private implementation increases maintenance work and requires clear ownership for future framework and plugin updates.
