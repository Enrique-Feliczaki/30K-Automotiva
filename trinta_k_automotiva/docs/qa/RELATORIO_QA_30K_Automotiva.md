# Relatório de QA — 30K Automotiva

**Data da revisão:** 17/11/2026
**Escopo:** testes Flutter/Dart e Cypress da aplicação Web

## Resultado da reestruturação

A suíte principal ficou separada em três categorias executáveis de forma independente:

| Categoria | Casos principais | Local |
| --- | ---: | --- |
| Unitário | 2 | `test/unit/` |
| Integração | 2 | `test/integration/` |
| E2E | 2 | `cypress/e2e/` |

Os demais testes Flutter continuam como regressão complementar. Eles não são usados para inflar a contagem dos seis casos principais.

## Testes principais

### Unitários

- `test/unit/cart_store_test.dart`: adiciona, agrupa, altera e remove itens diretamente no `CartStore`, verificando quantidade e subtotal.
- `test/unit/product_store_test.dart`: verifica as regras que impedem SKU repetido e normalizam estoque negativo para zero.

Esses testes não constroem widgets nem usam navegador. As entradas são passadas diretamente às classes e as saídas são comparadas com valores específicos.

### Integração

- `test/integration/cart_state_integration_test.dart`: toca no botão de quantidade da `CartScreen` e confirma a mesma alteração no `CartStore`, no subtotal e nos textos da interface.
- `test/integration/checkout_integration_test.dart`: parte da sacola, abre `PaymentScreen`, preenche o endereço e confirma o pedido. Ao final verifica estoque, perfil, carrinho e diálogo de confirmação.

Os testes usam interações do `WidgetTester`; não chamam diretamente callbacks dos botões para substituir a ação do usuário.

### End-to-End

- `cypress/e2e/autenticacao_e2e.cy.js`: abre a aplicação, cadastra o cliente, faz login, acessa a conta, efetua logout e confirma o retorno à autenticação.
- `cypress/e2e/compra_e2e.cy.js`: cadastra e autentica um comprador, adiciona um produto real, abre a sacola, preenche o checkout Pix, conclui o pedido e confirma que a sacola ficou vazia.

Os dois casos usam o aplicativo Flutter Web real no Chrome e verificam resultados visíveis. As quatro especificações Cypress anteriores foram removidas porque eram verificações fragmentadas de carregamento, texto e validação; nenhuma percorria um fluxo completo.

## Auditoria dos testes complementares

| Arquivos | Classificação | Decisão |
| --- | --- | --- |
| `address_validation_test.dart`, `cart_item_test.dart`, `customer_profile_test.dart`, `email_validation_test.dart` | Unidade | Mantidos: regras isoladas e assertivas específicas. |
| `card_expiry_input_formatter_test.dart`, `document_input_formatter_test.dart` | Unidade | Mantidos: casos de edição e limites dos formatadores. |
| `registration_email_test.dart` | Unidade com criptografia local | Mantido para validar a barreira de persistência. |
| `cart_stock_test.dart` | Unidade e widget | Mantido: limites de estoque que não aparecem nos dois casos principais. |
| `local_database_test.dart` | Integração de persistência | Mantido como regressão técnica, separado da apresentação principal. |
| `auth_screen_test.dart`, `cart_screen_test.dart`, `payment_screen_test.dart` | Widget isolado | Mantidos para validações e estados de tela. Não são chamados de E2E. |
| `admin_screen_test.dart`, `admin_crud_test.dart`, `inventory_screen_test.dart` | Widget/integração de componente | Mantidos: CRUD e estoque administrativo. |
| `home_navigation_test.dart`, `home_search_test.dart` | Widget/integração de componente | Mantidos: navegação, busca e perfil. |
| `benefit_strip_test.dart`, `responsive_layout_test.dart` | Widget visual | Mantidos: regressão responsiva. |
| `product_description_test.dart`, `widget_test.dart` | Widget | Mantidos: detalhes do produto e entrada inicial do aplicativo. |

Quatro arquivos repetitivos de `CartStore` e `ProductStore` foram consolidados nos dois casos unitários principais. O teste antigo que chamava `onPressed` diretamente durante o checkout também foi removido; o novo caso percorre o fluxo pela interface.

## Defeito corrigido durante a revisão

A validação de e-mail aceitava apenas uma lista fechada de terminações. Isso confundia formato com existência de domínio e rejeitava TLDs sintaticamente válidos. A regra agora valida:

- uma parte local bem formada;
- rótulos de domínio sem hífens inválidos;
- pelo menos dois caracteres em cada rótulo anterior ao TLD;
- terminação completa presente na lista de sufixos aceitos pelo cadastro.

O endereço `cliente@e.com` e terminações inexistentes como `.come` são rejeitados, enquanto domínios completos com sufixos como `.com`, `.com.br`, `.co`, `.org` e `.dev` continuam válidos. A aplicação não afirma que o endereço existe; essa comprovação exigiria confirmação por e-mail.

## Comandos de execução

```powershell
flutter pub get
flutter test test/unit --reporter expanded
flutter test test/integration --reporter expanded
flutter test --reporter expanded
```

Para E2E, mantenha o servidor aberto no primeiro terminal:

```powershell
flutter run -d web-server --web-port 8080 --no-web-resources-cdn
```

Em outro terminal:

```powershell
npm install
npm run test:e2e
```

## Resultados de execução

Esta seção deve ser preenchida apenas com resultados efetivamente observados na versão atual:

| Execução | Aprovados | Falhas | Situação |
| --- | ---: | ---: | --- |
| Unitários principais | 2 | 0 | Aprovados |
| Integração principal | 2 | 0 | Aprovados |
| Suíte Flutter completa | 160 | 0 | Aprovada |
| Cypress no Chrome 157 | 2 | 0 | Aprovados em execução conjunta |

O servidor Web foi iniciado com `--no-web-resources-cdn` para servir o CanvasKit localmente. Sem essa opção, o ambiente de execução bloqueou a busca externa no Google CDN antes da inicialização do aplicativo; não era uma falha funcional dos fluxos.

`flutter analyze --no-pub` também foi executado. Não houve erro de compilação, mas o analisador encontrou 22 diagnósticos preexistentes de manutenção (20 informações e 2 avisos) em arquivos de produção, como uso legado não referenciado e parâmetro opcional não utilizado. Eles não impedem a execução dos testes e não foram alterados por estarem fora do escopo desta revisão.

## Limitações conhecidas

- O pagamento é simulado; o aplicativo confirma a preparação do Pix, não uma transação bancária real.
- Os dados são persistidos localmente no navegador e não são sincronizados com servidor remoto.
- A validação de formato de e-mail não comprova que a caixa postal existe.
