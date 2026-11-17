const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:8080',
    defaultCommandTimeout: 20000,
    pageLoadTimeout: 60000,
    video: false,
    screenshotOnRunFailure: true
  }
})
