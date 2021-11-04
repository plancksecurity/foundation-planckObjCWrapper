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


#############################
#############################
#############################

ENGINE_VERSION="master"
ENGINE_NAME="pEpEngine"

# Exit on errors
set -e

if [ -f "${LIB_DIR}/libpEpengine.a" ]; then
    echo "lib exists already in ${LIB_DIR}. If you want to rebuild it, delete the existing one."
    exit 0
fi

EGNINE_DIR="${SRC_DIR}/${ENGINE_NAME}"
if [ ! -d "${EGNINE_DIR}" ]; then
    cd "${SRC_DIR}"
        git clone -b ${ENGINE_VERSION} https://gitea.pep.foundation/pEp.foundation/pEpEngine           
    cd "${CURRENT_DIR}"
fi

cd "${SRC_DIR}/${ENGINE_NAME}/"
    echo "PREFIX=${PREFIX}" > local.conf
    echo '
    PER_MACHINE_DIRECTORY=$(PREFIX)/share/pEp

    SQLITE3_FROM_OS=""

    YML2_PATH=$(HOME)/local/bin/yml2

    ETPAN_LIB=-L$(PREFIX)/lib
    ETPAN_INC=-I$(PREFIX)/include

    ASN1C=$(PREFIX)/bin/asn1c
    ASN1C_INC=-I$(PREFIX)/share/asn1c

    OPENPGP=SEQUOIA
    SEQUOIA_LIB=-L$(PREFIX)/lib
    SEQUOIA_INC=-I$(PREFIX)/include

    CFLAGS+=-DNDEBUG=1 -Os
    CXXFLAGS+=-DNDEBUG=1 -Os
    LDFLAGS+=-nostartfiles -Os

    export PKG_CONFIG_PATH=$(PREFIX)/share/pkgconfig/
    ' >> local.conf
    make install
    make dbinstall

    cp asn.1/*.a "${PREFIX}/lib/" # missing in the makefile.
cd "${CURRENT_DIR}"

rm -rf "${SRC_DIR}/${ENGINE_NAME}"
rm -rf "${LIB_DIR}/"*.so*
rm -rf "${LIB_DIR}/"*.la
