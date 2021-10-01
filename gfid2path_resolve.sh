#!/bin/bash

# Version: 1.0
# Author: amark@redhat.com
# Quickly resolve a GFID to the full path and filename.
# Useful to identify the location of a file on brick
# when heal info only shows a GFID and not the full path.

function get_parent_dir_gfid() {
    gfid=$2
    getfattr -d -m . -e text $1.glusterfs/${gfid:0:2}/${gfid:2:2}/$gfid|grep trusted.gfid2path &>/dev/null
    if [ $? -ne 0 ]; then
            echo "No trusted.gfid2path xattr exist."
            exit -1
    fi
    parent_dir_gfid=$(getfattr -d -m . -e text $1.glusterfs/${gfid:0:2}/${gfid:2:2}/$gfid 2>/dev/null|grep trusted.gfid2path|egrep -o ".{8}-.{4}-.{4}-.{4}-.{12}")
}

function get_full_path() {
    gfid=$2
    readlink -f $1.glusterfs/${gfid:0:2}/${gfid:2:2}/$gfid
    if [ $? -ne 0 ]; then
            echo "Executing readlink on directory failed." >&2
            exit -1
    fi
}

main() {
        if [ $# -lt 2 ] ;then
                echo "Resolves file GFID to full path via trusted.gfid2path xattr. Example:"
                echo "$0 /brick1/brick/ a70c723f-7dd7-44c5-b327-95eaae48d47e"
                exit -1
        fi
        gfid=$2
        if [ -e "$1.glusterfs/${gfid:0:2}/${gfid:2:2}/$gfid" ]; then

              get_parent_dir_gfid $1 $2
              if [ $? -ne 0 ]; then
                      echo "Executing getfattr failed."
                      exit -1
              fi
              full_path=$(get_full_path $1 $parent_dir_gfid)
              filename=$(getfattr -d -m . -e text $1.glusterfs/${gfid:0:2}/${gfid:2:2}/$gfid 2>/dev/null|grep trusted.gfid2path|cut -d / -f 2|sed 's/.$//')
              echo "FULL PATH:" $full_path
              echo "FILENAME:" $filename
        else
              echo "GFID link doesn't exist or brick path is incorrect."
        fi
}

main "$@"
