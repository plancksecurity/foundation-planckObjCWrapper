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
mkdir -p "${PREFIX}"
cd "${PREFIX}"
    PREFIX=$(pwd)
cd "${CURRENT_DIR}"
if [ "${SRC_DIR}" = "" ]; then
    SRC_DIR=~/src
fi
mkdir -p "${SRC_DIR}"
cd "${SRC_DIR}"
    SRC_DIR=$(pwd)
cd "${CURRENT_DIR}"

LIB_DIR="${PREFIX}/lib"
mkdir -p "${LIB_DIR}"

VERSION="master"

# Go

TRANSPORT_DIR="${SRC_DIR}/libpEpTransport"
if [ ! -d "${TRANSPORT_DIR}" ]; then
    cd "${SRC_DIR}"
        git clone -b ${VERSION} https://gitea.pep.foundation/pEp.foundation/libpEpTransport.git           
    cd "${CURRENT_DIR}"
fi

cd "${TRANSPORT_DIR}"
	echo "" > local.conf
	echo "PREFIX=${PREFIX}" >> local.conf
	echo "YML2_PATH=${PREFIX}/bin/yml2" >> local.conf
	make src
	make install
cd "${CURRENT_DIR}"

