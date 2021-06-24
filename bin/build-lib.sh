#!/bin/bash

COOKBOOK_HOME=`dirname $0`/..
LIB_HOME="$COOKBOOK_HOME/lib"

cd $LIB_HOME
make -s
