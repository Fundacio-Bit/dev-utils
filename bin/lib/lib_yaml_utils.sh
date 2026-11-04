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
###   LOAD YAML UTILS           ###
###################################


##################################################################
##################################################################

lib_yaml_utils.check_yaml(){

    local cmnd=yq
    
    # echo ""
    # echo "Checking ${cmnd} settings ..."
    
    local yaml_yq=/dev/null
    if  command -v ${cmnd} &> /dev/null; then
        yaml_yq=$(command -v $cmnd)
    fi

    echo "${yaml_yq}"
}


##################################################################
##################################################################

lib_yaml_utils.get_yaml_key(){
    
    local yaml_file="$1"
    local yaml_key="$2"
    local default_value="$3"

    if [ -z "$yaml_file" ] || [ -z "$yaml_key" ]; then
        echo "Usage: lib_yaml_utils.get_yaml_key <yaml_file> <yaml_key> [default_value]" >&2
        return 2
    fi

    if [ ! -f "$yaml_file" ]; then
        echo "Error: YAML file not found: $yaml_file" >&2
        return 1
    fi

    local yaml_bin
    yaml_bin=$(lib_yaml_utils.check_yaml)
    if [ -z "$yaml_bin" ] || [ "$yaml_bin" = "/dev/null" ]; then
        echo "Error: yq not found in PATH" >&2
        return 127
    fi
 
    echo "[$(date +"%Y-%m-%d %T")] Reading key '$yaml_key' from $yaml_file..." >&2

    # Build a safe yq path expression that supports keys with dashes or special chars.
    local yaml_expr
    if [[ "$yaml_key" == .* ]] || [[ "$yaml_key" == \[* ]]; then
        yaml_expr="$yaml_key"
    else
        local key_parts key_part escaped_part
        IFS='.' read -r -a key_parts <<< "$yaml_key"
        yaml_expr='.'
        for key_part in "${key_parts[@]}"; do
            escaped_part=${key_part//\"/\\\"}
            yaml_expr+="[\"${escaped_part}\"]"
        done
    fi

    # Read key using yq v4 syntax and return empty string when key is missing/null.
    local value
    value=$("$yaml_bin" eval "${yaml_expr} // \"\"" - < "$yaml_file")
    local status=$?

    echo "[$(date +"%Y-%m-%d %T")] Read value '$value' for key '$yaml_key' from $yaml_file" >&2


    if [ $status -ne 0 ]; then
        echo "Error: Unable to read key '$yaml_key' from $yaml_file" >&2
        return $status
    fi

    if [ -z "$value" ]; then
        if [ -n "$default_value" ]; then
            echo "$default_value"
            return 0
        fi
        return 3
    fi
  
    echo "$value"
}


##################################################################
##################################################################


lib_yaml_utils.value_to_env(){
    
    local key="$1"
    local value="$2"
    
    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "Usage: lib_yaml_utils.value_to_env <key> <value>" >&2
        return 2
    fi
    echo "[$(date +"%Y-%m-%d %T")] Setting environment variable '$key' with value '$value'..." >&2
    # Export the key-value pair as an environment variable
    echo "${key}"="${value}"

}


##################################################################
##################################################################

lib_yaml_utils.yaml_array_to_string(){
    
    local yaml_array="$1"
    
    if [ -z "$yaml_array" ]; then
        echo "Usage: lib_yaml_utils.yaml_array_to_string <yaml_array>" >&2
        return 2
    fi

    # Convert the YAML array to a space-separated string
    local string_array
    string_array="$(echo "$yaml_array" | grep -v '^&' | sed 's/^- //' | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
    
    echo "\"${string_array}\""
}


lib_yaml_utils.join_array(){
    
    local string_array="$1"
    local order="$2"
    local separator="$3"
    
    if [ -z "$string_array" ]; then
        echo "Usage: lib_yaml_utils.join_array <string_array> [order] [separator]" >&2
        return 2
    fi

    # Convert the space-separated string to a domain-separated string
    local domain_string
    if [ -z "$separator" ]; then
        separator='.'
    fi

    order=${order:-asc}
    if [ "$order" == "desc" ]; then
        string_array=$(echo "$string_array" | tr ' ' '\n' | sort -r | tr '\n' ' ')
    else
        string_array=$(echo "$string_array" | tr ' ' '\n' | sort | tr '\n' ' ')
    fi

    domain_string="$(echo "$string_array" | sed 's/[[:space:]]*$//' | tr ' ' "$separator")"
    
    echo "${domain_string}"
}


################################################################
################################################################

lib_yaml_utils.yaml_service_array_to_string(){
    local yaml_array="$1"
    local separator="${2:-/}"

    [ -n "$yaml_array" ] || {
        echo "Usage: lib_yaml_utils.yaml_service_array_to_string <yaml_array> [separator]" >&2
        return 2
    }

    local yaml_bin
    yaml_bin=$(lib_yaml_utils.check_yaml)
    if [ -z "$yaml_bin" ] || [ "$yaml_bin" = "/dev/null" ]; then
        echo "Error: yq not found in PATH" >&2
        return 127
    fi


    local expr
    expr=$(printf '.[] | "\\(.name)%s\\(.version)"' "$separator")
    echo "\"$(echo "$yaml_array" | "$yaml_bin" eval -r "$expr" - | paste -sd' ' -)\""
}



##################################################################
##################################################################

lib_yaml_utils.setenv_app_values(){

    local yaml_file=$1
    local env_file=$2

    lib_yaml_utils.value_to_env "APP_LONG_NAME" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.long_name" "cod-app")" >> "$env_file"
    lib_yaml_utils.value_to_env "APP_SHORT_NAME" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.short_name" "app")" >> "$env_file"
    lib_yaml_utils.value_to_env "APP_PROJECT_VERSION" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.project.version" "1.0")" >> "$env_file"
    lib_yaml_utils.value_to_env "APP_PROJECT_TAG" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.project.tag" "1.0.0")" >> "$env_file"
    # lib_yaml_utils.value_to_env "APP_PROJECT_SGBD" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.project.sgbd" "postgresql")" >> "$env_file"
    
    # yaml_array=$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.project.sgbd_exclude_array" "")
    # string_array=$(lib_yaml_utils.yaml_array_to_string "$yaml_array")
    # lib_yaml_utils.value_to_env "APP_PROJECT_SGBD_EXCLUDE_ARRAY" "${string_array}" >> "$env_file"

    yaml_array=$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.domain_name_array" "")
    string_array=$(lib_yaml_utils.yaml_array_to_string "$yaml_array")
    string_array_raw="${string_array//\"/}"
    order=$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.domain_name_order" "asc")
    separator=$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.domain_name_separator" ".")
    domain_name=$(lib_yaml_utils.join_array "${string_array_raw}" "${order}" "${separator}")
    lib_yaml_utils.value_to_env "APP_DOMAIN_NAME" "${domain_name}" >> "$env_file"
    order=$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.package_name_order" "desc")
    separator=$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.package_name_separator" ".")
    package_name=$(lib_yaml_utils.join_array "${string_array_raw}" "${order}" "${separator}")
    lib_yaml_utils.value_to_env "APP_PACKAGE_NAME" "${package_name}" >> "$env_file"
    order=$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.package_path_order" "desc")
    separator=$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.package_path_separator" "/")
    package_path=$(lib_yaml_utils.join_array "${string_array_raw}" "${order}" "${separator}")
    lib_yaml_utils.value_to_env "APP_PACKAGE_PATH" "${package_path}" >> "$env_file"

    # lib_yaml_utils.value_to_env "APP_FILES_BASE_FOLDER" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.files.base_folder" "data")" >> "$env_file"
    # yaml_array=$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.files.subfolder_array" "")
    # string_array=$(lib_yaml_utils.yaml_array_to_string "$yaml_array")
    # lib_yaml_utils.value_to_env "APP_FILES_SUBFOLDER_ARRAY" "${string_array}" >> "$env_file"

    yaml_array=$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.service_array" "")
    separator=$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.service_name_version_separator" "/")
    string_array=$(lib_yaml_utils.yaml_service_array_to_string "$yaml_array" "$separator")
    lib_yaml_utils.value_to_env "APP_SERVICE_ARRAY" "${string_array}" >> "$env_file"

}


lib_yaml_utils.setenv_app_expanded_values(){

    local yaml_file=$1
    local env_file=$2

    app_long_name="$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.long_name" "cod-app")"
    app_short_name="$(lib_yaml_utils.get_yaml_key "$yaml_file" "app.short_name" "app")"

    app_long_name_spinal=$app_long_name
    app_short_name_spinal=$app_short_name

    app_long_name_upper=$(lib_string_utils.spinal_to_upper $app_long_name_spinal)
    app_long_name_lower=$(lib_string_utils.spinal_to_lower $app_long_name_spinal)
    app_long_name_camel=$(lib_string_utils.spinal_to_camelcase $app_long_name_spinal)
    app_short_name_upper=$(lib_string_utils.spinal_to_upper $app_short_name_spinal)
    app_short_name_lower=$(lib_string_utils.spinal_to_lower $app_short_name_spinal)
    app_short_name_camel=$(lib_string_utils.spinal_to_camelcase $app_short_name_spinal)

    lib_yaml_utils.value_to_env "APP_LONG_NAME_SPINAL" "$app_long_name_spinal" >> "$env_file"
    lib_yaml_utils.value_to_env "APP_SHORT_NAME_SPINAL" "$app_short_name_spinal" >> "$env_file"
    lib_yaml_utils.value_to_env "APP_LONG_NAME_UPPER" "$app_long_name_upper" >> "$env_file"
    lib_yaml_utils.value_to_env "APP_LONG_NAME_LOWER" "$app_long_name_lower" >> "$env_file"
    lib_yaml_utils.value_to_env "APP_LONG_NAME_CAMEL" "$app_long_name_camel" >> "$env_file"
    lib_yaml_utils.value_to_env "APP_SHORT_NAME_UPPER" "$app_short_name_upper" >> "$env_file"
    lib_yaml_utils.value_to_env "APP_SHORT_NAME_LOWER" "$app_short_name_lower" >> "$env_file"
    lib_yaml_utils.value_to_env "APP_SHORT_NAME_CAMEL" "$app_short_name_camel" >> "$env_file"


}


lib_yaml_utils.setenv_docker_values(){

    local yaml_file=$1
    local env_file=$2

    lib_yaml_utils.value_to_env "DOCKER_CUSTOM_USERNAME_ON_INSTALL" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "docker.custom_username_on_install" "changeit")" >> "$env_file"
    lib_yaml_utils.value_to_env "DOCKER_CUSTOM_USERID" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "docker.custom_userid" "1000")" >> "$env_file"
    lib_yaml_utils.value_to_env "DOCKER_FILE_MAINTAINER" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "docker.file_maintainer" "Govern de les Illes Balears <govern@ib.es>")" >> "$env_file"

}


##################################################################################################################################
##################################################################################################################################


# lib_yaml_utils.setenv_python_values(){

#     local yaml_file=$1
#     local env_file=$2

#     lib_yaml_utils.value_to_env "PYTHON_PATH" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "python.path" "/usr/bin")" >> "$env_file"

# }


# lib_yaml_utils.setenv_python_app_values(){

#     local yaml_file=$1
#     local env_file=$2

#     lib_yaml_utils.value_to_env "PYTHON_APP_VENV" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "python-app.venv" "venv-scripts")" >> "$env_file"
#     lib_yaml_utils.value_to_env "PYTHON_APP_VERSION" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "python-app.version" "3.11")" >> "$env_file"
#     python_target_name=$(lib_yaml_utils.get_yaml_key "$yaml_file" "python-app.target_name" "local")
#     lib_yaml_utils.value_to_env "PYTHON_APP_TARGET_NAME" "$python_target_name" >> "$env_file"

#     base_path_key="python.target.${python_target_name}.base_path"
#     lib_yaml_utils.value_to_env "PYTHON_APP_BASE_PATH" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "${base_path_key}" "./")" >> "$env_file"
#     venv_prefix_key="python.target.${python_target_name}.venv-prefix"
#     lib_yaml_utils.value_to_env "PYTHON_APP_VENV_PREFIX" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "${venv_prefix_key}" "./")" >> "$env_file"
#     lib_yaml_utils.value_to_env "PYTHON_APP_ENABLED" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "python-app.enabled" "true")" >> "$env_file"
# }


# lib_yaml_utils.setenv_python_scripts_values(){

#     local yaml_file=$1
#     local env_file=$2

    
#     lib_yaml_utils.value_to_env "PYTHON_SCRIPTS_VENV" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "python-scripts.venv" "venv-scripts")" >> "$env_file"
#     lib_yaml_utils.value_to_env "PYTHON_SCRIPTS_VERSION" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "python-scripts.version" "3.11")" >> "$env_file"
#     python_target_name=$(lib_yaml_utils.get_yaml_key "$yaml_file" "python-scripts.target_name" "local")
#     lib_yaml_utils.value_to_env "PYTHON_SCRIPTS_TARGET_NAME" "$python_target_name" >> "$env_file"

#     base_path_key="python.target.${python_target_name}.base_path"
#     lib_yaml_utils.value_to_env "PYTHON_SCRIPTS_BASE_PATH" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "${base_path_key}" "./")" >> "$env_file"
#     venv_prefix_key="python.target.${python_target_name}.venv-prefix"
#     lib_yaml_utils.value_to_env "PYTHON_SCRIPTS_VENV_PREFIX" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "${venv_prefix_key}" "./")" >> "$env_file"
#     lib_yaml_utils.value_to_env "PYTHON_SCRIPTS_ENABLED" "$(lib_yaml_utils.get_yaml_key "$yaml_file" "python-scripts.enabled" "false")" >> "$env_file"    
# }


##################################################################
##################################################################

lib_yaml_utils.yaml_to_env(){
    
    echo ""
    echo "[$(date +"%Y-%m-%d %T")] Creating .env from settings.yaml..."
    echo ""
    
    local yaml_file=$1
    local env_file=$2

    if [ -f "$yaml_file" ]; then
        echo "Found $yaml_file"

        lib_yaml_utils.setenv_app_values "$yaml_file" "$env_file"
        lib_yaml_utils.setenv_app_expanded_values "$yaml_file" "$env_file"
        lib_yaml_utils.setenv_docker_values "$yaml_file" "$env_file"
        # lib_yaml_utils.setenv_python_values "$yaml_file" "$env_file"
        # lib_yaml_utils.setenv_python_scripts_values "$yaml_file" "$env_file"
        # lib_yaml_utils.setenv_python_app_values "$yaml_file" "$env_file"
    
    else
        echo "Error: YAML file not found: $yaml_file"
    fi

    echo "[$(date +"%Y-%m-%d %T")] Transformed $yaml_file to .env..."

}

##################################################################
##################################################################

lib_yaml_utils.setenv(){
   

    if [[ $(lib_yaml_utils.check_yaml) != "/dev/null" ]]; then
        touch .environment
        for FILE in settings.yaml; do
            if [[ ${FILE} == *.backup ]]
            then
                echo "Skiping backup file: "$FILE
            else
                echo "Loading: "$FILE
                echo $'\n' >> .environment
                lib_yaml_utils.yaml_to_env $FILE .environment
            fi
        done
        mv .environment .env
        echo ""
    else
        echo "Error: yq is not installed. Please install yq to proceed."
        echo "You can install yq by following the instructions at https://github.com/mikefarah/yq#install"
    fi

}



##################################################################
##################################################################



lib_yaml_utils.loadenv(){

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

lib_yaml_utils.loaded(){
    echo lib_yaml_utils.sh loaded
    echo lib_string_utils.sh may be required
}

