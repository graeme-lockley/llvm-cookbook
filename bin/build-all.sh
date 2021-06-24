#!/bin/bash

COOKBOOK_HOME=`dirname $0`/..

$COOKBOOK_HOME/bin/build-lib.sh
$COOKBOOK_HOME/bin/build-snippets.sh
$COOKBOOK_HOME/bin/build-docs.sh
