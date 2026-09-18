# Chess Challenges — escopo funcional

## Visão geral

Chess Challenges é um app mobile de aprendizado e prática de xadrez. O
conteúdo principal é local para que o jogador consiga estudar sem internet.
Internet é necessária apenas para capacidades remotas, como sincronização,
autenticação, anúncios e validação de compra.

## Modos disponíveis

- **Lições guiadas:** campanha com 100 fases distribuídas em 10 mundos, dicas,
  feedback sonoro e progressão linear;
- **Desafios por objetivo:** 30 fases com objetivo explícito, limite de jogadas
  e pontuação de até três estrelas;
- **Contra bot:** partidas com bot iniciante, intermediário e avançado;
- **2 jogadores local:** duas pessoas jogam no mesmo dispositivo.

## Regras comuns de xadrez

A biblioteca de regras valida movimentos legais, xeque, xeque-mate, empate,
roque, en passant e promoção. A UI nunca deve decidir legalidade manualmente:
ela consulta `ChessRulesService` e exibe os destinos retornados pelo serviço.

Cada modo controla seu próprio estado Riverpod. Ao sair, reiniciar ou trocar de
partida, uma geração nova invalida qualquer operação assíncrona antiga.

## Progresso e estatísticas

`PlayerProgress` é a fonte de verdade do progresso do jogador. Ele guarda:

- fases guiadas concluídas e ofensiva diária;
- estrelas por desafio de objetivo;
- partidas contra bot, vitórias, derrotas, empates e dificuldade;
- partidas locais e resultado por cor;
- timestamps para merge e sincronização.

O fluxo é local-first:

1. a alteração atualiza o estado em memória;
2. o snapshot é salvo no storage local;
3. a gravação remota é enfileirada e agrupada pelo snapshot mais recente;
4. falha de rede não interrompe a partida nem apaga o progresso local.

O merge remoto combina conquistas e maiores pontuações sem substituir uma
alteração local mais nova.

## Monetização

A edição Free exibe anúncios em pausas naturais, como depois de concluir uma
partida. A edição PRO remove anúncios e é verificada pelo fluxo de compra da
loja. O app não confia em um campo editável pelo cliente para conceder PRO.

O comportamento de anúncios é protegido por elegibilidade, intervalo mínimo e
checagem da edição atual. Durante desenvolvimento são usados IDs de teste.

## Conteúdo

Os puzzles e desafios ficam em assets locais e são carregados por data sources.
Novos conteúdos devem ser adicionados aos dados, não codificados dentro de
widgets. Para desafios por objetivo, cada fase deve definir pelo menos:

```json
{
  "level": 1,
  "fen": "posição inicial",
  "objective": "objetivo que o jogador precisa cumprir",
  "scoring": {
    "threeStarLimit": 2,
    "twoStarLimit": 3,
    "oneStarLimit": 4
  },
  "playerColor": "white"
}
```

O controlador calcula estrelas a partir das jogadas do jogador e só grava a
melhor pontuação obtida para a fase. Cada desafio tem três limites: atingir o
primeiro dá 3 estrelas, o segundo dá 2 e o terceiro dá 1. Fases de mate em 1
usam tentativas como métrica, porque a posição volta ao início depois de um
lance incorreto.

## Fora do escopo atual

- multiplayer online;
- ranking de amigos ou contas sociais obrigatórias;
- painel administrativo para editar fases remotamente;
- conquistas e notificações push;
- sincronização de partidas em andamento.

Esses itens podem ser adicionados sem reescrever a experiência principal,
desde que usem novos contratos de dados e não acoplem a UI ao backend.

## Critérios de qualidade

Antes de liberar uma versão, validar:

- `flutter analyze` sem avisos;
- `flutter test` passando;
- campanha e modos jogáveis sem internet;
- bot não bloqueia a UI enquanto calcula;
- sair ou reiniciar durante um cálculo não aplica movimento antigo;
- sincronização não perde uma atualização local;
- compra, restauração e anúncios usam IDs e contas de produção somente no
  build de release;
- textos e componentes continuam compatíveis com os idiomas suportados.
