#!/bin/bash

readonly SCRIPT_VERSION=0.1.0
readonly REPO_DIR=template
readonly REPO_NAME=helm-template
readonly BRANCH=main
readonly NAMESPACE=nicholaswilde
readonly CHARTS_DIR=charts

# Get the directory the script is in.
# https://stackoverflow.com/a/246128/1061279
CHARTS_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/${CHARTS_DIR}"
readonly CHARTS_PATH
SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME
readonly URL="https://github.com/${NAMESPACE}/${REPO_NAME}/archive/${BRANCH}.tar.gz"

# Display Help
function help(){
  echo "Init a helm chart from a template."
  echo
  usage
  echo "options:"
  echo "  -h     Print this Help."
  echo "  -v     Print script version and exit."
}

# Show the usage
function usage() {
  echo "Usage: ${SCRIPT_NAME} [REPOSITORY:TAG|-h|-v]"
}

# Echo usageerror if something isn't right.
function usageerror() {
  usage
  echo ""
  echo "Try ${SCRIPT_NAME} -h for more options."
  exit 1
}

# Parse the repository:tag argument
function parse(){
  if [[ $# == 0 ]]; then
    echo "${SCRIPT_NAME}: missing repository and tag"
    usageerror
  fi
  echo "Parsing arguments"
  eval REPOSITORY="$(echo "$1" | awk -F ":" '{print $1}')"
  eval CHART_NAME="$(basename "$1"|awk -F ":" '{print $1}')"
  eval CHART_PATH="${CHARTS_PATH}/${CHART_NAME}"
  eval TAG="$(basename "$1"|awk -F ":" '{print $2}')"
  eval VERSION="$(echo "${TAG}"|awk -F "-" '{print $1}')"
  if [ -z "${REPOSITORY}" ]; then
    echo "${SCRIPT_NAME}: missing repository"
    usageerror
  fi
  if [ -z "${CHART_NAME}" ]; then
    echo "${SCRIPT_NAME}: missing chart name"
    usageerror
  fi
  if [ -z "${TAG}" ]; then
    echo "${SCRIPT_NAME}: missing tag"
    usageerror
  fi
  # shellcheck disable=SC2153
  if [ -z "${CHART_PATH}" ]; then
    echo "${SCRIPT_NAME}: missing chart path"
    usageerror
  fi
  if [ -z "${VERSION}" ]; then
    echo "${SCRIPT_NAME}: missing version"
    usageerror
  fi
  echo "  REPOSITORY: ${REPOSITORY}"
  echo "  CHART_NAME: ${CHART_NAME}"
  echo "  CHART_PATH: ${CHART_PATH}"
  echo "  TAG:        ${TAG}"
  echo "  PORT:       ${PORT}"
  echo "  VERSION:    ${VERSION}"
  [ -n "${PORT}" ] && echo "  PORT:       ${PORT}"
}

# Do a bunch of checks
function checks(){
  echo "Doing checks"
  # Check if chart dir exists
  if [ -d "${CHART_PATH}" ]; then
    echo "Chart already exists, ${CHART_PATH}"
    exit 1
  fi

  # Check if yq is installed
  if ! command -v yq &> /dev/null; then
    echo "yq is not installed"
    exit 1
  fi
}

# Download the template
function download(){
  echo "Downloading template"
  local temp_dir
  temp_dir=$(mktemp -d)
  # https://stackoverflow.com/a/687052/1061279
  trap 'rm -rf -- "$temp_dir"' EXIT
  cd "${temp_dir}" || exit 1
  wget -qO- "${URL}" | tar -xz
  cp -r "${REPO_NAME}"-"${BRANCH}"/"${REPO_DIR}"/ "${CHART_PATH}"
}

# Update Chart.yaml
function updatechart(){
  echo "Updating Chart.yaml"
  local chart_file_path
  chart_file_path="${CHART_PATH}"/Chart.yaml
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
  echo "Updating values.yaml"
  local values_path
  values_path="${CHART_PATH}"/values.yaml
  # repository
  yq e ".image.repository=\"${REPOSITORY}\"" -i "${values_path}"
  # tag
  yq e ".image.tag=\"${TAG}\"" -i "${values_path}"
  # ingress
  yq e ".ingress.hosts[0].host=\"${CHART_NAME}.192.168.1.203.nip.io\"" -i "${values_path}"
  # Add the three hyphens to the top of the file
  sed -i '1i ---' "${values_path}"
}

# main function
function main(){
  parse "$@"
  checks "$@"
  download
  updatechart
  updatevalues
}

# https://www.jamescoyle.net/how-to/1774-bash-getops-example
# https://opensource.com/article/19/12/help-bash-program
# Get the options
while getopts ":hv" o; do
  case "${o}" in
    h) # display Help
      help
      exit 0;;
    v)
      echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
      exit 0;;
    \?) # incorrect option
      usageerror;;
  esac
done

# https://unix.stackexchange.com/a/214151/93726
shift "$((OPTIND-1))"

main "$@"
