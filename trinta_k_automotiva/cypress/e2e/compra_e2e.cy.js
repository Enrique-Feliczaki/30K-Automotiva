describe('30K Automotiva - compra', () => {
  beforeEach(() => {
    cy.visit('/')
    cy.ativarAcessibilidade()
  })

  it('adiciona um produto e conclui a compra pelo Pix', () => {
    const email = `comprador.cypress.${Date.now()}.${Math.floor(Math.random() * 1e9)}@example.org`
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
    cy.preencherCampo('Nome completo', 'Comprador Cypress')
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

    cy.contains('Shampoo Neutro Concentrado 1,5L').should('be.visible')
    cy.get('[role="button"]')
      .filter((_, button) => button.textContent.includes('Shampoo Neutro'))
      .first()
      .click()
    cy.contains('[role="button"]', 'Adicionar ao carrinho').click()
    cy.contains('Produto adicionado ao carrinho').should('exist')
    cy.contains('[role="button"]', 'Voltar').click()
    cy.contains('[role="button"]', 'Abrir sacola').click()
    cy.contains('Minha sacola').should('be.visible')
    cy.contains('1 item').should('exist')

    cy.contains('[role="button"]', 'Finalizar pedido').click()
    cy.preencherCampo('CEP', '85010000')
    cy.preencherCampo('Estado', 'PR')
    cy.preencherCampo('Cidade', 'Guarapuava')
    cy.preencherCampo('Bairro', 'Centro')
    cy.preencherCampo('Rua', 'Rua de Teste')
    cy.preencherCampo('Número', '100')
    cy.contains('[role="button"]', 'Continuar para o Pix').click()

    cy.contains('Tudo certo!').should('be.visible')
    cy.contains('[role="button"]', 'Entendi').click()
    cy.contains('Explorar produtos').should('be.visible')
    cy.contains('[role="button"]', 'Abrir sacola').click()
    cy.contains('Sua sacola está vazia').should('be.visible')
  })
})
