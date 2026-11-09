
describe('30K Automotiva - Testes E2E', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('QA-31 - Deve carregar o aplicativo', () => {
    cy.get('flt-glass-pane', { timeout: 30000 })
      .should('exist')
  })

  it('QA-32 - Deve permitir ativar a acessibilidade', () => {
    cy.get('flt-semantics-placeholder', {
      timeout: 30000
    }).then(($elemento) => {
      $elemento[0].click()
    })

    cy.get('flt-semantics-host')
      .should('exist')
  })

  it('QA-33 - Deve mostrar elementos da interface', () => {
    cy.get('flt-semantics-placeholder', {
      timeout: 30000
    }).then(($elemento) => {
      $elemento[0].click()
    })

    cy.get('flt-semantics-host')
      .find('flt-semantics')
      .should('have.length.greaterThan', 0)
  })
})
