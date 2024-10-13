#!/usr/bin/env bash

#### Description: Test for string values
#### Written by: Guillermo de Ignacio - gdeignacio on 01-2023

###################################
###   Test environment values   ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./test_string_utils.sh

Test string conversions

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Testing string utils..."
echo ""

test_string_utils_foobar=""
test_string_utils_file=""

source $PROJECT_PATH/bin/lib_string_utils.sh

before(){
    test_string_utils_foobar="foo-bar"
    test_string_utils_file=$PROJECT_PATH/test/foobar.txt
}


test_spinal_to_camelcase(){
    local foobar=$1
    echo Testing $foobar in spinal-case format
    echo ""
    echo To camelcase
    echo $(lib_string_utils.spinal_to_camelcase $foobar)
}

test_spinal_to_lower(){
    local foobar=$1
    echo Testing $foobar in spinal-case format
    echo ""
    echo To lowercase
    echo $(lib_string_utils.spinal_to_lower $foobar)
}

test_spinal_to_upper(){
    local foobar=$1
    echo Testing $foobar in spinal-case format
    echo ""
    echo To uppercase
    echo $(lib_string_utils.spinal_to_upper $foobar)
}

test_replace_key_value_before(){
    local file=${test_string_utils_file}
    echo "FOO=bar" > ${file}
    echo File ${file} created
    echo Listing ${file}
    echo $(cat ${file})
}

test_replace_key_value(){
    local key=$1
    local old_value=$2
    local new_value=$3
    local file=$4
    
    echo Testing $foobar in spinal-case format
    echo ""
    echo To uppercase
    echo $(lib_string_utils.replace_key_value $key $old_value $new_value $file)
}

test_replace_key_value_after(){
    local file=${test_string_utils_file}
    echo ""
    echo Listing ${file}
    cat ${file}
    echo Deleting ${file}
    rm ${file}
}


main(){

    before
    echo "foobar value is $test_string_utils_foobar"
    echo ""
    echo $(test_spinal_to_camelcase $test_string_utils_foobar)
    echo ""
    echo $(test_spinal_to_lower $test_string_utils_foobar)
    echo ""
    echo $(test_spinal_to_upper $test_string_utils_foobar)
    echo ""
    test_replace_key_value_before
    lib_string_utils.replace_key_value FOO bar foo $test_string_utils_file  
    test_replace_key_value_after

}


main "$@"
