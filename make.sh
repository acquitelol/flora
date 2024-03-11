#!/bin/sh

type=$(ps -p $$ -o comm=)
yellow='\033[93m'
green='\033[92m'
red='\033[91m'
endc='\033[0m'

print() {
    if [ "$type" = "bash" ]; then
        echo -e "$1"
    else
        echo "$1"
    fi
}

doing() {
    print "$yellow[*] $1...$endc"
}

finished() {
    lowercase=$(print "$1" | tr '[:upper:]' '[:lower:]')
    print "$green[+] Done $lowercase!$endc"
}

failed() {
    lowercase=$(print "$1" | tr '[:upper:]' '[:lower:]')
    print "$red[-] Failed $lowercase!$endc"
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

# task "Cleaning paths" "gmake clean;"
task "Making tweak" "gmake package && [ -e \$(find packages/com.rosiepie.flora*.deb) ];"
task "Renaming package filename" "find packages/com.rosiepie.flora*.deb -exec sh -c 'mv \"\$0\" packages/Flora.deb' {} \;"
