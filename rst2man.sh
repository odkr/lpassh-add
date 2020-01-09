#!/bin/sh

pandoc -o lpassh-add.1 -t man -s MANUAL.rst \
    -M title=lpassh-add -M date="$(date '+%B %d, %Y')" -M section=1