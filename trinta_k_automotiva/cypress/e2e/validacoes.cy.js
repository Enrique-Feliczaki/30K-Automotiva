describe('30K Automotiva - Validacoes de Cadastro', () => {
  beforeEach(() => {
    cy.visit('/')
    cy.ativarAcessibilidade()
    cy.contains('Cadastrar').first().click()
  })

  it('QA-42 exige nome no cadastro vazio', () => {
    cy.contains('Criar cadastro').click()
    cy.contains('Informe seu nome').should('exist')
  })

  it('QA-43 exige email valido no cadastro vazio', () => {
    cy.contains('Criar cadastro').click()
    cy.contains('Informe um e-mail válido').should('exist')
  })

  it('QA-44 exige CPF valido no cadastro vazio', () => {
    cy.contains('Criar cadastro').click()
    cy.contains('Informe um CPF válido').should('exist')
  })

  it('QA-45 exige senha com no minimo seis caracteres', () => {
    cy.contains('Criar cadastro').click()
    cy.contains('A senha deve ter pelo menos 6 caracteres').should('exist')
  })

  it('QA-46 permite abrir a orientacao de recuperacao de senha', () => {
    cy.contains('Entrar').first().click()
    cy.contains('Esqueci minha senha').click()
    cy.contains('Entre em contato com o suporte para redefinir sua senha.')
      .should('exist')
  })
})
