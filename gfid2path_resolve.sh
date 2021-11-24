#!/bin/bash

# Version: 1.1
# Author: amark@redhat.com
# Quickly resolve a GFID to filename and/or directory path.
# Useful when heal info oputput shows a GFID only.

function get_parent_dir_gfid() {
    gfid=$2
    getfattr -d -m . -e text $brick_path.glusterfs/${gfid:0:2}/${gfid:2:2}/$gfid|grep trusted.gfid2path &>/dev/null

    if [ $? -ne 0 ]; then
            echo "No trusted.gfid2path xattr exist. Trying readlink directly."
            dir=$(readlink -f $brick_path.glusterfs/${gfid:0:2}/${gfid:2:2}/$gfid)
            echo "DIRECTORY:" $dir
            exit -1
    fi
    parent_dir_gfid=$(getfattr -d -m . -e text $brick_path.glusterfs/${gfid:0:2}/${gfid:2:2}/$gfid 2>/dev/null|grep trusted.gfid2path|egrep -o ".{8}-.{4}-.{4}-.{4}-.{12}")
}

function get_full_path() {
    gfid=$2
    readlink -f $brick_path.glusterfs/${gfid:0:2}/${gfid:2:2}/$gfid

    if [ $? -ne 0 ]; then
            echo "Executing readlink on directory failed." >&2
            exit -1
    fi
}

main() {
    if [ $# -lt 2 ] ; then
            echo "Resolves file GFID to full path via trusted.gfid2path xattr. Example:"
            echo "$0 /brick1/brick/ a70c723f-7dd7-44c5-b327-95eaae48d47e"
            exit -1
    fi

    brick_path=$1
    gfid=$2

    if [[ $1 != */ ]]; then
            brick_path="$1/"
    fi

    if [ -e "$brick_path.glusterfs/${gfid:0:2}/${gfid:2:2}/$gfid" ]; then
          get_parent_dir_gfid $brick_path $2
          if [ $? -ne 0 ]; then
                  echo "Executing getfattr failed."
                  exit -1
          fi
          full_path=$(get_full_path $brick_path $parent_dir_gfid)
          filename=$(getfattr -d -m . -e text $brick_path.glusterfs/${gfid:0:2}/${gfid:2:2}/$gfid 2>/dev/null|grep trusted.gfid2path|cut -d / -f 2|sed 's/.$//')
          echo "FULL PATH:" $full_path
          echo "FILENAME:" $filename
    else
          echo "GFID link doesn't exist or brick path is incorrect."
    fi
}

main "$@"
