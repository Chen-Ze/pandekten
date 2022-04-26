#!/bin/bash

##
# print a relative path from "source folder" to "target file"
#
# params:
#  $1 - target file, can be a relative path or an absolute path.
#  $2 - source folder, can be a relative path or an absolute path.
#
# test:
#  $ mkdir -p ~/A/B/C/D; touch ~/A/B/C/D/testfile.txt; touch ~/A/B/testfile.txt
#
#  $ getRelativePath ~/A/B/C/D/testfile.txt  ~/A/B
#  $ C/D/testfile.txt
#  
#  $ getRelativePath ~/A/B/testfile.txt  ~/A/B/C
#  $ ../testfile.txt
#
#  $ getRelativePath ~/A/B/testfile.txt  /
#  $ home/bunnier/A/B/testfile.txt 
#
function getRelativePath(){
    local targetFilename=$(basename $1)
    local targetFolder=$(cd $(dirname $1);pwd) # absolute target folder path
    local currentFolder=$(cd $2;pwd) # absulute source folder
    local result=.

    while [ "$currentFolder" != "$targetFolder" ];do
      if [[ "$targetFolder" =~ "$currentFolder"* ]];then
          pointSegment=${targetFolder#$currentFolder}
          result=$result/${pointSegment#/}
          break
      fi  
      result="$result"/..
      currentFolder=$(dirname $currentFolder)
    done

    result=$result/$targetFilename
    echo ${result#./}
}

function create() {
    echo "Making directory \"$1\""
    mkdir -p "$1"

    title=$(basename "$1")
    echo "Title is $title"
    
    echo "Creating .tex file \"$1/main.tex\""
    touch "$1/main.tex"

    echo "Writing .tex file"
    cat .template.tex | sed "s/TITLE/$title/g" >> "$1/main.tex"

    relativePath=$(getRelativePath ./Style "$1")
    echo "Relative path from target directory to Style: \"$relativePath\""

    echo "Changing directory to \"$1\""
    cd "$1"

    echo "Linking .texmf"
    ln -s $relativePath .texmf
}

create $1
