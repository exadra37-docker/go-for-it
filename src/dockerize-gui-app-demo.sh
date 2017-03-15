#!/bin/bash
# @package exadra37-docker-images/dockerize-graphical-user-interface-app-demo
# @link    https://gitlab.com/u/exadra37-docker-images/dockerize-graphical-user-interface-app-demo
# @since   12 March 2017
# @license GPL-3.0
# @author  Exadra37(Paulo Silva) <exadra37ingmailpointcom>
#
# Social Links:
# @link    Auhthor:  https://exadra37.com
# @link    Gitlab:   https://gitlab.com/Exadra37
# @link    Github:   https://github.com/Exadra37
# @link    Linkedin: https://uk.linkedin.com/in/exadra37
# @link    Twitter:  https://twitter.com/Exadra37

set -e

########################################################################################################################
# Functions
########################################################################################################################

    function Print_Text_With_Label()
    {
        local _label_text="${1}"

        local _text="${2}"

        local _label_background_color="${3:-42}"

        local _text_background_color="${4:-229}"

        printf "\n\e[1;${_label_background_color}m ${_label_text}:\e[30;48;5;${_text_background_color}m ${_text} \e[0m \n"
    }

    function Display_Help()
    {
        Print_Text_With_Label  "Show Help" "./dgad -h" 100

        Print_Text_With_Label  "Build Docker Image locally" "./dgad -l" 100

        Print_Text_With_Label "Run" "./dgad"
    }

    # @link http://wiki.ros.org/docker/Tutorials/GUI#The_isolated_way
    function Setup_X11_Server_Authority()
    {
        ### VARIABLES ARGUMENTS ###

            local _x11_authority_file="${1?}"


        ### EXECUTION ###

            # Setup X11 server authentication
            touch "${_x11_authority_file}" &&
            xauth nlist "${DISPLAY}" | sed -e 's/^..../ffff/' | xauth -f "${_x11_authority_file}" nmerge - &&
            chmod 644 "${_x11_authority_file}"
    }

    function Docker_Image_Does_Not_Exist()
    {
        ### VARIABLES ARGUMENTS ###

            local _image_name="${1?}"


        ### EXECUTION ####

            # On empty result means we do not have the image...
            if [ -z $( sudo docker images -q "${_image_name}" ) ]
                then
                    # Image does not exist
                    return 0
            fi

            # Image exist
            return 1
    }

    function Docker_Build()
    {
        ### VARIABLES DEFAULTS ###

            local _default_build_context=$(dirname $(readlink -f $0))/../build


        ### VARIABLES ARGUMENTS ###

            local _image_name="${1?}"

            local _image_tag="${2:-latest}"

            local _build_context="${3:-$_default_build_context}"


        ### EXECUTION ###

            sudo docker build \
                    --tag "${_image_name}:${_image_tag}" \
                    "${_build_context}"
    }


    function Docker_Run()
    {
        ### VARIABLES DEFAULTS ###

            local _timestamp=$( date +"%s" )


        ### VARIABLES ARGUMENTS ###

            local _image_name="${1?}"

            local _repository_name="${2?}"

            local _container_user="${3?}"

            local _x11_socket="${4?}"

            local _x11_authority_file="${5?}"


        ### VARIABLES COMPOSITION ###

            local _container_name="${_repository_name}_${_timestamp}"


        ### EXECUTION ###

            Print_Text_With_Label "Docker Image Name" "$_image_name" 40
            Print_Text_With_Label "Container Name" "$_container_name" 40
            Print_Text_With_Label "User in Container" "$_container_use" 40
            Print_Text_With_Label "X11 Socket" "$_x11_socket" 40
            Print_Text_With_Label "X11 Authority File" "$_x11_authority_file" 40

            Print_Text_With_Label "Go For It App" "Below the container output for executing the app..." 41 # red label

            # Run Container with X11 authentication and using same user in container and host
            # @link http://wiki.ros.org/docker/Tutorials/GUI#The_isolated_way
            #
            # Additional to the above tutorial:
            #   * x11_socket and x11_authority_file only have ready access to the Host, instead of ready and write.
            sudo docker run --rm -it \
                --name="${_container_name}" \
                --volume="${_x11_socket}":"${_x11_socket}":ro \
                --volume="${_x11_authority_file}":"${_x11_authority_file}":ro \
                --env="XAUTHORITY=${_x11_authority_file}" \
                --env="DISPLAY" \
                --user="${_container_user}" \
                "${_image_name}"
    }


########################################################################################################################
# Variables Defaults
########################################################################################################################

    local_build='false'

    x11_socket=/tmp/.X11-unix

    container_user="dockerize-gui-app"

    docker_image_name="exadra37/dockerize-graphical-user-interface-app-demo"


########################################################################################################################
# Variables Arguments
########################################################################################################################

    while getopts ':lh' flag; do
      case "${flag}" in
        l) local_build="${OPTARG}"; local_build="true"; docker_image_name="${docker_image_name}-local"; shift ;;
        h) Display_Help; exit 0 ;;
        \?) Print_Text_With_Label "Fatal Error" "Option -$OPTARG is not supported..." 41; exit 1 ;;
        :) Print_Text_With_Label "Fatal Error" "Option -$OPTARG requires a value..." 41; exit 1 ;;
      esac
    done


########################################################################################################################
# Variables Composition
########################################################################################################################

    repository_name="${docker_image_name##*/}"

    container_user_dir=/home/"$USER"/."${container_user}"/"${repository_name}"

    x11_authority_file="${container_user_dir}"/x11dockerize


########################################################################################################################
# Execution
########################################################################################################################

    mkdir -p "${container_user_dir}"

    # Setup X11 server bridge between host and container
    Setup_X11_Server_Authority "${x11_authority_file}"

    if [ "true" = "${local_build}" ] && Docker_Image_Does_Not_Exist "${docker_image_name}"
        then
            Docker_Build "${docker_image_name}"
    fi

    Docker_Run "${docker_image_name}" \
               "${repository_name}" \
               "${container_user}" \
               "${x11_socket}" \
               "${x11_authority_file}"

    Display_Help
