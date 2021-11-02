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
mkdir -p "${PREFIX}/include"
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

SQLITE_NAME="sqlite"

# Exit on errors
set -e

if [ -f "${LIB_DIR}/libsqlite3.a" ]; then
    echo "lib exists already in ${LIB_DIR}. If you want to rebuild it, delete the existing one."
    exit 0
fi

SQLITE_DIR="${SRC_DIR}/${SQLITE_NAME}"
if [ ! -d "${SQLITE_DIR}" ]; then
    cd "${SRC_DIR}"
        git clone https://pep-security.lu/gitlab/misc/sqlite.git
    cd "${CURRENT_DIR}"
fi

cd "${SRC_DIR}/${SQLITE_NAME}/"
    gcc -c -fPIC sqlite3.c -o sqlite3.o
    ar qf libsqlite3.a sqlite3.o
    ranlib libsqlite3.a
    mv libsqlite3.a "${PREFIX}/lib"
    cp sqlite3.h "${PREFIX}/include/"
cd "${CURRENT_DIR}"

rm -rf "${SRC_DIR}/${SQLITE_NAME}"
rm -rf "${LIB_DIR}/"*.so*
rm -rf "${LIB_DIR}/"*.la
