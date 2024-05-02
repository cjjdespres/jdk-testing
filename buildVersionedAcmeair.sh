#!/bin/bash

# Arguments
VERSION=""
JDK_DIR=""

# Other constants (could be arguments too, I suppose)
ACMEAIR_TAG_BASE="acmeair-full"
LIBERTY_TAG_BASE="liberty"
JDK_TAG_BASE="semeruesque"

function displayHelp() {
  echo "Build a complete acmeair container from an existing JDK image."
  echo "This will build images:"
  echo "- ${ACMEAIR_TAG_BASE}:<version>"
  echo "- ${LIBERTY_TAG_BASE}:<version>"
  echo "- ${JDK_TAG_BASE}:<version>"
  echo ""
  echo "Parameters:"
  echo -n $'\t'; echo "--version=<STRING>"
  echo -n $'\t'; echo "    Version to use for the various images"
  echo -n $'\t'; echo "    Required."
  echo -n $'\t'; echo "    Example: --version=image-with-test-patch"
  echo -n $'\t'; echo "--jdk-dir=<PATH>"
  echo -n $'\t'; echo "    Path to the local directory of the JDK image to use when building the container image"
  echo -n $'\t'; echo "    Required."
  echo -n $'\t'; echo "    Example: --jdk-dir=/home/user/openj9-openjdk-jdk17/build/linux-x86_64-server-release/images/jdk/"
}

function failWith() {
  echo "Build failed: $1"
  exit 1
}

if [[ $# -eq 0 ]]; then
  displayHelp
  exit 0
fi

for i in "$@"; do
  case $i in
    --version=*)
      VERSION="${i#*=}"
      shift # past argument=value
      ;;
    --jdk-dir=*)
      JDK_DIR="${i#*=}"
      shift # past argument=value
      ;;
    -h|--help)
      displayHelp
      exit 0
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

if [[ $# -gt 0 ]] ; then
  echo "This script does not take positional arguments and one was provided"
  SHOULD_FAIL="YES"
fi

if [ -z ${VERSION} ]; then
  echo "Missing parameter --version=<string>"
  SHOULD_FAIL="YES"
fi
if [ -z ${JDK_DIR} ]; then
  echo "Missing parameter --jdk-dir=<string>"
  SHOULD_FAIL="YES"
fi

if [ -n "${SHOULD_FAIL}" ]; then
  failWith "Error(s) when checking build setup. See previous message(s) for details. Run this script without parameters for help."
fi

SCRIPT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

set -Eeox pipefail

JDK_TAG="${JDK_TAG_BASE}:${VERSION}"
LIBERTY_TAG="${LIBERTY_TAG_BASE}:${VERSION}"
JDK_DIR="${JDK_DIR}"
ACMEAIR_TAG="${ACMEAIR_TAG_BASE}:${VERSION}"
ACMEAIR_BASE="${LIBERTY_TAG}"

cd "${SCRIPT_DIR}"/liberty-container
./build.sh --jdk-tag="${JDK_TAG}" --liberty-tag="${LIBERTY_TAG}" --jdk-dir="${JDK_DIR}"

cd ../acmeair-container
./buildAcmeair.sh --acmeair-tag="${ACMEAIR_TAG}" --acmeair-base="${ACMEAIR_BASE}"
