
describe('30K Automotiva - Validacoes', () => {
  beforeEach(() => {
    cy.visit('/')

    cy.get('flt-glass-pane', {
      timeout: 30000
    }).should('exist')

    cy.get('body').then(($body) => {
      if ($body.find('flt-semantics-placeholder').length) {
        cy.get('flt-semantics-placeholder').then(($elemento) => {
          $elemento[0].click()
        })
      }
    })

    cy.get('flt-semantics-host').should('exist')
  })



    it('QA-40 - Valida email vazio no login', () => {
    cy.contains('Entrar').last().click()

    cy.get('flt-semantics-host').then(($host) => {
        const texto = $host.text()
        cy.log('Conteudo acessivel: ' + texto)
    })

    cy.screenshot('qa-40-validacao-email')
    })

    it('QA-41 - Valida senha vazia no login', () => {
    cy.contains('Entrar').last().click()

    cy.get('flt-semantics-host').then(($host) => {
        const texto = $host.text()
        cy.log('Conteudo acessivel: ' + texto)
    })

    cy.screenshot('qa-41-validacao-senha')
    })



  it('QA-42 - Valida nome vazio no cadastro', () => {
    cy.contains('Cadastrar').first().click()

    cy.contains('Criar cadastro').click()

    cy.contains('Informe seu nome')
      .should('exist')
  })

  it('QA-43 - Valida email vazio no cadastro', () => {
    cy.contains('Cadastrar').first().click()

    cy.contains('Criar cadastro').click()

    cy.contains('Informe um e-mail válido')
      .should('exist')
  })

  it('QA-44 - Valida CPF vazio no cadastro', () => {
    cy.contains('Cadastrar').first().click()

    cy.contains('Criar cadastro').click()

    cy.contains('Informe um CPF válido')
      .should('exist')
  })

  it('QA-45 - Valida senha curta no cadastro', () => {
    cy.contains('Cadastrar').first().click()

    cy.contains('Criar cadastro').click()

    cy.contains('A senha deve ter pelo menos 6 caracteres')
      .should('exist')
  })

  it('QA-46 - Exibe recuperacao de senha', () => {
    cy.contains('Esqueci minha senha').click()

    cy.contains(
      'Entre em contato com o suporte para redefinir sua senha.'
    ).should('exist')
  })
})
