#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
PREFIX=$1
CURRENT_DIR=$(pwd)

# Get Absolute Paths & Setup

cd "${SCRIPT_DIR}"
    SCRIPT_DIR=$(pwd)
cd "${CURRENT_DIR}"
if [ "${PREFIX}" = "" ]; then
    PREFIX=~/local
fi
INSTALL_DIR="${PREFIX}/bin"
mkdir -p "${INSTALL_DIR}"
cd "${PREFIX}"
    PREFIX=$(pwd)
cd "${CURRENT_DIR}"


#############################
#############################
#############################

VERSION="2.7.1"

# Exit on errors
set -e

if [ -d "${INSTALL_DIR}/yml2" ]; then
    echo "yml2 exists already in ${INSTALL_DIR}. If you want to rebuild it, delete the existing one."
    exit 0
fi

cd "${INSTALL_DIR}"
    git clone -b ${VERSION} https://gitea.pep.foundation/fdik/yml2          
cd "${CURRENT_DIR}"
