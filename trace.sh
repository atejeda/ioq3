#!/usr/bin/env bash

BINARY=build/debug-linux-x86_64/ioquake3.x86_64
REPORT=report

rm -rf gmon.out report*

$BINARY
gprof $BINARY gmon.out > $REPORT.txt
gprof2dot $REPORT.txt > $REPORT.dot
dot -Tpng -o$REPORT.png $REPORT.dot
xdg-open $REPORT.png