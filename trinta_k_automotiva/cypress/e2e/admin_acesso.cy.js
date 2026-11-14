describe('30K Automotiva - Navegacao Administrativa', () => {
  beforeEach(() => {
    cy.visit('/')
    cy.ativarAcessibilidade()
    cy.contains('Entrar como administrador').click()
  })

  it('QA-122 abre o login administrativo', () => {
    cy.contains('Entrar admin').should('exist')
    cy.contains('Cadastrar empresa').should('exist')
    cy.contains('Acesso restrito à administração de produtos.').should('exist')
  })

  it('QA-123 abre cadastro de empresa', () => {
    cy.contains('Cadastrar empresa').click()
    cy.contains('Criar cadastro').should('exist')
    cy.contains('Cadastre a empresa administradora para liberar o acesso de gestão.')
      .should('exist')
  })

  it('QA-124 permite retornar ao login administrativo', () => {
    cy.contains('Cadastrar empresa').click()
    cy.contains('Entrar admin').click()
    cy.contains('Acesso restrito à administração de produtos.').should('exist')
  })

  it('QA-125 permite voltar ao login de cliente', () => {
    cy.contains('Voltar ao login de cliente').click()
    cy.contains('Entrar como administrador').should('exist')
    cy.contains('Esqueci minha senha').should('exist')
  })

  it('QA-126 cadastro de empresa vazio exibe validacao de CNPJ', () => {
    cy.contains('Cadastrar empresa').click()
    cy.contains('Criar cadastro').click()
    cy.contains('Informe um CNPJ válido').should('exist')
  })
})
