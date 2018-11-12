To view it in action: [https://robertdp.github.io/frontend-test/dist/](https://robertdp.github.io/frontend-test/dist/)

This project uses:
- PureScript
- React.js
- Tailwind CSS

To use the build command included with this project, you will need to install Zephyr ([https://github.com/coot/zephyr](https://github.com/coot/zephyr)) as an extra step.

The breakdown:

Module | Description
--- | ---
`Main` | Bootstraps the React app with a `Config`
`Component.*` | The React components
`Control.Language.*` | DSL definitions for the different effectful domains used
`Control.App` | Implementation of the DSLs for the current app (different implementations can be used for testing, client-/server-side implementations etc.)
`Data.*` | Custom data types
`Logic.*` | Business logic written in the DSLs. Not tied to any implementation.

Regarding the bundle size, there are a couple of libraries that really piled the kilobytes on and were really only used for small, specific tasks like date formatting. They could be removed, but I was more focused on convenience with this project.
