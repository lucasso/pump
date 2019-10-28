#!/bin/sh

if [ $# -ne 1 ]; then
  echo "podaj plik .s jako jedyny parametr"
  exit 1
fi

PLIKS=$1

if [ e! -f $PLIKS ]; then
  echo "nie ma takiego pliku \"$PLIKS\""
  exit 2
fi

echo "kompilowanie $PLIKS"
avra -I $(dirname $0) $PLIKS
