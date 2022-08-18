#!/usr/bin/env bash


THIS="${BASH_SOURCE[0]##*/}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

VOLUME_DIR="${SCRIPT_DIR}/.."

VOLUME_JENKINS_DATA="${VOLUME_DIR}/jenkins-data"

VOLUMES=(
  "${VOLUME_JENKINS_DATA}"
  "${VOLUME_DIR}/jenkins-docker-certs"
)

SSH_QE_TAR="${SCRIPT_DIR}/../ssh.qe.tar"

SETUP=0
TEARDOWN=0
REMOVE_VOLUMES=0
PRUNE=0

DOCKER_DIND_HOST_PORT="2376"
JENKINS_HOST_PORT_1="9000"
JENKINS_HOST_PORT_2="50000"

function options_menu(){
    HELP_STR="""
      Program: ${THIS}

      Description:
          This script bootstraps jenkins.

      ./bin/${THIS}

          Options:
              --setup                           : Bring up Jenkins in Docker
              --teardown                        : Teardown Jenkins in Docker
              --remove-volumes                  : Deletes all Docker volumes
              --prune                           : Similar to docker prune
                                                  This will remove:
                                                    - all stopped containers
                                                    - all networks not used by at least one container
                                                    - all images without at least one container associated to them
                                                    - all build cache
                                                    - all volumes not used by at least one container

      Examples:
        1. Help message
            ./bin/${THIS} --help

        2. To Bring up Jenkins in Docker
           ./bin/${THIS} --setup

        3. To Teardown Jenkins in Docker
           ./bin/${THIS} --teardown

        4. To remove mounted volumes from system
           ./bin/${THIS} --remove-volumes

        4. To Prune
            ./bin/${THIS} --prune

"""
    echo "${HELP_STR}"
}

function parse_command_line_arguments(){
    while [[ $# -gt 0 ]]; do
        key="$1"
        shift

        case $key in
            --setup)
                SETUP=1
                ;;

            --teardown)
                TEARDOWN=1
                ;;

            --remove-volumes)
                REMOVE_VOLUMES=1
                ;;

            --prune)
                PRUNE=1
                ;;

            -h|--help)
                options_menu
                exit 1
                ;;

            *)
                echo "ERROR: Unknown option: $1" >&2
                exit 1
                ;;
        esac
    done
}

#export "VOLUME_DIR=${VOLUME_DIR}"

function setup() {
#    teardown
    #[[ ! -f "${SSH_QE_TAR}" ]] && echo "ssh.qe.tar file not provided in root directory of the project... exiting" && exit 1
    for volume in "${VOLUMES[@]}"; do
      echo "${volume}"
      mkdir -p "${volume}"
    done
    sudo groupadd -g 1000 -r jenkins
    sudo useradd  -u 1000 -g jenkins -M -r -d "${VOLUME_JENKINS_DATA}" -s /bin/bash -c 'Jenkins User' jenkins
    sudo chown -R jenkins:jenkins "${VOLUME_JENKINS_DATA}"
    sudo docker-compose up -d
}

function teardown() {
    sudo docker-compose down
    sudo docker image rm jenkins-image:2.332.2
    sudo docker image rm docker:dind
}

function prune() {
    echo "y" | sudo docker system prune -a
    echo "y" | sudo docker system prune -a --volumes
}

function remove_volumes() {
    for volume in "${VOLUMES[@]}"; do
      printf "\nrm -rf %s\n" "${volume}"
        sudo rm -rf ${volume}
    done
}

##
# Main
##
parse_command_line_arguments "$@"
DOCKER_COMPOSE_ENV_VARS="""
VOLUME_DIR=${VOLUME_DIR}
DOCKER_DIND_HOST_PORT=${DOCKER_DIND_HOST_PORT}
JENKINS_HOST_PORT_1=${JENKINS_HOST_PORT_1}
JENKINS_HOST_PORT_2=${JENKINS_HOST_PORT_2}

"""
echo "${DOCKER_COMPOSE_ENV_VARS}" > "${SCRIPT_DIR}/../.env"
[[ ${SETUP} -eq 1 ]] && setup
[[ ${TEARDOWN} -eq 1 ]] && teardown
[[ ${REMOVE_VOLUMES} -eq 1 ]] && remove_volumes
[[ ${PRUNE} -eq 1 ]] && prune
