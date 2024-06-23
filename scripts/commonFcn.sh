#!/bin/bash

# FUNCTION DEFINITIONS FOR OTHER RUN SCRIPTS

# FUNCTION TO ECHO INPUT IN GREEN
# >>>-------------------------------------------------------------
# INPUTS:
# $1: INPUT TO ECHO
# ----------------------------------------------------------------
EchoGreen(){
    echo -e "\e[32m$1\e[0m"
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO ECHO INPUT IN RED
# >>>-------------------------------------------------------------
# INPUTS:
# $1: INPUT TO ECHO
# ----------------------------------------------------------------
EchoRed(){
    echo -e "\e[31m$1\e[0m"
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO ECHO INPUT IN YELLOW
# >>>-------------------------------------------------------------
# INPUTS:
# $1: INPUT TO ECHO
# ----------------------------------------------------------------
EchoYellow(){
    echo -e "\e[33m$1\e[0m"
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO PRINT A LINE OF BOXLINES
# >>>-------------------------------------------------------------
EchoBoxLine(){
    echo $(printf '%.s─' $(seq 1 $(tput cols)))
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF A DIRECTORY EXISTS
# >>>-------------------------------------------------------------
# INPUTS:
# $1: DIRECTORY TO CHECK
# $2=create: CREATE DIRECTORY IF IT DOES NOT EXIST (optional)
# ----------------------------------------------------------------
CheckDir(){
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        EchoRed "[$FUNCNAME] INSUFFICIENT NUMBER OF ARGUMENTS"
        exit 1
    fi

    if [ -d $1 ]; then
        EchoGreen "[$FUNCNAME] DIRECTORY $1 EXISTS"
        if [ "$2x" == "createx" ]; then
            EchoYellow "[$FUNCNAME] THE SECOND ARGUMENT WILL BE IGNORED"
        fi
    else
        EchoRed "[$FUNCNAME] DIRECTORY $1 DOES NOT EXIST"
        if [ "$2x" == "createx" ]; then
            EchoYellow "[$FUNCNAME] CREATING DIRECTORY $1"
            mkdir -p $1
        else
            EchoRed "[$FUNCNAME] PLEASE CREATE DIRECTORY $1"
            exit 1
        fi
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<