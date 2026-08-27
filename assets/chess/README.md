# Chess Assets

Coloque aqui os assets exportados do Figma.

Use SVG sempre que possivel. Mantenha os nomes abaixo para o codigo conseguir carregar as imagens sem mapeamentos extras.

## Pecas

Pecas brancas:

```txt
assets/chess/pieces/white/king.svg
assets/chess/pieces/white/queen.svg
assets/chess/pieces/white/rook.svg
assets/chess/pieces/white/bishop.svg
assets/chess/pieces/white/knight.svg
assets/chess/pieces/white/pawn.svg
```

Pecas pretas:

```txt
assets/chess/pieces/black/king.svg
assets/chess/pieces/black/queen.svg
assets/chess/pieces/black/rook.svg
assets/chess/pieces/black/bishop.svg
assets/chess/pieces/black/knight.svg
assets/chess/pieces/black/pawn.svg
```

## Tabuleiro

O tabuleiro sera montado pelo Flutter como uma grid 8x8. Cada casa usa um SVG conforme a cor e o estado.

```txt
assets/chess/board/light_square.svg
assets/chess/board/dark_square.svg
assets/chess/board/light_selected_square.svg
assets/chess/board/dark_selected_square.svg
assets/chess/board/light_move_hint_square.svg
assets/chess/board/dark_move_hint_square.svg
```

Uso esperado:

- `light_square.svg`: casa clara normal.
- `dark_square.svg`: casa escura normal.
- `light_selected_square.svg`: casa clara com peca selecionada.
- `dark_selected_square.svg`: casa escura com peca selecionada.
- `light_move_hint_square.svg`: casa clara com movimento possivel.
- `dark_move_hint_square.svg`: casa escura com movimento possivel.

## Indicadores

Nao estamos usando `assets/chess/indicators/` no MVP atual.

Selecao e movimento possivel ficam em `assets/chess/board/`, porque esses estados ja sao SVGs de casa inteira. Se no futuro precisarmos de overlays separados, como erro, acerto, xeque ou setas de dica, podemos adicionar uma pasta especifica para isso.

## UI

Use `assets/chess/ui/` para elementos do app que nao sao parte direta do tabuleiro, como icones de streak, medalhas, mundos, capitulos e botoes especiais.
