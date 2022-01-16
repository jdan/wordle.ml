## wordle.ml

Cheating at [Wordle](https://www.powerlanguage.co.uk/wordle/) with OCaml.

### usage

Grab dependencies from [opam](https://opam.ocaml.org)

```sh
opam install dune ppx_inline_test
```

Modify the `rules` list in `bin/main.ml`. Then run:

```sh
cat words.txt | dune exec bin/main.exe | head
# upeat 71385
# cheat 69860
# theca 69860
# thema 68635
# wheat 65555
# tweag 64450
# tweak 63350
# theat 59228
# theta 59228
# theah 54996
```

These candidates are sorted by a very rough heuristic:
* For each letter, add the number of times that letter appears in any word
* Multiply by the number of unique letters (more letters means more clues!)

### results

It works okay! I cheated on day 197 starting with "SIREN"

> Wordle 197 3/6
>
> 🟨⬛⬛⬛⬛<br>
> ⬛⬛⬛🟨🟨<br>
> 🟩🟩🟩🟩🟩<br>

### example

Let's image we have the word "CHEAT."

Set `rules` to `[]` and run:

```sh
cat words.txt | dune exec bin/main.exe | head
# aeros 139565
# arose 139565
# soare 139565
# aesir 136170
# arise 136170
# raise 136170
# reais 136170
# serai 136170
# aloes 135630
# stoae 135250
```

Manually computing this, "AROSE" would get a pattern of 🟨⬛⬛⬛🟨. Modify `rules` accordingly and re-run:

```ocaml
let rules =
  [ ("arose", [Yellow; Black; Black; Black; Yellow])
  ]
```

```sh
cat words.txt | dune exec bin/main.exe | head
# telia 115385
# elain 113670
# entia 113290
# tenia 113290
# tinea 113290
# laten 111350
# leant 111350
# eliad 111175
# ideal 111175
# lutea 109145
```

TELIA corresponds to a pattern of 🟨🟨⬛⬛🟨.

```ocaml
let rules =
  [ ("arose", [Yellow; Black; Black; Black; Yellow])
  ; ("telia", [Yellow; Yellow; Black; Black; Yellow])
  ]
```

```sh
cat words.txt | dune exec bin/main.exe | head
# enact 104635
# paten 104590
# manet 104375
# eaten 102244
# cadet 102140
# pated 102095
# mated 101880
# hated 100800
# gated 100220
# bated 100135
```

ENACT is the top-ranked choice, with an evaluation of 🟨⬛🟨🟨🟩.

```ocaml
let rules =
  [ ("arose", [Yellow; Black; Black; Black; Yellow])
  ; ("telia", [Yellow; Yellow; Black; Black; Yellow])
  ; ("enact", [Yellow; Black; Yellow; Yellow; Green])
  ]
```

```sh
cat words.txt | dune exec bin/main.exe | head
# cadet 102140
# cheat 98675
# facet 95450
```

CADET gets top billing, with an evaluation of 🟩🟨⬛🟨🟩.

```ocaml
let rules =
  [ ("arose", [Yellow; Black; Black; Black; Yellow])
  ; ("telia", [Yellow; Yellow; Black; Black; Yellow])
  ; ("enact", [Yellow; Black; Yellow; Yellow; Green])
  ; ("cadet", [Green; Yellow; Black; Yellow; Green])
  ]
```

```sh
cat words.txt | dune exec bin/main.exe | head
# cheat 98675
```

And finally, we arrive at CHEAT 🟩🟩🟩🟩🟩.

🟨⬛⬛⬛🟨<br>
🟨🟨⬛⬛🟨<br>
🟨⬛🟨🟨🟩<br>
🟩🟨⬛🟨🟩<br>
🟩🟩🟩🟩🟩
