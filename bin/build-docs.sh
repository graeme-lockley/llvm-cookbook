#!/bin/bash

COOKBOOK_HOME=`dirname $0`/..

BIN_HOME="$COOKBOOK_HOME/bin"
BUILD_HOME="$COOKBOOK_HOME/build"
DOCS_HOME="$COOKBOOK_HOME/docs"
SNIPPETS_HOME="$COOKBOOK_HOME/snippets"

OLDEST_BUILD=$BUILD_HOME/`ls -1tr "$BUILD_HOME" | head -n 1`
YOUNGEST_SNIPPET=$SNIPPETS_HOME/`ls -1t "$SNIPPETS_HOME" | head -n 1`
YOUNGEST_DOC=$DOCS_HOME/`ls -1t "$DOCS_HOME" | head -n 1`

# echo OLDEST_BUILD: $OLDEST_BUILD: `ls -Fal $OLDEST_BUILD`
# echo YOUNGEST_SNIPPET: $YOUNGEST_SNIPPET: `ls -Fal $YOUNGEST_SNIPPET`
# echo YOUNGEST_DOC: $YOUNGEST_DOC: `ls -Fal $YOUNGEST_DOC`

if [ $OLDEST_BUILD -ot $YOUNGEST_SNIPPET -o $OLDEST_BUILD -ot $YOUNGEST_DOC ]
then
    for z in $DOCS_HOME/*.md
    do
        NAME=$(basename $z .md)

        echo Doc: $NAME
        awk -f $BIN_HOME/fred.awk $DOCS_$z > $BUILD_HOME/"$NAME".md
    done
fi

