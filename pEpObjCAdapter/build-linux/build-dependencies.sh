SCRIPT_DIR=$(dirname "$0")
CURRENT_DIR=$(pwd)
cd ${SCRIPT_DIR}
SCRIPT_DIR=$(pwd)

sh ${SCRIPT_DIR}/dependency_builder/buildPEPObjCAdapterProtocols.sh
sh ${SCRIPT_DIR}/dependency_builder/buildPEPObjCTypeUtils.sh