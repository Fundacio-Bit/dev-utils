#!/usr/bin/env bash

#### Description: Loads environment variables from .env file
#### The script defines functions to check the operating system, check if Docker and R are available, and load environment variables from a .env file.
#### The script is intended to be sourced by other scripts that need to load environment variables and check
#### Written by: Guillermo de Ignacio - gdeignacio on 01-2023

# Revision 2024-08-01
# Revision 2024-08-01: Updated to load environment variables from .env file and check if Docker and R are available.
# Revision 2026-05-26: Minor updates and improvements


#### THIS FILE USED TO BE SOURCED. THINK TWICE BEFORE UPDATE.
#### EXECUTING BY YOURSELF WILL ONLY TAKE EFFECT IN YOUR CURRENT SHELL.

###################################
###   LOAD ENV UTILS            ###
###################################


##################################################################
##################################################################

lib_env_utils.check_os(){

    local unameOut="$(uname -s)"
    local machine="UNKNOWN:${unameOut}"
    local isLinux=0

    case "${unameOut}" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=Mac;;
        CYGWIN*)    machine=Cygwin;;
        MINGW*)     machine=MinGw;;
        *)          machine="UNKNOWN:${unameOut}"
    esac

    # echo "Your OS is ${machine} according uname=${unameOut}"

    isLinux=0
    # Assign mode 1 if so is linux or mac, 0 otherwise
    if [[ ${machine} == "Linux" || ${machine} == "Mac" ]]; then
        isLinux=1
    fi

    echo "${isLinux}"
}


##################################################################
##################################################################


lib_env_utils.check_docker(){

    local cmnd=docker
    
    # echo ""
    # echo "Checking ${cmnd} settings ..."

    local dckr=/dev/null
    if command -v ${cmnd} > /dev/null; then
        dckr=$(command -v ${cmnd})
        # echo "${cmnd} is available at ${dckr}"
    #else
    #    echo "${cmnd} is not available. ${cmnd} set to ${dckr}"
    fi

    echo "${dckr}"

}

##################################################################
##################################################################


lib_env_utils.check_R(){

    local cmnd=R
    #echo ""
    #echo "Checking ${cmnd} settings ..."

    local rpath=/dev/null
    if command -v ${cmnd} > /dev/null; then
        rpath=$(command -v ${cmnd})
    #    echo "${cmnd} is available at ${rpath}"
    #else
    #    echo "${cmnd} is not available. ${cmnd} set to ${rpath}"
    fi

    echo "${rpath}"

}

##################################################################
##################################################################



lib_env_utils.loadenv(){

    echo ""
    echo "[$(date +"%Y-%m-%d %T")] Loading env..."
    echo ""

    while read line; do 
        # Define the string value
        # Set space as the delimiter
        IFS='='
        #Read the split words into an array based on space delimiter
        read -a strarr <<< "$line"
        #Count the total words
        #echo "There are ${#strarr[*]} words in the text."
        key="${strarr[0]}"
        value="${strarr[1]}"
        export $key=$(eval echo $value)
        echo "$key : $(eval echo \${$key})" 
    done < <(cat $1/.env | grep -v "#" | grep -v "^$")

}

##################################################################
##################################################################

lib_env_utils.loaded(){
    echo lib_env_utils.sh loaded
    echo lib_string_utils.sh may be required
}

