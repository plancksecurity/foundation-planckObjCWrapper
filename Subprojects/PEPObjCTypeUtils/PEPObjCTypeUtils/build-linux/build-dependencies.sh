SCRIPT_DIR=$(dirname "$0")
PREFIX=$1
CURRENT_DIR=$(pwd)

# Get Absolute Paths & Setup

cd "${SCRIPT_DIR}"
    SCRIPT_DIR=$(pwd)
cd "${CURRENT_DIR}"

sh dependency_builder/install-yml2.sh
sh dependency_builder/build-sqlite3.sh
sh dependency_builder/build-asn1.sh

sh dependency_builder/build-gmp.sh
sh dependency_builder/build-nettle.sh
sh dependency_builder/build-sequoia.sh

sh dependency_builder/build-libetpan.sh
sh dependency_builder/build-pEptransport.sh
sh dependency_builder/build-pEpengine.sh

sh dependency_builder/build-PEPObjCTypes.sh

