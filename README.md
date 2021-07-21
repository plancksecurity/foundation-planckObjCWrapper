WIP

HowToBuild static lib for macOS

## Deployment

```
PER_MACHINE_DIRECTORY="/Library/Application Support/pEp"
PER_USER_DIRECTORY=$HOME/.pEp
```

## Required Tools

For building the engine, you need a working python3 environment and all dependencies:

```
sudo port install git
sudo port install gmake
sudo port install autoconf
sudo port install libtool
sudo port install automake
sudo port install wget
sudo port install capnproto

pushd ~
git clone https://gitea.pep.foundation/fdik/yml2
popd

curl https://sh.rustup.rs -sSf | sh
```

add this to ~/.profile (create if it doesn't exist):

```
source $HOME/.cargo/env
export PATH="$HOME/.cargo/bin:$PATH"
```

restart your Console (!)

```
sudo port install pkgconfig
rustup update
```

Install Xcode (if not installed already)

## Apple IDs & Certificates

### Apple ID

You need to have an Apple ID (connected to pEp team account) configured in Xcode .  Ask `#service`, if you want to be added to the team account. 

## Build Dependencies
```
mkdir src_pEpObjCAdapter_macOS
cd src_pEpObjCAdapter_macOS

git clone https://gitea.pep.foundation/buff/common-dependency-build-helpers-4-apple-hardware.git
git clone http://pep-security.lu/gitlab/iOS/pep-toolbox.git
git clone https://pep-security.lu/gitlab/iOS/CocoaLumberjack
git clone https://pep-security.lu/gitlab/misc/libetpan.git
git clone https://pep-security.lu/gitlab/misc/sqlite.git
git clone https://gitea.pep.foundation/pEp.foundation/pEpEngine
git clone https://gitea.pep.foundation/pep.foundation/pEpObjCAdapter.git
```

## Build

### iOS Only: Copy System DB 

The `system.db` from the pEpEngine repository must be copied in the bundle that uses the pEpObjCAdapter.a static lib. The ObjCAdapter copies it at runtime in the desired directory.

Backround: Has been introduces to use Apple Shared App Directory of the client App.

### Using Xcode UI

`open pEpMacOSAdapter/pEpObjCAdapter.xcworkspace/`

Build scheme "All" of pEpObjCAdapter.xcworkspace

### Using terminal

`xcodebuild -workspace "pEpObjCAdapter.xcworkspace" -scheme "PEPObjCAdapter_macOS" -configuration RELEASE`

(or DEBUG)

### Build Dir & Build Artefacts

You can find the build artefacts in the `pEpMacOSAdapter/build` folder
