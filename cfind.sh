#!/bin/bash

myWord=$1

grep --color='auto' -ERn --include=\*.c --include=\*.h --color=auto "$myWord" .
