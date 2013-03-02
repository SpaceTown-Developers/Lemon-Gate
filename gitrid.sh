#!/bin/sh
echo "git (`git describe --always`)" > data/lemon_version.txt
rm -rf .git
