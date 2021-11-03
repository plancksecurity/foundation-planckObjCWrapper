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

VERSION="openpgp/v1.3.1"

if [ -f "${LIB_DIR}/libsequoia_openpgp_ffi.a" ]; then
    echo "lib exists already in ${LIB_DIR}. If you want to rebuild it, delete the existing one."
    exit 0
fi

SEQUOIA_DIR="${SRC_DIR}/sequoia"
if [ ! -d "${SEQUOIA_DIR}" ]; then
    cd "${SRC_DIR}"
        git clone -b ${VERSION} --depth 1 https://gitlab.com/sequoia-pgp/sequoia.git
    cd "${CURRENT_DIR}"
fi

cd "${SEQUOIA_DIR}"
    cargo update
    RUSTFLAGS="-L ${LIB_DIR}" cargo build -p sequoia-openpgp-ffi --release
    make -C openpgp-ffi install PREFIX=${PREFIX}
cd "${CURRENT_DIR}"

rm -rf "${SRC_DIR}"
rm -rf "${LIB_DIR}/"*.so*
rm -rf "${LIB_DIR}/"*.la
