# trinta_k_automotiva

## Testar o banco local no navegador

Dentro desta pasta, execute `flutter run` e selecione Chrome (ou execute
`flutter run -d chrome`). O arquivo `web_dev_config.yaml` configura automaticamente
o endereço `http://localhost:7357`, mantendo a mesma origem do banco entre execuções.
Essa configuração requer Flutter 3.38 ou superior.

Use sempre o mesmo navegador. O Chrome aberto pelo Flutter usa um perfil de
desenvolvimento, separado do seu Chrome habitual; os cadastros desses perfis
não são compartilhados. Encerre normalmente com `q` para permitir que o Flutter
guarde o perfil de desenvolvimento. `flutter clean` remove esse perfil em
`.dart_tool/chrome-device`, incluindo os dados locais dele.

Evite passar outra porta com `--web-port`, pois isso substitui a configuração
do projeto e abre outro armazenamento. Os dados continuam locais e podem ser
removidos ao limpar os dados do navegador.

Para usar seu navegador habitual, o script abaixo continua disponível:

No PowerShell, dentro desta pasta, execute:

```powershell
.\run_web.ps1
```

Abra `http://localhost:7357` sempre no mesmo navegador e perfil, sem modo
anônimo. O script usa endereço e porta fixos.

O SQLite da versão web é armazenado no navegador, separado por origem
(protocolo, host e porta) e perfil. Executar com outra porta
pode abrir outra origem e parecer perder os cadastros. Limpar os dados do
site também remove o banco. Os dados ainda não são sincronizados com a nuvem.

Para conferir a persistência, cadastre uma conta nesse endereço, pare o
servidor com `q`, execute o script novamente e faça login na mesma URL e perfil.
Cadastros de portas ou perfis anteriores não são migrados automaticamente.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
