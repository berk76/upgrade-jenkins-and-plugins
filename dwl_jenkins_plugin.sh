#!/bin/bash

set -e

UPDATES_URL="http://updates.jenkins-ci.org/download/plugins/"

if [ $# -lt 2 ]; then
  echo "USAGE: $0 plugin-list-file destination-directory"
  exit 1
fi

plugin_list=$1
plugin_dir=$2
last_dwl_file="$plugin_dir/last_dwl.txt"

mkdir -p $plugin_dir

###########################################
# function: version 
# usage: version $ver
###########################################
version() { 
  echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; 
}

###########################################
# function: downloadPlugin
# usage: downloadPlugin $plugin $version
###########################################
downloadPlugin() {
  echo "Downloading: $1 $2"
  curl -L --output ${plugin_dir}/${1}.hpi  ${UPDATES_URL}/${1}/${2}/${1}.hpi
  echo "${1}.hpi" > $last_dwl_file
  return 0
}

###########################################
# function: installPlugin
# usage: installPlugin $plugin $version
###########################################
installPlugin() {
  echo "------------------"
  echo "Required:    $1 $2"
  if [ -f ${plugin_dir}/${1}.hpi ] && [ "$2" != "latest" ]; then
    if [ "$2" == "1" ]; then
      return 1
    fi
    ver=$( unzip -p ${plugin_dir}/${1}.hpi META-INF/MANIFEST.MF|tr -d '\r' | sed -e ':a;N;$!ba;s/\n //g' | grep -e 'Plugin-Version' | awk '{print $2}' | tr "," "\n" | grep -v 'resolution:=optional')
    if [ $(version $ver) -ge $(version $2) ]; then
      echo "Skipped:     $1 $ver (already installed)"
      return 0
    else
      echo "Installed:   $1 $ver"
    fi
  else
    echo "Not installed"
  fi
  downloadPlugin $1 $2
  changed=1
  return 0
}

while IFS="|" read plugin version
do
    #escape comments
    if [[ $plugin =~ ^# ]]; then
       continue
    fi

    #install the plugin
    installPlugin $plugin $version
done < $plugin_list


changed=1
maxloops=100

while [ "$changed"  == "1" ]; do
  echo "Check for missing dependecies ..."
  if  [ $maxloops -lt 1 ] ; then
    echo "Max loop count reached - probably a bug in this script: $0"
    exit 1
  fi
  ((maxloops--))
  changed=0
  for f in ${plugin_dir}/*.hpi ; do
    echo
    echo "*** Dependencies for $f (iteration $(expr 100 - $maxloops))***"
    echo
    # get a list of only non-optional dependencies
    deps=$( unzip -p ${f} META-INF/MANIFEST.MF|tr -d '\r' | sed -e ':a;N;$!ba;s/\n //g' | grep -e 'Plugin-Dependencies' | awk '{print $2}')
    
    #if deps were found, install them .. then set changed, so we re-loop all over all xpi's 
    if [ -f $last_dwl_file ]; then
      rm $last_dwl_file
    fi
    if [[ ! -z $deps ]]; then
      echo $deps | tr "," "\n" | grep -v 'resolution:=optional' | tr ' ' '\n' | 
      while IFS=: read plugin version; do
        installPlugin $plugin $version
      done
    fi
    if [ -f $last_dwl_file ]; then
      changed=1
    fi
  done
done

echo "!!! all done !!!"
