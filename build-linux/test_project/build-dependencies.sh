SCRIPT_DIR=$(dirname "$0")
CURRENT_DIR=$(pwd)
cd ${SCRIPT_DIR}
SCRIPT_DIR=$(pwd)

PEP_OBJC_ADAPTER_BUILD_LINUX_DIR="${SCRIPT_DIR}/.."
cd ${PEP_OBJC_ADAPTER_BUILD_LINUX_DIR}
# chagne after finding a fix for "Categories not linked statically"
make install messages=yes shared=yes

cd ${CURRENT_DIR}