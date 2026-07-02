#!/bin/bash
X=5
if [ $X == 5 ]; then echo "five"; fi   # SC2086: double-quote $X
