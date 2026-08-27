# Chess Chalenges - Documento do MVP

## Visao geral

O MVP sera um app Flutter offline de desafios de xadrez em formato de campanha, inspirado em progresso diario estilo Duolingo. O usuario avanca por fases, resolve puzzles curtos de 1 a 3 jogadas e mantem uma sequencia diaria ao completar pelo menos uma fase por dia.

O app nao tera login, backend, ranking online ou Firebase no primeiro momento. Toda a experiencia inicial deve funcionar sem internet.

## Objetivo do MVP

Validar se a experiencia principal e divertida e clara:

- abrir o app;
- ver o mapa de fases;
- entrar em uma fase desbloqueada;
- resolver uma sequencia curta de xadrez;
- receber feedback imediato;
- avancar no progresso;
- manter uma meta diaria.

## Escopo fechado

O MVP tera:

- campanha offline com fases;
- base local de puzzles;
- desafios de 1 a 3 jogadas do usuario;
- resposta automatica do adversario com lances pre-salvos;
- erro imediato caso o usuario faca qualquer lance incorreto;
- reinicio da fase apos erro;
- ajuda/ver solucao;
- progresso local;
- streak diaria;
- notificacao local se o usuario ainda nao concluiu uma fase no dia;
- design baseado nos assets do Figma fornecido.

## Fora do escopo inicial

O MVP nao tera:

- login;
- Firebase;
- ranking online;
- multiplayer;
- modo contra computador;
- engine Stockfish;
- puzzles baixados dinamicamente;
- sincronizacao entre dispositivos;
- loja, assinatura ou monetizacao;
- painel admin.

Esses pontos podem entrar depois que a experiencia principal estiver validada.

## Modelo de jogo

Cada fase contem um puzzle de xadrez. O usuario controla apenas o lado que esta resolvendo.

Fluxo de uma fase:

1. O app carrega uma posicao inicial em FEN.
2. O usuario tenta o primeiro lance correto.
3. Se o lance estiver errado, a fase entra em estado de erro.
4. Se o lance estiver certo, o app aplica o lance.
5. Se houver resposta do adversario, o app executa automaticamente o proximo lance salvo.
6. O fluxo continua ate o usuario completar todos os lances dele.
7. Ao concluir a sequencia inteira sem erro, a fase e marcada como concluida.

Exemplo de puzzle de 3 jogadas do usuario:

```txt
Usuario joga lance 1
App joga resposta 1
Usuario joga lance 2
App joga resposta 2
Usuario joga lance 3
Fase concluida
```

Se o usuario errar qualquer lance, inclusive o primeiro, o desafio falha imediatamente e deve mostrar acao para tentar de novo.

## Ajuda

O MVP tera ajuda simples, sem sistema complexo de dicas.

Comportamentos esperados:

- antes do erro, pode existir botao de ajuda;
- a ajuda pode destacar a peca correta ou mostrar uma dica textual curta;
- apos erro, o usuario pode ver a solucao;
- ver a solucao nao deve contar como conclusao perfeita da fase;
- a fase so conta como concluida quando o usuario executar a sequencia correta.

A regra exata de recompensa ao usar ajuda pode ser ajustada depois. Para o MVP, a prioridade e clareza.

## Progresso e campanha

A campanha sera composta por uma trilha de fases. Para o MVP, a progressao pode ser linear por baixo, mesmo que o visual mostre ramificacoes.

Estrutura sugerida:

```txt
10 mundos
10 capitulos por mundo
10 fases por capitulo
= 1000 fases
```

Na primeira entrega jogavel, podemos usar menos fases reais e manter a estrutura pronta para expandir.

Regras:

- o usuario comeca na fase 1;
- concluir uma fase desbloqueia a proxima;
- fases concluidas podem ser repetidas;
- repetir fase ja concluida nao deve duplicar recompensa diaria;
- uma fase so conta como concluida se a sequencia for resolvida corretamente.

## Meta diaria e streak

A meta diaria do usuario sera completar pelo menos uma fase por dia.

Regras:

- ao completar a primeira fase do dia, a streak do dia e garantida;
- completar varias fases no mesmo dia avanca a campanha normalmente;
- a streak so aumenta uma vez por dia;
- se o usuario passar um dia sem concluir fase, a streak e quebrada;
- todos os dados ficam salvos localmente no dispositivo.

## Notificacoes

O MVP usara notificacoes locais, sem servidor.

Regra inicial:

- se o usuario ainda nao concluiu uma fase no dia, o app pode lembrar em um horario configurado;
- horario padrao sugerido: 19h;
- a notificacao deve ser simples e ligada a manutencao da sequencia diaria.

Exemplo de texto:

```txt
Sua sequencia esta em jogo. Complete uma fase hoje.
```

## Base de puzzles

O app usara uma base local em JSON. Podemos montar essa base a partir de puzzles proprios ou de uma fonte livre, como a base de puzzles do Lichess, que e distribuida como CC0.

Para o MVP, a base local deve conter apenas puzzles ja filtrados e prontos para uso.

Campos sugeridos:

```json
{
  "id": "mate-001",
  "fen": "posicao inicial em FEN",
  "moves": ["e2e4", "e7e5", "g1f3"],
  "playerMoveIndexes": [0, 2],
  "sideToMove": "w",
  "theme": "mateIn2",
  "difficulty": 1,
  "world": 1,
  "chapter": 1,
  "level": 1
}
```

Observacao: se usarmos puzzles do Lichess, a preparacao precisa respeitar o formato da base. Em muitos casos, o primeiro lance da solucao e o lance que chega na posicao do desafio, entao a importacao deve transformar os dados para o formato usado pelo app.

## Arquitetura tecnica

O projeto sera Flutter com MVVM e Clean Architecture.

Padrao de fluxo:

```txt
Page -> ViewModel -> UseCase -> Repository -> DataSource
```

Estrutura sugerida:

```txt
lib/
  core/
    constants/
    errors/
    routing/
    storage/
    theme/
    utils/

  features/
    campaign/
      domain/
        entities/
        repositories/
        usecases/
      data/
        datasources/
        models/
        repositories/
      presentation/
        pages/
        viewmodels/
        widgets/

    puzzles/
      domain/
        entities/
        repositories/
        usecases/
      data/
        datasources/
        models/
        repositories/
      presentation/
        pages/
        viewmodels/
        widgets/

    progress/
      domain/
      data/
      presentation/

    notifications/
      domain/
      data/
      presentation/

  shared/
    chess/
    widgets/
```

## Estado e dependencias sugeridas

Decisoes tecnicas recomendadas:

- Riverpod para estado e injecao de dependencias;
- biblioteca de xadrez em Dart para validar movimentos, FEN, roque, promocao e xeque;
- storage local para progresso e configuracoes;
- assets locais para puzzles e pecas;
- notificacoes locais para lembrete diario.

Nao devemos implementar regras completas de xadrez manualmente.

## Telas do MVP

Telas principais:

- splash/loading simples;
- mapa de fases;
- tela de puzzle;
- estado de erro;
- estado de conclusao;
- tela/modal de ajuda;
- configuracao simples de notificacao, se necessario.

## Design

O design deve seguir o Figma fornecido, especialmente:

- tabuleiro com casas claras e azuladas;
- pecas escuras e claras com contorno consistente;
- destaque roxo para movimentos possiveis, selecao e feedback;
- coordenadas do tabuleiro quando fizer sentido;
- visual limpo, mobile-first e direto ao jogo.

O app deve abrir no produto em si, nao em landing page.

## Criterios de aceite do MVP

O MVP esta pronto quando:

- o app abre sem internet;
- o usuario consegue ver a trilha de fases;
- o usuario consegue abrir uma fase;
- o tabuleiro renderiza corretamente a posicao FEN;
- o usuario consegue mover pecas;
- lances corretos avancam a sequencia;
- lances errados mostram erro e permitem reiniciar;
- o adversario executa automaticamente lances pre-salvos;
- a fase conclui ao final da sequencia correta;
- o progresso local e salvo;
- a streak diaria funciona;
- a notificacao local pode lembrar o usuario;
- o visual base segue o Figma.

## Proximos passos

1. Ajustar dependencias do Flutter.
2. Criar a estrutura Clean Architecture + MVVM.
3. Implementar design system base.
4. Criar entidades e modelos de puzzle.
5. Adicionar uma base pequena de puzzles locais.
6. Implementar tela de puzzle e validacao da sequencia.
7. Implementar mapa de fases e progresso local.
8. Implementar streak e notificacao local.
9. Testar fluxo completo do MVP.
