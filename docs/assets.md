# Guia de Assets

Este projeto esta preparado para receber os SVGs do Figma em `assets/chess/`.

## Onde colocar cada coisa

```txt
assets/chess/pieces/white/     pecas brancas
assets/chess/pieces/black/     pecas pretas
assets/chess/board/            casas do tabuleiro e estados de movimento
assets/chess/ui/               icones e elementos visuais fora do tabuleiro
assets/puzzles/                base local de puzzles em JSON
```

## Nomes esperados

Pecas brancas:

```txt
king.svg
queen.svg
rook.svg
bishop.svg
knight.svg
pawn.svg
```

Pecas pretas usam os mesmos nomes dentro de `assets/chess/pieces/black/`.

Tabuleiro:

```txt
light_square.svg
dark_square.svg
light_selected_square.svg
dark_selected_square.svg
light_move_hint_square.svg
dark_move_hint_square.svg
```

Esses SVGs representam a casa inteira. O tabuleiro final sera montado no Flutter em uma grid 8x8, usando uma dessas imagens para cada posicao.

No modelo atual, selecao e movimento possivel ficam em `assets/chess/board/`, porque esses estados ja sao SVGs de casa inteira.

## Indicadores

Nao estamos usando `assets/chess/indicators/` no MVP atual.

Se no futuro precisarmos de camadas extras por cima da casa, como erro, acerto, xeque ou setas de dica, podemos recriar uma pasta para overlays.

## Observacoes para exportar do Figma

- Exporte as pecas como SVG.
- Mantenha a arte centralizada dentro do viewport do SVG.
- Use viewBox consistente entre as pecas, se possivel.
- Evite nomes com espaco, acento ou letras maiusculas.
- Se o Figma exportar com nomes longos, renomeie para os nomes deste guia.
