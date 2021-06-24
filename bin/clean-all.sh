#!/bin/bash

COOKBOOK_HOME=`dirname $0`/..

BUILD_HOME="$COOKBOOK_HOME/build"
SNIPPETS_HOME="$COOKBOOK_HOME/snippets"
LIB_HOME="$COOKBOOK_HOME/lib"

rm -f "$BUILD_HOME"/*.md
rm -f "$SNIPPETS_HOME"/*.bc  "$SNIPPETS_HOME"/*.out "$SNIPPETS_HOME"/*.bin
rm -f "$LIB_HOME"/*.bc "$LIB_HOME"/*.ll