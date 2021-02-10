#!/bin/bash
# Author: Nicholas Wilde <ncwilde43@gmail.com>
#
# Todo:
#   - Update artifact.io annotations in Chart.yaml
#   - Add helm-docs and git commit

SCRIPT_VERSION="0.1.1"
CHARTS_DIR="charts"

# Get the directory the script is in.
# https://stackoverflow.com/a/246128/1061279
CHARTS_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/${CHARTS_DIR}"
SCRIPT_NAME="$(basename "${0}")"
SCRIPT_DESC="Update a helm chart"
readonly CHARTS_PATH
readonly SCRIPT_NAME
readonly SCRIPT_DESC

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
  printf "Usage: %s [-h|-v] REPOSITORY:TAG [<patch>|minor|major]\n" "${SCRIPT_NAME}"
}

function script_desc(){
  printf "%s\n\n" "${SCRIPT_DESC}"
}

# Show the help
function show_help(){
  show_usage
  script_desc
  printf "Mandatory arguments:\n"
  printf "  REPOSITORY:TAG      The repository and tag of the image to be updated\n\n"
  printf "Optional arguments:\n"
  printf "  <patch>|minor|major Semver bump type. Default is patch.\n\n"
  printf "Options:\n"
  printf "  -h                  Print this Help.\n"
  printf "  -v                  Print script version and exit.\n"
  exit 0
}

function show_version(){
  printf "%s version %s\n" "${SCRIPT_NAME}" "${SCRIPT_VERSION}"; exit 0
}

# printf usage_error if something isn't right.
function usage_error() {
  show_usage
  printf "\nTry %s -h for more options.\n" "${SCRIPT_NAME}" >&2
  exit 1
}

# Parse
function parse(){
  printf "Parsing inputs\n"
  eval REPOSITORY="$(echo "$1" | awk -F ":" '{print $1}')"
  eval CHART_NAME="$(basename "$1"|awk -F ":" '{print $1}')"
  eval CHART_PATH="${CHARTS_PATH}/${CHART_NAME}"
  eval TAG="$(basename "$1"|awk -F ":" '{print $2}')"
  eval APP_VERSION="$(echo "${TAG}"|awk -F "-" '{print $1}')"
  is_null "${REPOSITORY}" 	&& printf "%s: missing repository\n" "${SCRIPT_NAME}" 	&& usage_error
  is_null "${CHART_NAME}" 	&& printf "%s: missing chart name\n" "${SCRIPT_NAME}" 	&& usage_error
  is_null "${TAG}"        	&& printf "%s: missing tag\n" "${SCRIPT_NAME}"        	&& usage_error
  # shellcheck disable=SC2153
  is_null "${CHART_PATH}" 	&& printf "%s: missing chart path\n" "${SCRIPT_NAME}" 	&& usage_error
  is_null "${APP_VERSION}" 	&& printf "%s: missing app version\n" "${SCRIPT_NAME}"  && usage_error
  printf "  REPOSITORY:   %s\n" "${REPOSITORY}"
  printf "  CHART_NAME:   %s\n" "${CHART_NAME}"
  printf "  CHART_PATH:   %s\n" "${CHART_PATH}"
  printf "  TAG:          %s\n" "${TAG}"
  printf "  APP_VERSION:  %s\n" "${APP_VERSION}"
  printf "  BUMP:         %s\n" "${BUMP}"
}

# Do a bunch of checks
function checks(){
  printf "Doing checks\n"
  ! dir_exists  "${CHART_PATH}" && printf "Chart does not exist, %s\n" "${CHART_NAME}" >&2 && exit 1
  ! command_exists yq     && printf "yq is not installed\n" && exit 1
  ! command_exists semver && printf "semver is not installed\n" >&2 && exit 1
}

# Update the Chart.yaml
function update_chart(){
  printf "Updating Chart.yaml\n"
  local chart_file_path="${CHART_PATH}/Chart.yaml"
  # appVersion
  yq e ".appVersion=\"${APP_VERSION}\"" -i "${chart_file_path}"
  bump_ver "${chart_file_path}"
  # Add the three hyphens to the top of the file
  sed  -i '1i ---' "${chart_file_path}"
}

# Bump the sem version
function bump_ver(){
  local chart_file_path="${1}"
  local current_chart_version
  current_chart_version="$(yq e ".version" "${chart_file_path}")"
  is_null "${current_chart_version}" && return
  local new_chart_version
  new_chart_version="$(semver bump "${BUMP}" "${current_chart_version}")"
  is_null "${new_chart_version}" && return
  printf "  Bumping chart version from %s to %s\n" "${current_chart_version}" "${new_chart_version}"
  yq e ".version=\"${new_chart_version}\"" -i "${chart_file_path}"
}

# Update values.yaml
function update_values(){
  printf "Updating values.yaml\n"
  local VALUES_PATH="${CHART_PATH}/values.yaml"
  yq e ".image.repository=\"${REPOSITORY}\"" -i "${VALUES_PATH}"
  yq e ".image.tag=\"${TAG}\"" -i "${VALUES_PATH}"
  # Add the three hyphens to the top of the file
  sed -i '1i ---' "${VALUES_PATH}"
}

# Main functions
function main(){
  parse "$@"
  checks "$@"
  update_chart
  update_values
}

case "$#" in
  0) usage_error;;
esac

# https://www.jamescoyle.net/how-to/1774-bash-getops-example
# https://opensource.com/article/19/12/help-bash-program
# Get the options
while getopts ":hv" o; do
  case "${o}" in
    h)  show_help;;
    v)  show_version;;
    \?) usage_error;;
  esac
done

# https://unix.stackexchange.com/a/214151/93726
shift "$((OPTIND-1))"
case "${2}" in
  "patch"|"minor"|"major")  BUMP="${2}";;
  "")                       BUMP="patch" ;;
  *)                        usage_error;;
esac
main "$1"
