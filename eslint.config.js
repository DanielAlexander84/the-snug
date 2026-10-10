// JS lint gate (D8). Covers the React code and the root JS config files.
// There were no findings when the gate was switched on, so there is no baseline.
import js from "@eslint/js"
import globals from "globals"
import react from "eslint-plugin-react"
import reactHooks from "eslint-plugin-react-hooks"
import prettier from "eslint-config-prettier"

export default [
  {
    ignores: ["node_modules/", "public/", "vendor/", "tmp/", "log/", "storage/", "app/assets/builds/", "docs/"],
  },
  js.configs.recommended,
  {
    files: ["app/frontend/**/*.{js,jsx}"],
    ...react.configs.flat.recommended,
    languageOptions: {
      ...react.configs.flat.recommended.languageOptions,
      globals: globals.browser,
    },
    settings: { react: { version: "detect" } },
  },
  {
    files: ["app/frontend/**/*.{js,jsx}"],
    ...react.configs.flat["jsx-runtime"],
  },
  {
    files: ["app/frontend/**/*.{js,jsx}"],
    plugins: { "react-hooks": reactHooks },
    rules: reactHooks.configs.recommended.rules,
  },
  {
    files: ["app/frontend/**/*.test.{js,jsx}"],
    languageOptions: { globals: { ...globals.browser, ...globals.jest, global: "readonly" } },
  },
  {
    files: ["*.cjs"],
    languageOptions: { sourceType: "commonjs", globals: globals.node },
  },
  {
    files: ["app/views/pwa/service-worker.js"],
    languageOptions: { globals: globals.serviceworker },
  },
  {
    // React 19 ignores propTypes at runtime and the project has no TypeScript (D9),
    // so this rule would demand declarations that nothing checks.
    rules: { "react/prop-types": "off" },
  },
  prettier,
]
