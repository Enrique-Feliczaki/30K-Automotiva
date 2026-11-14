describe('30K Automotiva - Login e Cadastro', () => {
  beforeEach(() => {
    cy.visit('/')
    cy.ativarAcessibilidade()
  })

  it('QA-34 exibe a tela de login', () => {
    cy.contains('30K AUTOMOTIVA').should('exist')
    cy.contains('Esqueci minha senha').should('exist')
    cy.contains('Entrar como administrador').should('exist')
  })

  it('QA-35 exibe a opcao de cadastro', () => {
    cy.contains('Cadastrar').should('be.visible')
  })

  it('QA-36 permite abrir o cadastro', () => {
    cy.contains('Cadastrar').first().click()
    cy.contains('TIPO DE CADASTRO').should('exist')
    cy.contains('Criar cadastro').should('exist')
  })

  it('QA-37 permite voltar do cadastro para o login', () => {
    cy.contains('Cadastrar').first().click()
    cy.contains('Esqueci minha senha').should('not.exist')
    cy.contains('Entrar').first().click()
    cy.contains('Esqueci minha senha').should('exist')
  })

  it('QA-38 impede navegacao ao tentar login vazio', () => {
    cy.contains('Entrar').last().click()
    cy.contains('30K AUTOMOTIVA').should('exist')
    cy.contains('Esqueci minha senha').should('exist')
    cy.contains('Entrar como administrador').should('exist')
  })

  it('QA-39 mostra entrada administrativa', () => {
    cy.contains('Entrar como administrador').should('be.visible')
  })
})
