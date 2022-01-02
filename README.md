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