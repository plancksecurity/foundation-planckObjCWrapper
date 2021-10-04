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

NETTLE_VERSION="3.7.3"
NETTLE_NAME="nettle-${NETTLE_VERSION}"

# Exit on errors
set -e

if [ -f "${LIB_DIR}/libnettle.a" ]; then
    echo "lib exists already in ${LIB_DIR}. If you want to rebuild it, delete the existing one."
    exit 0
fi

NETTLE_DIR="${SRC_DIR}/${NETTLE_NAME}"
if [ ! -d "${NETTLE_DIR}" ]; then
    cd "${SRC_DIR}"
        wget -nc https://ftp.gnu.org/gnu/nettle/${NETTLE_NAME}.tar.gz
        tar xvf ${NETTLE_NAME}.tar.gz
    cd "${CURRENT_DIR}"
fi

cd "${SRC_DIR}/${NETTLE_NAME}/"
    PKG_CONFIG_ALLOW_CROSS=1 PKG_CONFIG_PATH=$LIB_DIR/pkgconfig ./configure --prefix=${PREFIX} --with-lib-path=${PREFIX}/lib --with-include-path=${PREFIX}/include --disable-shared --disable-documentation  --verbose 
    make clean
    make -j4
    make install
cd "${CURRENT_DIR}"

mv "${PREFIX}/lib64/libnettle.a" "${PREFIX}/lib" 
mv "${PREFIX}/lib64/libhogweed.a" "${PREFIX}/lib" 

rm -rf "${SRC_DIR}"*.gz
rm -rf "${LIB_DIR}/"*.so*
rm -rf "${LIB_DIR}/"*.la
