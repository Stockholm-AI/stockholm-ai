#!/usr/bin/env bash
set -ex
input_image=$1
output_image=$2

## Example usage: ./convert_to_favicon.sh icon.svg favicon.ico

for d in 16 32; do
    convert -resize ${d}x${d} -flatten -colors 256 ${input_image} /tmp/favicon-${d}.ico
done
convert /tmp/favicon-{16,32}.ico favicon.ico
