#!/bin/sh
out='bin/serialize-example.txt'

echo "Generated with bin/serialize.sh" > $out
cat bin/serializer.hack | hhvm bin/serializer.hack >> $out