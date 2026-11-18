describe('30K Automotiva - autenticação', () => {
  beforeEach(() => {
    cy.visit('/')
    cy.ativarAcessibilidade()
  })

  it('cadastra, autentica e encerra a sessao do cliente', () => {
    const email = `cliente.cypress.${Date.now()}.${Math.floor(Math.random() * 1e9)}@example.com`
    const senha = 'senha123'
    const baseCpf = Array.from({ length: 9 }, () => Math.floor(Math.random() * 10))

    if (baseCpf.every((digito) => digito === baseCpf[0])) {
      baseCpf[8] = (baseCpf[8] + 1) % 10
    }

    const calcularDigito = (digitos, pesoInicial) => {
      const soma = digitos.reduce(
        (total, digito, indice) => total + digito * (pesoInicial - indice),
        0
      )
      const resto = soma % 11
      return resto < 2 ? 0 : 11 - resto
    }
    const primeiroDigito = calcularDigito(baseCpf, 10)
    const segundoDigito = calcularDigito([...baseCpf, primeiroDigito], 11)
    const cpf = [...baseCpf, primeiroDigito, segundoDigito].join('')

    cy.contains('Cadastrar').first().click()
    cy.preencherCampo('Nome completo', 'Cliente Cypress')
    cy.preencherCampo('E-mail', email)
    cy.preencherCampo('CPF', cpf)
    cy.preencherCampo('Senha', senha)
    cy.contains('[role="button"]', 'Criar cadastro').click()

    cy.contains('Cadastro criado. Faça login para continuar.').should('exist')
    cy.get('[aria-label="E-mail"]').clear()
    cy.get('[aria-label="Senha"]').clear()
    cy.preencherCampo('E-mail', email)
    cy.preencherCampo('Senha', senha)
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
