describe('30K Automotiva - Inicializacao', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('QA-31 carrega o aplicativo Flutter Web', () => {
    cy.get('flt-glass-pane', { timeout: 30000 }).should('exist')
  })

  it('QA-32 ativa a acessibilidade', () => {
    cy.ativarAcessibilidade()
    cy.get('flt-semantics-host').should('exist')
  })

  it('QA-33 mostra o titulo na interface', () => {
    cy.ativarAcessibilidade()
    cy.contains('30K AUTOMOTIVA').should('exist')
  })
})
