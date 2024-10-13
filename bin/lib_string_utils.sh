#!/usr/bin/env bash

#### Description: String utils function library
#### Written by: Guillermo de Ignacio - gdeignacio on 01-2023


#### THIS FILE USED TO BE SOURCED. THINK TWICE BEFORE UPDATE.
#### EXECUTING BY YOURSELF WILL ONLY TAKE EFFECT IN YOUR CURRENT SHELL.


###################################
###   STRING UTILS              ###
###################################

##################################################################
##################################################################

lib_string_utils.spinal_to_camelcase() {
    IFS=- read -ra str <<<"$1"
    printf '%s' "${str[@]^}"
}


##################################################################
##################################################################

lib_string_utils.spinal_to_lower() {
    IFS=- read -ra str <<<"$1"
    printf '%s' "${str[@],,}"
}


##################################################################
##################################################################

lib_string_utils.spinal_to_upper() {
    IFS=- read -ra str <<<"$1"
    printf '%s' "${str[@]^^}"
}


##################################################################
##################################################################

lib_string_utils.replace_key_value(){
    
    local key=$1
    local old_value=$2
    local new_value=$3
    local file=$4

    old_key_value=$(echo $key\=$old_value)
    new_key_value=$(echo $key\=$new_value)
    echo "Value substitution from $old_key_value to $new_key_value"
    # Better use double quoting for sedstring'
    sed -i "s/${old_key_value}/${new_key_value}/" ${file}
    echo $(cat $file)
}


##################################################################
##################################################################

lib_string_utils.loaded(){
    echo lib_string_utils.sh loaded
}