# Chess Challenges

Aplicativo Flutter mobile-first para aprender e praticar xadrez com lições
guiadas, desafios por objetivo, partidas contra bot e partidas locais para
dois jogadores. A campanha e os exercícios principais funcionam offline;
Firebase, anúncios e sincronização entram como capacidades opcionais.

## Documentação

- [Arquitetura](docs/architecture.md)
- [Padrões visuais e internacionalização](docs/app_standards.md)
- [Guia de assets](docs/assets.md)
- [Escopo funcional](docs/mvp.md)
- [Modelo de dados dos puzzles](docs/puzzle_data_model.md)
- [Monetização](docs/MONETIZATION.md)

## Desenvolvimento

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

O projeto usa Riverpod para estado e injeção de dependências, assets locais
para conteúdo de xadrez e tokens compartilhados em `lib/core/theme`.

## Edições

A edição Premium é a padrão. Para executar ou gerar a edição Free:

```bash
flutter run --dart-define=IS_PREMIUM=false
flutter build apk --dart-define=IS_PREMIUM=false
```

## Firebase

As configurações nativas do Firebase identificam o app mobile e podem ficar
associadas ao projeto. Segredos de servidor, chaves privadas e credenciais de
produção nunca devem entrar no repositório. O app continua inicializando sem
Firebase; nesse caso o progresso fica local e anúncios/sincronização são
desativados conforme a configuração disponível.

## Qualidade

Toda mudança deve passar por `flutter analyze` e `flutter test`. Para mudanças
de estado assíncrono, adicione um teste que cubra cancelamento, atualização
fora de ordem ou erro da dependência quando aplicável.
