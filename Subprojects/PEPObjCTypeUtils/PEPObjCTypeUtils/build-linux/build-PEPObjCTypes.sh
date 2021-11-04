SCRIPT_DIR=$(dirname "$0")
CURRENT_DIR=$(pwd)
cd ${SCRIPT_DIR}
SCRIPT_DIR=$(pwd)

PEP_OBJC_TYPES_BUILD_LINUX_DIR="${SCRIPT_DIR}/../../../PEPObjCTypes/PEPObjCTypes/build-linux"

cd ${PEP_OBJC_TYPES_BUILD_LINUX_DIR}
	make install messages=yes shared=no
cd ${CURRENT_DIR}