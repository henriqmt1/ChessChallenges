# Chess Challenges

<p align="center">
  Um app mobile-first para aprender, praticar e jogar xadrez em sessões curtas.
</p>

<p align="center">
  <a href="https://github.com/henriqmt1/ChessChallenges/actions/workflows/ci.yml">
    <img src="https://github.com/henriqmt1/ChessChallenges/actions/workflows/ci.yml/badge.svg" alt="CI">
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/license-see%20LICENSE-lightgrey" alt="License">
</p>

O Chess Challenges combina lições guiadas, desafios por objetivo e partidas
livres em uma experiência simples e progressiva. O conteúdo principal é local,
permitindo jogar offline; Firebase, anúncios e compras entram como capacidades
complementares.

## Funcionalidades

- Lições guiadas organizadas por mundos e fases.
- Desafios por objetivo com estrelas e limite de jogadas.
- Partidas contra bot em três níveis de dificuldade.
- Modo local para dois jogadores no mesmo aparelho.
- Progresso, estatísticas e ofensiva diária.
- Tema claro e escuro com design system compartilhado.
- Anúncios interstitial na edição Free.
- Edição Premium para remover anúncios.
- Integração preparada para Firebase e sincronização de progresso.

## Começando

Requisitos:

- Flutter SDK instalado.
- Android Studio para Android ou Xcode para iOS.
- Um dispositivo físico ou emulador configurado.

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

O projeto usa Riverpod para estado e injeção de dependências, conteúdo local
para os exercícios e tokens compartilhados em `lib/core/theme`.

## Free e Premium

A edição **Free é o padrão**. Ela representa o comportamento real esperado para
produção: possui anúncios em pausas naturais e libera o conteúdo seguindo a
progressão normal.

A edição **Premium** remove os anúncios após uma compra válida. A flag abaixo
serve apenas para testes internos e não substitui a validação da loja:

```bash
# Free — padrão
flutter run --dart-define=FORCE_PREMIUM=false

# Premium — simulação interna
flutter run --dart-define=FORCE_PREMIUM=true
```

Para gerar um APK de teste:

```bash
flutter build apk --debug --dart-define=FORCE_PREMIUM=false
```

Em produção, o estado Premium deve ser determinado pela compra ou restauração
da compra, não por uma flag embutida no aplicativo.

## Anúncios

Durante o desenvolvimento, os anúncios de teste podem ser usados com:

```bash
flutter run \
  --dart-define=ENABLE_ADS=true \
  --dart-define=USE_TEST_ADS=true
```

Os IDs de produção são fornecidos somente no build de release:

```bash
flutter build apk --release \
  --dart-define=ENABLE_ADS=true \
  --dart-define=USE_TEST_ADS=false \
  --dart-define=ADMOB_INTERSTITIAL_ANDROID=SEU_ID_ANDROID
```

Nunca use anúncios reais durante os testes locais. O aplicativo limita a
frequência dos anúncios e não interrompe uma partida em andamento.

## Firebase

O Firebase é usado como suporte para autenticação, sincronização de progresso,
Remote Config e futuras validações de versão. O app continua funcionando sem
conexão para o conteúdo local; a internet é necessária para sincronização,
compras, atualizações remotas e carregamento de anúncios.

Arquivos nativos como `google-services.json` e `GoogleService-Info.plist`
identificam os aplicativos mobile. Segredos de servidor, chaves privadas,
certificados de assinatura e credenciais de produção nunca devem ser enviados
ao repositório.

## Organização do projeto

```text
lib/
├── app/        # Funcionalidades e telas organizadas por domínio
├── core/       # Configuração, tema, async, localização e infraestrutura
└── shared/     # Xadrez, monetização, feedback e componentes reutilizáveis

test/           # Testes unitários, de widgets e de fluxo
docs/           # Arquitetura, padrões, MVP e decisões do produto
```

Na camada de apresentação, o padrão é consistente:

- `FeatureViewModel`: estado e ações da tela.
- `FeatureState`: estado imutável exposto para a interface.
- `featureViewModelProvider`: entrada do Riverpod para a tela.
- Serviços e repositórios: regras e acesso a dados fora da UI.

## Qualidade

Antes de abrir um pull request, rode:

```bash
dart format lib test
flutter analyze
flutter test --concurrency=1
```

O GitHub Actions executa análise estática e testes automaticamente em cada
push e pull request.

## Documentação

- [Arquitetura](docs/architecture.md)
- [Padrões visuais e internacionalização](docs/app_standards.md)
- [Guia de assets](docs/assets.md)
- [Escopo funcional](docs/mvp.md)
- [Modelo de dados dos puzzles](docs/puzzle_data_model.md)
- [Monetização](docs/MONETIZATION.md)

## Estado do projeto

O núcleo jogável está implementado. As próximas etapas são validações de
release nas lojas, configuração definitiva de anúncios e compras, revisão das
regras do Firebase e publicação das novas fases.

Consulte o arquivo [LICENSE](LICENSE) para os termos de uso do projeto.
