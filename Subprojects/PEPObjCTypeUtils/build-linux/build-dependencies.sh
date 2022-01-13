SCRIPT_DIR=$(dirname "$0")
CURRENT_DIR=$(pwd)

# Get Absolute Paths & Setup

cd "${SCRIPT_DIR}"
    SCRIPT_DIR=$(pwd)
cd "${CURRENT_DIR}"

sh dependency_builder/build-PEPObjCTypes.sh

