#!/bin/bash

COOKBOOK_HOME=`dirname $0`/..
SNIPPETS_HOME="$COOKBOOK_HOME/snippets"

for z in $SNIPPETS_HOME/*.ll
do
    BASE_NAME="$(basename "$z" .ll)"
    BC_FILE_NAME=$SNIPPETS_HOME/"$BASE_NAME".bc
    BIN_FILE_NAME=$SNIPPETS_HOME/"$BASE_NAME".bin
    OUT_FILE_NAME=$SNIPPETS_HOME/"$BASE_NAME".out

    if [[ "$OUT_FILE_NAME" -ot "$z" ]]
    then
        echo Snippet: "$BASE_NAME"
        llvm-as-10 "$z"
        clang -Woverride-module "$BC_FILE_NAME" "$COOKBOOK_HOME"/lib/lib.bc -o $BIN_FILE_NAME
        "$BIN_FILE_NAME" | tee "$OUT_FILE_NAME"

    fi
done
