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
    #PKG_CONFIG_ALLOW_CROSS=1 RUST_BACKTRACE=full PKG_CONFIG_PATH=${CURRENT_LIB_DIR}/lib/pkgconfig RUSTFLAGS="-L ${PREFIX}/lib" cargo build --target ${HOST} --release
    #RUSTFLAGS="-L ${LIB_DIR}" cargo build --release
    cargo update
    RUSTFLAGS="-L ${LIB_DIR}" cargo build -p sequoia-openpgp-ffi --release
    make -C openpgp-ffi install PREFIX=${PREFIX}
cd "${CURRENT_DIR}"


#cp "${SEQUOIA_DIR}/target/${HOST}/release"/*.a "${CURRENT_LIB_DIR}/lib"

# # copy headers
# cp -R "${SEQUOIA_DIR}/openpgp-ffi/include"/* "${CURRENT_LIB_DIR}/include/"
#     # END: Lib Specific Code
# }

# # Cleanup
# cleanup()
# {
#     rm -rf "${TMP_DIR}/x86_64"
#     rm -rf "${TMP_DIR}/arm64"
#     export MACOSX_DEPLOYMENT_TARGET=10.10
# }
# cleanup

# # Setup

# mkdir -p "${TMP_DIR}"
# mkdir -p "${PREFIX}"

# # Build
# pushd "${TMP_DIR}"
#     buildLib "x86_64" "x86_64-apple-macos10.10" "x86_64-apple-darwin" "macosx"
#     buildLib "arm64" "arm64-apple-macos11.1" "aarch64-apple-darwin" "macosx"
# popd

# # Make Fat Lib
# sh "${SCRIPT_DIR}/build-fat-libs.sh" "${TMP_DIR}/arm64/lib" "${TMP_DIR}/x86_64/lib" "${LIB_DIR}"
# # Make Fat Bin
# sh "${SCRIPT_DIR}/build-fat-bins.sh" "${TMP_DIR}/arm64/bin" "${TMP_DIR}/x86_64/bin" "${BIN_DIR}"


# # Copy Headers If Currently Building Lib
# ARM64_INCLUDE_DIR="${TMP_DIR}/arm64/include"
# cp -r "${ARM64_INCLUDE_DIR}"/* "${INCLUDE_DIR}" 2>/dev/null || :

# # Cleanup
# cleanup

rm -rf "${SRC_DIR}"
rm -rf "${LIB_DIR}/"*.so*
rm -rf "${LIB_DIR}/"*.la
