#!/usr/bin/env bash

#### Description: Stack related utility functions
#### Written by: Guillermo de Ignacio - gdeignacio on 01-2023

#### THIS FILE USED TO BE SOURCED. THINK TWICE BEFORE UPDATE.
#### EXECUTING BY YOURSELF WILL ONLY TAKE EFFECT IN YOUR CURRENT SHELL.

###################################
###   STACK_UTILS               ###
###################################


##################################################################
##################################################################

lib_stack_utils.get_stack_path(){

    local stack_path=""

    if [ -z "${APP_STACK_PATH}" ]; then
        echo "APP_STACK_PATH is not defined. Please define it in your settings file."
        return 1
    fi

    if [ ! -d "${APP_STACK_PATH}" ]; then
        echo "APP_STACK_PATH=${APP_STACK_PATH} does not exist or is not a directory. Please check your settings file."
        return 1
    fi

    stack_path="${APP_STACK_PATH}"

    echo "${stack_path}"
}

##################################################################
##################################################################

lib_stack_utils.get_app_array(){

    local app_array=""
    
    local stack_path=$1

    if [ -z "${stack_path}" ] || [ ! -d "${stack_path}" ]; then
        echo "stack_path is not defined or does not exist: ${stack_path}"
        return 1
    fi

   

    app_array="${APP_PROJECT_ARRAY}"

    echo "${app_array}"
}


##################################################################
##################################################################


lib_env_utils.loaded(){
    echo lib_env_utils.sh loaded
    echo lib_string_utils.sh may be required
}

