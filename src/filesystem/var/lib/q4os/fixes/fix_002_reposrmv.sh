#!/bin/sh
#remove q4os-3-0-cn repositories
echo "Fixing repositories ..."
sed -i '/q4os-3-0-cn/d' /etc/apt/sources.list
for REPO_FL in /etc/apt/sources.list.d/*.list ; do
  sed -i '/q4os-3-0-cn/d' $REPO_FL
done
