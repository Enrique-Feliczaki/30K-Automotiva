describe('30K Automotiva - Navegacao Administrativa', () => {
  beforeEach(() => {
    cy.visit('/')
    cy.ativarAcessibilidade()
    cy.contains('Entrar como administrador').click()
  })

  it('QA-122 abre o login administrativo', () => {
    cy.contains('Entrar admin').should('exist')
    cy.contains('Cadastrar empresa').should('not.exist')
    cy.contains('CNPJ').should('exist')
    cy.contains('Acesso restrito à administração de produtos.').should('exist')
  })

  it('QA-123 nao oferece cadastro administrativo', () => {
    cy.contains('Criar cadastro').should('not.exist')
    cy.contains('Cadastrar empresa').should('not.exist')
  })

  it('QA-124 permite retornar ao login administrativo', () => {
    cy.contains('Voltar ao login de cliente').click()
    cy.contains('Entrar como administrador').click()
    cy.contains('Acesso restrito à administração de produtos.').should('exist')
  })

  it('QA-125 permite voltar ao login de cliente', () => {
    cy.contains('Voltar ao login de cliente').click()
    cy.contains('Entrar como administrador').should('exist')
    cy.contains('Esqueci minha senha').should('exist')
  })

  it('QA-126 login administrativo vazio exige CNPJ e senha', () => {
    cy.contains('[role="button"]', /^Entrar$/).click()
    cy.contains('Informe seu CNPJ').should('exist')
    cy.contains('Informe sua senha').should('exist')
  })
})
