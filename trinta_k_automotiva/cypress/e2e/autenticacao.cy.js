
describe('30K Automotiva - Login e Cadastro', () => {
  const ativarAcessibilidade = () => {
    cy.get('flt-glass-pane', { timeout: 30000 })
      .should('exist')

    cy.get('body').then(($body) => {
      if ($body.find('flt-semantics-placeholder').length) {
        cy.get('flt-semantics-placeholder').then(($elemento) => {
          $elemento[0].click()
        })
      }
    })

    cy.get('flt-semantics-host', { timeout: 10000 })
      .should('exist')
  }

  beforeEach(() => {
    cy.visit('/')
    ativarAcessibilidade()
  })

  it('QA-34 - Exibe a tela de login', () => {
    cy.contains('30K AUTOMOTIVA').should('exist')
    cy.contains('Esqueci minha senha').should('exist')
    cy.contains('Entrar como administrador').should('exist')
  })

  it('QA-35 - Exibe a opcao de cadastro', () => {
    cy.contains('Cadastrar').should('be.visible')
  })

  it('QA-36 - Permite selecionar a aba de cadastro', () => {
    cy.contains('Cadastrar').first().click()

    cy.contains('Esqueci minha senha')
      .should('not.exist')

    cy.screenshot('qa-36-cadastro')
  })

  it('QA-37 - Permite voltar para a aba de login', () => {
    cy.contains('Cadastrar').first().click()

    cy.contains('Esqueci minha senha')
      .should('not.exist')

    cy.contains('Entrar').first().click()

    cy.contains('Esqueci minha senha')
      .should('exist')
  })

  it('QA-38 - Mantem a autenticacao com login vazio', () => {
    cy.contains('Entrar').last().click()

    cy.contains('30K AUTOMOTIVA')
      .should('exist')

    cy.contains('Esqueci minha senha')
      .should('exist')

    cy.screenshot('qa-38-login-vazio')
  })

  it('QA-39 - Exibe a opcao de acesso administrativo', () => {
    cy.contains('Entrar como administrador')
      .should('be.visible')
  })
})
