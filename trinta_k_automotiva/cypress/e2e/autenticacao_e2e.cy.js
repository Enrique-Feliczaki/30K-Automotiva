describe('30K Automotiva - autenticação', () => {
  beforeEach(() => {
    cy.visit('/')
    cy.ativarAcessibilidade()
  })

  it('cadastra, autentica e encerra a sessao do cliente', () => {
    cy.contains('Cadastrar').first().click()
    cy.preencherCampo('Nome completo', 'Cliente Cypress')
    cy.preencherCampo('E-mail', 'cliente.cypress@example.com')
    cy.preencherCampo('CPF', '52998224725')
    cy.preencherCampo('Senha', 'senha123')
    cy.contains('[role="button"]', 'Criar cadastro').click()

    cy.contains('Cadastro criado. Faça login para continuar.').should('exist')
    cy.get('[role="button"]')
      .filter((_, button) => button.textContent.trim() === 'Entrar')
      .last()
      .click()
    cy.contains('Explorar produtos').should('be.visible')

    cy.get('[aria-label*="Conta"]').last().click()
    cy.contains('Minha conta').should('be.visible')
    cy.contains('[role="button"]', 'Sair da conta').click()
    cy.contains('Esqueci minha senha').should('be.visible')
  })
})
