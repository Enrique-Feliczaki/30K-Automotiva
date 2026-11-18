## unitários

flutter test test/unit/cart_store_test.dart
flutter test test/unit/product_store_test.dart

## integração

flutter test test/integration/cart_state_integration_test.dart
flutter test test/integration/checkout_integration_test.dart

## Suíte completa

flutter test

flutter test --reporter expanded

## end-to-end

1. terminal: flutter run -d web-server --web-port 8080 --no-web-resources-cdn
2. terminal:
npx cypress run --browser chrome --spec "cypress/e2e/autenticacao_e2e.cy.js"
npx cypress run --browser chrome --spec "cypress/e2e/compra_e2e.cy.js"

## cypress visual

npx cypress open