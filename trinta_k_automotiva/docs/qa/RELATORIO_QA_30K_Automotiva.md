# Relatório de QA - 30K Automotiva

**Data:** 09/11/2026  
**Projeto:** 30K Automotiva (Flutter/Dart)  
**Repositório:** https://github.com/Enrique-Feliczaki/30K-Automotiva  
**Responsável:** Equipe de QA / testes acadêmicos  
**Status:** Execução parcial concluída; testes de carrinho via Cypress e autenticação real pendentes.

## 1. Objetivo

Verificar comportamentos do aplicativo 30K Automotiva por meio de testes automatizados de unidade/estado/widget em Flutter e testes end-to-end na versão Web com Cypress, registrando resultados e limitações verificáveis.

## 2. Ambiente e ferramentas

- Flutter e Dart; testes via `flutter test --reporter expanded`.
- Cypress 16.2.1 e Chrome 156, execução headless por `npx cypress run --browser chrome`.
- Node.js v24.15.0 (conforme saída do terminal).
- Aplicativo Flutter Web disponibilizado em `http://localhost:8080`.
- Execuções realizadas pelo responsável no Windows, com resultados enviados no terminal.

## 3. Escopo e resultados consolidados

| Conjunto | Arquivos | Executados | Sem falha na execução | Observação |
| --- | --- | ---: | ---: | --- |
| Flutter | `cart_item_test.dart`, `cart_store_test.dart`, `product_store_test.dart`, `widget_test.dart` | 30 | 30 | Testes de lógica, estado, estoque e widgets. |
| Cypress - inicialização | `spec.cy.js` | 3 | 3 | Carregamento, acessibilidade e elementos. |
| Cypress - autenticação | `autenticacao.cy.js` | 6 | 6 | Tela inicial, navegação entre abas, acesso administrativo. |
| Cypress - validações | `validacoes.cy.js` | 7 | 7 | Cinco verificações funcionais; QA-40 e QA-41 apenas diagnósticos. |
| **Total** | | **46** | **46** | **Nem todas as 46 execuções equivalem a validações funcionais completas.** |

**Nota metodológica:** QA-40 e QA-41 passaram na última execução porque registram o texto acessível e capturam a tela, sem asserção sobre a mensagem específica de erro. Por isso, não se deve relatar que a validação automática de e-mail/senha vazios foi comprovada pelo Cypress.

## 4. Casos de teste abrangidos

**Flutter (QA-01 a QA-30):** cálculo e formatação de valores; cópia de itens; adicionar, atualizar e remover itens do carrinho; quantidade e subtotal; notificações de mudanças; cadastro, edição e remoção de produtos; estoque negativo, baixo e esgotado; contadores de produtos; renderização e navegação básica de telas.

**Cypress - interface e navegação (QA-31 a QA-39):** inicialização Web, ativação da camada de acessibilidade, renderização de elementos, abertura de login/cadastro, retorno ao login, permanência na tela de autenticação sem credenciais e presença de acesso administrativo.

**Cypress - validações (QA-40 a QA-46):** QA-40 e QA-41 são diagnósticos; QA-42 a QA-45 verificam mensagens de cadastro para nome/e-mail/CPF/senha; QA-46 verifica a orientação de recuperação de senha.

## 5. Ocorrências e investigação

**OC-01 - Testes de autenticação não encontravam o texto “E-mail”.** Na primeira execução de `autenticacao.cy.js`, três de seis casos falharam. A investigação indicou incompatibilidade entre a busca textual usada pelo Cypress e a exposição dos elementos pelo Flutter Web. Os seletores/assertivas foram ajustados para elementos acessíveis, e a execução posterior registrou seis de seis casos sem falhas. **Classificação:** problema da automação; não há evidência de defeito funcional no aplicativo.

**OC-02 - Verificações automáticas das mensagens de login vazio.** Na primeira execução de `validacoes.cy.js`, cinco testes passaram e dois falharam porque o Cypress não encontrou “Informe seu e-mail” e “Informe sua senha”. Uma verificação manual, acompanhada de captura de tela, confirmou que as duas mensagens aparecem visualmente após pressionar Entrar com os campos vazios. Os testes QA-40 e QA-41 foram temporariamente convertidos em diagnósticos, que passaram, mas ainda não validam automaticamente a mensagem. **Classificação:** lacuna de cobertura automatizada, sem defeito funcional confirmado.

## 6. Limitações e pendências

- Não foram executados fluxos Cypress autenticados de catálogo, compra, carrinho, pedidos ou painel administrativo.
- Não foram comprovados automaticamente login com credenciais reais, cadastro persistido nem integração com backend.
- Os casos QA-40 e QA-41 precisam voltar a ter assertivas específicas; evidência manual não substitui teste automático.
- Aprovação dos testes existentes não garante ausência de defeitos no software.

## 7. Evidências

- Saída do terminal de `flutter test --reporter expanded`: 30 testes aprovados.
- Saída do Cypress com `autenticacao.cy.js` e `spec.cy.js`: 9 de 9 aprovados.
- Última saída de `validacoes.cy.js`: 7 de 7 sem falhas; QA-40/41 diagnósticos.
- Capturas de tela em `cypress/screenshots/`, incluindo `qa-36-cadastro.png`, `qa-38-login-vazio.png`, `qa-40-validacao-email.png` e `qa-41-validacao-senha.png`.
- Captura manual da tela do login com mensagens “Informe seu e-mail” e “Informe sua senha”.

## 8. Conclusão

A etapa inicial de QA foi concluída com infraestrutura de testes Flutter e Cypress operacional. As execuções reportadas somam 46 casos sem falha na última versão de cada conjunto, mas dois deles são apenas diagnósticos. As ocorrências investigadas não demonstraram defeito funcional no login vazio; revelaram limitações de seletores e acessibilidade para automação no Flutter Web. Recomenda-se, como prioridade, automatizar assertivas reais das mensagens de login e ampliar a cobertura com cenários autenticados, carrinho, estoque e fluxos administrativos.
