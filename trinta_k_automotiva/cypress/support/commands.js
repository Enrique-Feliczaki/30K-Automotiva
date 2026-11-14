Cypress.Commands.add('ativarAcessibilidade', () => {
  cy.get('flt-glass-pane', { timeout: 30000 }).should('exist')
  cy.get('body').then(($body) => {
    if ($body.find('flt-semantics-placeholder').length) {
      cy.get('flt-semantics-placeholder').then(($elemento) => {
        $elemento[0].click()
      })
    }
  })
  cy.get('flt-semantics-host', { timeout: 15000 }).should('exist')
})
