# Arquitetura

Chess Challenges usa uma organização por funcionalidade, com separação entre
domínio, dados e apresentação. A ideia é manter as regras de xadrez e de
progresso independentes da tela, para que novos modos possam reutilizar os
mesmos contratos.

## Estrutura

```text
lib/
  app/
    bot_game/
      domain/          regras, entidades e contratos do bot
      data/            execução do bot em isolate e providers de dados
      presentation/    páginas, estado e controladores Riverpod
    campaign/
    local_game/
    objective_challenges/
    progress/
    puzzles/
    home/
    faq/
    startup/
  core/
    config/            edição, versão e configuração de runtime
    l10n/               localização
    theme/              tokens e tema Material
  shared/
    chess/              regras, peças, tabuleiro e promoção
    feedback/           sons, toasts e feedback visual
    monetization/       anúncios, compra e oferta PRO
    widgets/             design system compartilhado
```

## Fluxo de estado

```text
Page
  -> Riverpod Notifier / AsyncNotifier
    -> domínio da funcionalidade
      -> repository ou data source
        -> storage local, Firebase ou asset local
```

As páginas coordenam navegação e efeitos visuais. Os ViewModels guardam estado
e regras de fluxo. Entidades e serviços de domínio não devem conhecer
widgets, textos traduzidos ou detalhes de armazenamento.

Na camada de apresentação, o padrão de nomenclatura é único: classes que
expõem estado e ações para a tela se chamam `*ViewModel`, e o estado imutável
fica em `*State`. `Notifier` e `AsyncNotifier` aparecem apenas como classes
base do Riverpod, não como nome da nossa abstração de tela.

## Decisões importantes

### Jogada do bot

O cálculo do bot é síncrono por natureza, mas é executado pelo contrato
`BotMoveCalculator`. A implementação de produção usa `compute` e transfere
apenas FEN, dificuldade e UCI de volta para a UI. Assim, uma busca mais pesada
não congela o tabuleiro.

O controlador valida geração da partida, FEN e turno depois de cada `await`.
Se o usuário reiniciar, sair da tela ou iniciar outra partida enquanto o bot
pensa, o resultado antigo é descartado.

### Progresso

O progresso é salvo primeiro localmente. Atualizações locais entram em uma
fila serializada e o envio remoto é agrupado pelo snapshot mais recente. Isso
evita duas gravações concorrentes sobrescreverem uma ação mais nova.

O Firebase é opcional para a experiência principal: sem conexão, campanha,
partidas e estatísticas locais continuam funcionando. Quando há usuário
autenticado/anônimo e rede, o repositório remoto tenta sincronizar o progresso.

### Design system

Tokens ficam em `core/theme/app_dimensions.dart` e `core/theme/app_colors.dart`.
Componentes compartilhados ficam em `shared/widgets/`:

- `AppPageFrame`: safe area, largura máxima e scroll padrão;
- `AppPageHeader`: cabeçalho secundário com voltar, título e ação opcional;
- `AppSurface`: superfície elevada com borda e raio consistentes;
- `AppPill`: etiquetas e estados compactos;
- `AppToolbarIconButton`: botão de toolbar com hit target e tooltip estáveis.

Novos componentes devem receber tokens do tema e evitar tamanhos ou cores
recorrentes definidos diretamente na página.

## Testes

Os testes cobrem regras de xadrez, controladores, fluxos de tela, progresso,
localização, monetização e componentes compartilhados. Antes de abrir um PR,
execute:

```bash
flutter analyze
flutter test
```

## Próximas evoluções técnicas

- adicionar testes de integração para compra, anúncios e sincronização real;
- criar uma camada de autenticação explícita quando login social entrar em
  produção;
- separar repositories remotos por contrato de domínio caso o backend cresça;
- adicionar observabilidade de falhas de sincronização e cálculo do bot.
