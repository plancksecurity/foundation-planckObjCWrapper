#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
PREFIX=$1
SRC_DIR=$2
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

if [ -f "${LIB_DIR}/libetpan.a" ]; then
    echo "lib exists already in ${LIB_DIR}. If you want to rebuild it, delete the existing one."
    exit 0
fi

LIBETPAN_DIR="${SRC_DIR}/libetpan"
if [ ! -d "${LIBETPAN_DIR}" ]; then
    cd "${SRC_DIR}"
        git clone -b ${VERSION} https://gitea.pep.foundation/pEp.foundation/libetpan
    cd "${CURRENT_DIR}"
fi

cd "${LIBETPAN_DIR}"
    ./autogen.sh --prefix=${PREFIX}
    make install
cd "${CURRENT_DIR}"

rm -rf "${SRC_DIR}"
rm -rf "${LIB_DIR}/"*.so*
rm -rf "${LIB_DIR}/"*.la