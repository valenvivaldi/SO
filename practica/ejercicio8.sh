#!/bin/bash

l=0
let t= 0

for i in $*
do
	l=$(wc -l $i | awk '{print $1}')
	echo $1
	let t=$t+$1
done 

echo "Total: $t, args: $#"
