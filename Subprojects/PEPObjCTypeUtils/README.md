# PEPObjCTypeUtils

Collection of shared PEPObjCType related tools. E.g. converting a (libpEpengine) struct message to/from (libpEpobjctypes) PEPMessage.

## Required Tools
```
sudo port install git
sudo port install gmake
sudo port install autoconf
sudo port install libtool
sudo port install automake
sudo port install asn1c
```

## Dependencies

```
mkdir src
cd src


git clone -b "master" https://pep-security.lu/gitlab/misc/sqlite.git
git clone -b "master" https://gitea.pep.foundation/pEp.foundation/libetpan.git

git clone git://github.com/vlm/asn1c.git
pushd asn1c
    git checkout tags/v0.9.28 -b pep-engine
popd

git clone -b v2.1.6 http://pep-security.lu/gitlab/macos/sequoia4macos.git
pushd sequoia4macos
    sh build.sh
popd

https://gitea.pep.foundation/pEp.foundation/pEpEngine.git
git clone -b "v1.16_without_lib_prefix_defines" https://gitea.pep.foundation/buff/libiconv.git
git clone https://gitea.pep.foundation/pEp.foundation/pEpMIME.git
git clone https://gitea.pep.foundation/pep.foundation/pEpObjCAdapter.git
```
## Build

### Using Xcode

open PEPObjCTypeUtils.xcproject/

Build scheme "PEPObjCTypeUtils_macOS".

### Using terminal

```
xcodebuild -project "PEPObjCTypeUtils.xcproject" -scheme "PEPObjCTypeUtils_macOS" -configuration RELEASE
```

## Build Dir & Build Artefacts

You can find the build artefacts in the `build` folder

