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

GMP_VERSION=6.2.1
GMP_NAME="gmp-${GMP_VERSION}"

# Exit on errors
set -e

if [ -f "${LIB_DIR}/libgmp.a" ]; then
    echo "lib exists already in ${LIB_DIR}. If you want to rebuild it, delete the existing one."
    exit 0
fi

GMP_DIR="${SRC_DIR}/${GMP_NAME}"
if [ ! -d "${GMP_DIR}" ]; then
	cd "${SRC_DIR}"
	    # GMP snapshot must be used until released
		wget -nc https://gmplib.org/download/gmp/$GMP_NAME.tar.bz2
		tar xvf ${GMP_NAME}.tar.bz2
	cd "${CURRENT_DIR}"
fi

#export CC="${CC} -fPIC"
cd "${SRC_DIR}/${GMP_NAME}"
	PKG_CONFIG_ALLOW_CROSS=1 PKG_CONFIG_PATH="${PREFIX}"/lib/pkgconfig ./configure --prefix="${PREFIX}" --disable-shared
	make clean
	make -j4
	make install
cd "${CURRENT_DIR}"

rm -rf "${SRC_DIR}"*.bz2
rm -rf "${LIB_DIR}/"*.so*
rm -rf "${LIB_DIR}/"*.la
