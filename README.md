## wordle.ml

Cheating at [Wordle](https://www.powerlanguage.co.uk/wordle/) with OCaml.

### usage

Modify the `rules` list in `bin/main.ml`. Then run:

```sh
cat /usr/share/dict/words | grep -E '^[a-z]{5}$' | dune exec bin/main.exe | head
# boosy 400
# toosh 396
# toshy 395
# boost 388
# goosy 388
# moost 380
# tossy 380
# bosom 376
# bossy 376
# coost 376
```

These candidates are sorted by a very rough heuristic:
* For each letter, add the number of times that letter appears in any word
* Multiply by the number of unique letters (more letters means more clues!)

Many of the words returned by the program (those in `/usr/share/dict/words` on my MacBook) are not in Wordle's dictionary. Just go down the list until you hit one.

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
cat /usr/share/dict/words | grep -E '^[a-z]{5}$' | dune exec bin/main.exe | head
# arose 84745
# orate 84735
# arise 83645
# raise 83645
# serai 83645
# arite 83635
# irate 83635
# retia 83635
# tarie 83635
# ariel 83570
```

Manually computing this, "AROSE" would get a pattern of 🟨⬛⬛⬛🟨. Modify `rules` accordingly and re-run:

```ocaml
let rules =
  [ Other ('a', 0)
  ; Never 'r'
  ; Never 'o'
  ; Never 's'
  ; Other ('e', 4)
  ]
```

```sh
cat /usr/share/dict/words | grep -E '^[a-z]{5}$' | dune exec bin/main.exe | head
# laeti 80260
# entia 79490
# tenai 79490
# tinea 79490
# elain 79425
# linea 79425
# ental 78425
# laten 78425
# leant 78425
# ileac 76085
```

LATEN corresponds to a pattern of ⬛🟨🟩🟨⬛.

```ocaml
let rules =
  [ Other ('a', 0)
  ; Never 'r'
  ; Never 'o'
  ; Never 's'
  ; Other ('e', 4)

  ; Never 'l'
  ; Other ('a', 1)
  ; Exact ('e', 2)
  ; Other ('t', 3)
  ; Never 'i'
  ]
```

```sh
cat /usr/share/dict/words | grep -E '^[a-z]{5}$' | dune exec bin/main.exe | head
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

Though UPEAT is likely not in Wordle's dictionary, we'll run with it using a pattern of ⬛⬛🟩🟩🟩.

```ocaml
let rules =
  [ Other ('a', 0)
  ; Never 'r'
  ; Never 'o'
  ; Never 's'
  ; Other ('e', 4)

  ; Never 'l'
  ; Other ('a', 1)
  ; Exact ('e', 2)
  ; Other ('t', 3)
  ; Never 'i'

  ; Never 'u'
  ; Never 'p'
  ; Exact ('e', 2)
  ; Exact ('a', 3)
  ; Exact ('t', 4)
  ]
```

```sh
cat /usr/share/dict/words | grep -E '^[a-z]{5}$' | dune exec bin/main.exe | head
# cheat 69860
# wheat 65555
```

CHEAT wins out against WHEAT (C's are more common), giving us a successful solution.

🟨⬛⬛⬛🟨<br>
⬛🟨🟩🟨⬛<br>
⬛⬛🟩🟩🟩<br>
🟩🟩🟩🟩🟩
