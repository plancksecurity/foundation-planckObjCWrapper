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

VERSION="v0.9.28"
NAME="asn1c"

# Exit on errors
set -e

####BUFF: wrong!
if [ -f "${PREFIX}/bin/asn1c" ]; then
    echo "lib exists already in ${PREFIX}/bin/. If you want to rebuild it, delete the existing one."
    exit 0
fi

DIR="${SRC_DIR}/${NAME}"
if [ ! -d "${DIR}" ]; then
    cd "${SRC_DIR}"
        git clone -b ${VERSION} git://github.com/vlm/asn1c.git
    cd "${CURRENT_DIR}"
fi

cd "${SRC_DIR}/${NAME}/"
    autoreconf -iv
    ./configure --prefix="${PREFIX}"
    make install
cd "${CURRENT_DIR}"

rm -rf "${DIR}"
rm -rf "${LIB_DIR}/"*.so*
rm -rf "${LIB_DIR}/"*.la
