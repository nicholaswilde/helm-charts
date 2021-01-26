#/bin/bash

VERSION=0.1.0
#REPO_DIR=template
#REPO_NAME=helm-template
#BRANCH=main
#NAMESPACE=nicholaswilde
CHARTS_DIR=charts

# Get the directory the script is in.
# https://stackoverflow.com/a/246128/1061279
CHARTS_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/${CHARTS_DIR}"

function help(){
   # Display Help
  echo "Update a helm chart."
  echo
  usage
  echo "options:"
  echo "  -h     Print this Help."
  echo "  -v     Print script version and exit."
}

function usage() {
  echo "Usage: $0 [REPOSITORY:TAG|-h|-v]"
}

# Echo usageerror if something isn't right.
function usageerror() {
  usage
  echo ""
  echo "Try $0 -h for more options."
  exit 1
}

function parse(){
  if [[ $# == 0 ]]; then
    echo "$0: missing repository and tag"
    usageerror
  fi
  echo "Parsing arguments"
  eval REPOSITORY=$(echo $1 | awk -F ":" '{print $1}')
  eval CHART_NAME=$(echo $(basename $1)|awk -F ":" '{print $1}')
  eval CHART_PATH="${CHARTS_PATH}/${CHART_NAME}"
  eval TAG=$(echo $(basename $1)|awk -F ":" '{print $2}')
  eval VERSION=$(echo ${TAG}|awk -F "-" '{print $1}')
  if [ -z "${REPOSITORY}" ]; then
    echo "$0: missing repository"
    usageerror
  fi
  if [ -z "${CHART_NAME}" ]; then
    echo "$0: missing chart name"
    usageerror
  fi
  if [ -z "${TAG}" ]; then
    echo "$0: missing tag"
    usageerror
  fi
  if [ -z "${CHART_PATH}" ]; then
    echo "$0: missing chart path"
    usageerror
  fi
  if [ -z "${VERSION}" ]; then
    echo "$0: missing version"
    usageerror
  fi
  echo "  REPOSITORY: ${REPOSITORY}"
  echo "  CHART_NAME: ${CHART_NAME}"
  echo "  CHART_PATH: ${CHART_PATH}"
  echo "  TAG:        ${TAG}"
  echo "  VERSION:    ${VERSION}"
}

# Do a bunch of checks
function checks(){
  echo "Doing checks"
  # Check if chart dir exists
  if [ ! -d "${CHART_PATH}" ]; then
    echo "Chart does not exist, ${CHART_NAME}"
    exit 1
  fi

  # Check if yq is installed
  if ! command -v yq &> /dev/null; then
    echo "yq is not installed"
    exit 1
  fi

  # Check if no arguments were supplied.
  if [ -z "$1" ]; then
    echo "No argument supplied"
    exit 1
  fi
}

function updatechart(){
  echo "Updating Chart.yaml"
  local CHART_FILE_PATH="${CHART_PATH}"/Chart.yaml
  # appVersion
  yq e ".appVersion=\"${VERSION}\"" -i "${CHART_FILE_PATH}"
  # home
  local HOME=$(yq e ".home" "${CHART_FILE_PATH}")
  if [[ "${HOME: -1}" == '/' ]]; then
    local HOME="${HOME::-1}"
  fi
  local HOME="${HOME}/${CHART_NAME}"
  yq e ".home=\"${HOME}\"" -i "${CHART_FILE_PATH}"
  # name
  yq e ".name=\"${CHART_NAME}\"" -i "${CHART_FILE_PATH}"
  # Add the three hyphens to the top of the file
  sed  -i '1i ---' "${CHART_FILE_PATH}"
}

function updatevalues(){
  echo "Updating values.yaml"
  local VALUES_PATH="${CHART_PATH}"/values.yaml
  yq e ".image.repository=\"${REPOSITORY}\"" -i "${VALUES_PATH}"
  yq e ".image.tag=\"${TAG}\"" -i "${VALUES_PATH}"
  # Add the three hyphens to the top of the file
  sed -i '1i ---' "${VALUES_PATH}"
}

function main(){
  parse "$@"
  checks "$@"
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
      echo "${0} version ${VERSION}"
      exit 0;;
    \?) # incorrect option
      echo "ERROR: Invalid option, ${OPTARG}"
      usageerror;;
  esac
done

# https://unix.stackexchange.com/a/214151/93726
shift "$((OPTIND-1))"

main "$@"
