#!/bin/bash
# Author: Nicholas Wilde <ncwilde43@gmail.com>
#
# Notes:
#   - YAML format is not preserved with yq (blank lines are removed).
#     See https://github.com/mikefarah/yq/issues/515
#
# Todo:
#   - Add the port argument.
#   - Update artifact.io annotations in Chart.yaml

readonly SCRIPT_VERSION=0.1.0
readonly REPO_DIR=template
readonly REPO_NAME=helm-template
readonly BRANCH=main
readonly NAMESPACE=nicholaswilde
readonly CHARTS_DIR=charts

# Get the directory the script is in.
# https://stackoverflow.com/a/246128/1061279
CHARTS_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/${CHARTS_DIR}"
SCRIPT_NAME="$(basename "${0}")"
readonly CHARTS_PATH
readonly SCRIPT_NAME
readonly URL="https://github.com/${NAMESPACE}/${REPO_NAME}/archive/${BRANCH}.tar.gz"
readonly SCRIPT_DESC="Init a helm chart from a template."


# to int
function to_int() {
    local -i num="10#${1}"
    echo "${num}"
}

# Check if the port is not okay
# https://docwhat.org/bash-checking-a-port-number
function port_not_ok() {
    local port="$1"
    local -i port_num
    port_num=$(to_int "${port}" 2>/dev/null)
    (( "${port_num}" < 1 || "${port_num}" > 65535 ))
}

# Check if variable is null
# Returns true if empty
function is_null(){
  [ -z "${1}" ]
}

# Check if directory exists
function dir_exists(){
  [ -d "${1}" ]
}

# Check if command exists
function command_exists(){
  command -v "${1}" &> /dev/null
}

# Check if variable is set
# Returns false if empty
function is_set(){
  [ -n "${1}" ]
}

function show_usage(){
  printf "Usage: %s [-p PORT] [-h|-v] REPOSITORY:TAG\n" "${SCRIPT_NAME}"
}

function script_desc(){
  printf "%s\n\n" "${SCRIPT_DESC}"
}

# Display Help
function help(){
  show_usage
  script_desc
  printf "Mandatory arguments:\n"
  printf "  REPOSITORY:TAG  The repository and tag of the image to be updated\n\n"
  printf ""
  printf "Options:\n"
  printf "  -p PORT         Port number to use\n"
  printf "  -h              Print this Help.\n"
  printf "  -v              Print script version and exit.\n"
  exit 0
}

# printf usage_error if something isn't right.
function usage_error() {
  show_usage
  printf "\nTry %s -h for more options.\n" "${SCRIPT_NAME}" >&2
  exit 1
}

function show_version(){
  printf "%s version %s\n" "${SCRIPT_NAME}" "${SCRIPT_VERSION}"; exit 0
}

# Parse the repository:tag argument
function parse(){
  printf "Parsing arguments\n"
  eval REPOSITORY="$(echo "$1" | awk -F ":" '{print $1}')"
  eval CHART_NAME="$(basename "$1"|awk -F ":" '{print $1}')"
  eval CHART_PATH="${CHARTS_PATH}/${CHART_NAME}"
  eval TAG="$(basename "$1"|awk -F ":" '{print $2}')"
  eval VERSION="$(echo "${TAG}"|awk -F "-" '{print $1}')"
  is_null "${REPOSITORY}" && printf "%s: missing repository\n" "${SCRIPT_NAME}" && usage_error
  is_null "${CHART_NAME}" && printf "%s: missing chart name\n" "${SCRIPT_NAME}" && usage_error
  is_null "${TAG}" && printf "%s: missing tag\n" "${SCRIPT_NAME}"               && usage_error
  # shellcheck disable=SC2153
  is_null "${CHART_PATH}" && printf "%s: missing chart path\n" "${SCRIPT_NAME}" && usage_error
  is_null "${VERSION}"    && printf "%s: missing version\n" "${SCRIPT_NAME}"    && usage_error
  printf "  REPOSITORY: %s\n" "${REPOSITORY}"
  printf "  CHART_NAME: %s\n" "${CHART_NAME}"
  printf "  CHART_PATH: %s\n" "${CHART_PATH}"
  printf "  TAG:        %s\n" "${TAG}"
  printf "  PORT:       %s\n" "${PORT}"
  printf "  VERSION:    %s\n" "${VERSION}"
}

# Do a bunch of checks
function checks(){
  printf "Doing checks\n"
  # Check if chart dir exists
  dir_exists "${CHART_PATH}" && printf "Chart already exists, %s\n" "${CHART_PATH}" >&2 && exit 1

  # Check if yq is not installed
  ! command_exists yq && printf "yq is not installed\n" >&2 && exit 1
}

# Download the template
function download(){
  printf "Downloading template\n"
  local temp_dir
  temp_dir="$(mktemp -d)"
  # https://stackoverflow.com/a/687052/1061279
  trap 'rm -rf -- "$temp_dir"' EXIT
  cd "${temp_dir}" || exit 1
  wget -qO- "${URL}" | tar -xz
  cp -r "${REPO_NAME}"-"${BRANCH}"/"${REPO_DIR}"/ "${CHART_PATH}"
}

# Update Chart.yaml
function updatechart(){
  printf "Updating Chart.yaml\n"
  local chart_file_path
  chart_file_path="${CHART_PATH}/Chart.yaml"
  # appVersion
  yq e ".appVersion=\"${VERSION}\"" -i "${chart_file_path}"
  # home
  local home
  home="$(yq e ".home" "${chart_file_path}")"
  if [[ "${home: -1}" == '/' ]]; then
    home="${home::-1}"
  fi
  home="${home}/${CHART_NAME}"
  yq e ".home=\"${home}\"" -i "${chart_file_path}"
  # name
  yq e ".name=\"${CHART_NAME}\"" -i "${chart_file_path}"
  # Add the three hyphens to the top of the file
  sed -i '1i ---' "${chart_file_path}"
}

# Update values.yaml
function updatevalues(){
  printf "Updating values.yaml\n"
  local values_path
  values_path="${CHART_PATH}/values.yaml"
  # repository
  yq e ".image.repository=\"${REPOSITORY}\"" -i "${values_path}"
  # tag
  yq e ".image.tag=\"${TAG}\"" -i "${values_path}"
  # ingress
  yq e ".ingress.hosts[0].host=\"${CHART_NAME}.192.168.1.203.nip.io\"" -i "${values_path}"
  # Update the port number
  update_port "${values_path}"
  # Add the three hyphens to the top of the file
  sed -i '1i ---' "${values_path}"
}

# Update the port number
function update_port(){
  local values_path
  values_path="${1}"
  is_null "${PORT}" && return
  printf "  Updating port to %s\n" "${PORT}"
  yq e ".service.port.port=\"${PORT}\"" -i "${values_path}"
}

# main function
function main(){
  parse "$1"
  checks "$1"
  download
  updatechart
  updatevalues
}

case "$#" in
  0) usage_error;;
esac

# https://www.jamescoyle.net/how-to/1774-bash-getops-example
# https://opensource.com/article/19/12/help-bash-program
# Get the options
while getopts "p:hv" o; do
  case "${o}" in
    h)  help;;
    v)  show_version;;
    p)  PORT="${OPTARG}"
        port_not_ok "${PORT}" && printf "Invalid port number, %s\n" "${PORT}" && usage_error;;
    \?) usage_error;;
  esac
done

# https://unix.stackexchange.com/a/214151/93726
shift "$((OPTIND-1))"

main "$1"
