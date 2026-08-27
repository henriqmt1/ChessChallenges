# Padroes visuais e internacionalizacao

## Tipografia

O app usa Poppins em todas as plataformas. Os arquivos ficam em
`assets/fonts/poppins/` e os pesos sao declarados no `pubspec.yaml`.

## Design tokens

- Cores: `lib/core/theme/app_colors.dart`
- Espacamentos, raios, tamanhos e escala tipografica:
  `lib/core/theme/app_dimensions.dart`
- Configuracao global do Material: `lib/core/theme/app_theme.dart`

Novos componentes devem consumir esses tokens em vez de declarar cores e
tamanhos recorrentes diretamente.

## Internacionalizacao

Os catalogos ficam em `lib/l10n/`:

- `app_pt_BR.arb`: portugues brasileiro e arquivo-base
- `app_pt.arb`: fallback para dispositivos configurados somente como `pt`
- `app_en.arb`: ingles
- `app_es.arb`: espanhol

Depois de alterar qualquer ARB, execute:

```bash
flutter gen-l10n
```

Os arquivos `app_localizations*.dart` sao gerados e nao devem ser editados
manualmente. Widgets acessam strings por `context.l10n`. ViewModels devem
guardar estados ou enums, nunca frases traduzidas.
