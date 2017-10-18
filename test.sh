#!/bin/bash

export RED='\e[31m'
export GREEN='\e[32m'
export YELLOW='\e[33m'
export CYAN='\e[36m'
export NC='\033[0m'

export PRE="[${CYAN}CT${NC}] "

function log(){
    case $2 in
        "warning")
            echo -e "${YELLOW}$1${NC}"
            ;;
        "error")
            echo -e "${RED}$1${NC}"
            ;;
        "success")
            echo -e "${GREEN}$1${NC}"
            ;;
        "task")
            printf "${PRE}$1... "
            ;;
        *)
            echo -e "${PRE}${BCYAN}LOG${NC}: $1"
            ;;
    esac
}

function up() {
    log "Contacting $2 ($1)..." "task"
    timeout 1 curl -s "$1" >/dev/null

    if [ $? = 0 ]; then
        log "Reached $2 successfully." "success"
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

free=$(df -BG / | tail -1 | awk '{print $4}' | sed 's/G$//')
required=30
log "Checking if host has 30G free" "task"
if [ $free -gt $required ]; then
    log "it does." "success"
else
    log "it does not." "error"
fi

log "Checking for 64 Bit OS" "task"
if [ $(uname -m) = "x86_64" ]; then
    log "64 Bit OS detected." "success"
else
    log "64 Bit OS not detected. You will not be able to compete." "error"
fi


# Test CCS servers
servers=($(< uri_1.txt) $(< uri_2.txt) $(< uri_3.txt))

for i in ${servers[@]}; do
    ip=$(echo $i | egrep -o "([0-9]{1,3}[.]){3}[0-9]{1,3}")
    log "Testing connectivity for CCS Server $ip" "task"
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
