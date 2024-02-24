#!/bin/sh

yellow='\033[93m'
green='\033[92m'
red='\033[91m'
endc='\033[0m'

doing() {
    echo "$yellow[*] $1...$endc"
}

finished() {
    lowercase=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    echo "$green[+] Done $lowercase!$endc"
}

failed() {
    lowercase=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    echo "$red[-] Failed $lowercase!$endc"
    exit 1
}

task() {
    doing "$1"
    if sh -c "$2"; then
        finished "$1"
    else
        failed "$1"
    fi
}

task "Clearing packages directory" "rm -rf packages/*;"
task "Making tweak" "gmake package && [ -e \$(find packages/*.deb) ];"
task "Renaming package filename" "find packages/*.deb -exec sh -c 'mv \"\$0\" packages/Flora.deb' {} \;"
