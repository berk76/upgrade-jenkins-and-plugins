#!/bin/bash

if [ $# -lt 2 ]; then
  echo "USAGE: $0 source-directory destination-directory"
  exit 1
fi

src_dir=$1
dest_dir=$2
owner=jenkins

for f in $src_dir/*.hpi ; do
  f=$(basename $f)
  rm -f $dest_dir/$(echo $f | sed 's/\..*/\.jpi/')
  rm -Rf $dest_dir/$(echo $f | sed 's/\..*//')
  cp -f $src_dir/$f $dest_dir/$f
  chown $owner $dest_dir/$f
  chgrp $owner $dest_dir/$f
done
