## wordle.ml

```sh
cat /usr/share/dict/words | grep -E '^[a-z]{5}$' | dune exec bin/main.exe
```