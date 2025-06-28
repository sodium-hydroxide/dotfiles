#!/bin/sh

/opt/homebrew/bin/ruff format "$1" \
  --line-length 80 \
  --quote-style double \
  --indent-style space \
  --line-ending lf

/opt/homebrew/bin/ruff check "$1" \
  --line-length 80 \
  --target-version py311 \
  --select F,E,W,I,B,UP,C90 \
  --fix \
  --show-fixes
