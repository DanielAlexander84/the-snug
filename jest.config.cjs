// Component tests (D7). Jest does not use the Vite build, so the JSX
// transform is configured here and nowhere else.
module.exports = {
  testEnvironment: "jsdom",
  roots: ["<rootDir>/app/frontend"],
  testMatch: ["**/*.test.jsx"],
  setupFilesAfterEnv: ["@testing-library/jest-dom"],
  transform: {
    "\\.jsx?$": [
      "babel-jest",
      {
        babelrc: false,
        configFile: false,
        presets: [
          ["@babel/preset-env", { targets: { node: "current" } }],
          ["@babel/preset-react", { runtime: "automatic" }],
        ],
      },
    ],
  },
}
