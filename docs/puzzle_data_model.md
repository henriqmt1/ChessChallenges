# Modelo JSON da campanha

A campanha offline jogável fica em:

```txt
assets/puzzles/campaign_v1.json
```

## Estrutura atual

```txt
10 mundos
10 fases por mundo
= 100 fases jogáveis
```

Os mundos seguem três faixas de dificuldade:

- mundos 1 a 3: fácil;
- mundos 4 a 7: médio;
- mundos 8 a 10: avançado.

A quantidade de jogadas do jogador cresce ao longo da campanha:

- 51 fases de uma jogada;
- 33 fases de duas jogadas;
- 16 fases de três jogadas.

## Regra das jogadas

As jogadas usam formato UCI. `moves` guarda a sequência completa, incluindo
as respostas automáticas do adversário, e `playerMoveIndexes` identifica as
jogadas do usuário.

```json
{
  "moves": ["e5f7", "h8g8", "f7d8"],
  "playerMoveIndexes": [0, 2]
}
```

## Geração e validação

O gerador cria as 100 fases a partir de exercícios-base, aplicando simetrias
de tabuleiro e inversões de cores. Antes de salvar, ele reproduz todas as
jogadas usando a mesma biblioteca de xadrez do app e interrompe se encontrar
qualquer lance ilegal.

```bash
dart run tool/generate_campaign.dart
flutter test test/campaign_content_test.dart
```
