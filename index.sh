#!/bin/bash
#
# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

set -e

# Arguments:
# 1 - folder to search files in
function buildIndex() {
    metaInfoFields=('displayName' 'description' 'language' 'projectType')
    metaInfoFields2=('projects')


    ## search for all devfiles
    
    readarray -d '' arr < <(find "$1" -name 'meta.yaml' -print0)

    readarray -d '' devfileArray < <(find "$1" -name 'devfile.yaml' -print0)

    FIRST_LINE=true
    echo "["


    declare -i count=0
   for i in "${arr[@]}"
    do
        if [ "$FIRST_LINE" = true ] ; then
            echo "{"
            FIRST_LINE=false
        else
            echo ",{"
        fi

        for field in "${metaInfoFields[@]}"
        do
            # get value of needed field in json format
            # note that it may have differrent formats: arrays, string, etc.
            # String value contains quotes, e.g. "str"
            value="$(yq r -j "$i" "$field")"
            echo "  \"$field\":$value,"
        done

        for field in "${metaInfoFields2[@]}"
        do
           # String value contains quotes, e.g. "str"
            projects="$(yq r -j "${devfileArray[$count]}" "projects[0].source.location")"
            #location="$(yq r -j "$projects" "location")"
           echo "  \"location\":$projects,"
        done

        parentFolderPath=${i%/*}
        echo "  \"links\": {\"self\":\"/$parentFolderPath/devfile.yaml\" }"
        echo "}"

    count=count+1

    done
    echo "]"




#    ## now loop through meta.yaml files
#    declare -i count=0
#    for i in "${arr[@]}"
#    do
#        if [ "$FIRST_LINE" = true ] ; then
#            echo "{"
#            FIRST_LINE=false
#        else
#            echo ",{"
#        fi
#
#        for field in "${metaInfoFields[@]}"
#        do
#            # get value of needed field in json format
#            # note that it may have differrent formats: arrays, string, etc.
#            # String value contains quotes, e.g. "str"
#            value="$(yq r -j "${arr[$count]}" "$field")"
#            echo "  \"$field\":$value,"
#        done
#
#        for field in "${metaInfoFields2[@]}"
#        do
#           # String value contains quotes, e.g. "str"
#            value="$(yq r -j "${devArray[$count]}" "$field")"
#            echo "  \"$field\":$value,"
#        done
#
#        parentFolderPath=${i%/*}
#        echo "  \"links\": {\"self\":\"/$parentFolderPath/devfile.yaml\" }"
#        echo "}"
#    
#        count=count+1
#       
#    done
#    echo "]"
}

buildIndex devfiles
