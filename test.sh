#!/bin/bash

##########################
# Written by Erik Boesen #
# github.com/ErikBoesen  #
##########################

export CYAN="\e[36m"
export RED="\e[31m"
export GREEN="\e[32m"
export YELLOW="\e[33m"
export NC="\033[0m"

export PRE="[${CYAN}CT${NC}] "

if [ $(uname) = "Darwin" ]; then
    function timeout() { perl -e 'alarm shift; exec @ARGV' "$@"; }
fi

function log(){
    case $2 in
        "warning")
            printf "${YELLOW}$1${NC}\n"
            ;;
        "error")
            printf "${RED}$1${NC}\n"
            ;;
        "success")
            printf "${GREEN}$1${NC}\n"
            ;;
        "task")
            printf "${PRE}$1... "
            ;;
        *)
            printf "${PRE}$1${NC}\n"
            ;;
    esac
}

function up() {
    log "Contacting $2 ($1)" "task"
    timeout 2 curl -s "$1" >/dev/null

    if [ $? = 0 ]; then
        log "successfully reached $2." "success"
    else
        log "Couldn't reach $2." "error"
    fi
}

# Test connection, system features
up google.com "Google"
up uscyberpatriot.org "CyberPatriot website"
up www.microsoft.com "Microsoft"
up canonical.com "Canonical"

# TODO: Test host time

if [ $(uname) = "Darwin" ]; then
    free=$(df -g / | tail -1 | awk '{print $3}')
else
    free=$(df -BG / | tail -1 | awk '{print $4}' | sed "s/G$//")
fi
required=30
log "Checking if host has >${required}G free" "task"
if [ $free -gt $required ]; then
    log "it does (${free}G)." "success"
else
    log "it does not (${free}G)." "error"
fi

log "Checking for 64-bit OS" "task"
arch=$(uname -m)
if [ $arch = "x86_64" ]; then
    log "$arch OS detected." "success"
else
    log "32-bit $arch OS detected. You will not be able to compete." "error"
fi


# Test CCS servers
servers=()
for i in uri_*.txt; do servers+=($(< $i)); done

if [ ${#servers[@]} = 0 ]; then
    log "Warning: no URI files detected. No CCS servers will be tested."
fi

for i in ${servers[@]}; do
    ip=$(echo $i | egrep -o "([0-9]{1,3}[.]){3}[0-9]{1,3}")
    log "Testing connectivity to CCS Server $ip" "task"
    resp=$(timeout 2 curl -s "$i")
    if [ $? = 0 ]; then
        case $resp in
            "")
                log "success!" "success"
                ;;
            *"403"*)
                log "Error 403: Forbidden." "warning"
                ;;
            *)
                log "Unknown response: $resp" "warning"
                ;;
        esac
    else
        log "server unreachable." "error"
    fi
done
