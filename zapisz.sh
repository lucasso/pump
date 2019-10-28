#!/bin/sh

if [ $# -ne 1 ]; then
  echo "podaj plik HEX jako jedyny parametr"
  exit 1
fi

PLIKHEX=$1

if [ ! -f $PLIKHEX ]; then
  echo "nie ma takiego pliku \"$PLIKHEX\""
  exit 2
fi

echo "zapiywanie $PLIKHEX do czipa"
sudo avrdude -c usbasp -p m8 -U flash:w:$PLIKHEX:i
