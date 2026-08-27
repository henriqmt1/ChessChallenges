# Chess Chalenges

Aplicativo Flutter offline com 100 desafios progressivos de xadrez,
distribuídos em 10 mundos de dificuldade crescente.

## Guias do projeto

- [Padroes visuais e internacionalizacao](docs/app_standards.md)
- [Guia de assets](docs/assets.md)
- [Escopo do MVP](docs/mvp.md)
- [Modelo de dados dos puzzles](docs/puzzle_data_model.md)

## Comandos principais

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

## Edições

A edição Premium é a padrão. Para executar ou gerar a edição Free:

```bash
flutter run --dart-define=IS_PREMIUM=false
flutter build apk --dart-define=IS_PREMIUM=false
```
