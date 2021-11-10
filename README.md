# HowToBuild pEpObjCAdapter for macOS & iOS

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
mkdir src_pEpObjCAdapter
cd src_pEpObjCAdapter

git clone https://gitea.pep.foundation/buff/common-dependency-build-helpers-4-apple-hardware.git
git clone http://pep-security.lu/gitlab/iOS/pep-toolbox.git
git clone https://pep-security.lu/gitlab/iOS/CocoaLumberjack
git clone https://pep-security.lu/gitlab/misc/libetpan.git
git clone https://pep-security.lu/gitlab/misc/sqlite.git
git clone https://gitea.pep.foundation/pEp.foundation/pEpEngine
git clone https://gitea.pep.foundation/pep.foundation/pEpObjCAdapter.git
```

## Build for iOS

### iOS Only: Copy System DB 

The `system.db` from the pEpEngine repository must be copied in the bundle that uses the pEpObjCAdapter.a static lib. The ObjCAdapter copies it at runtime in the desired directory.

Backround: Has been introduces to use Apple Shared App Directory of the client App.

### Using Xcode UI

`open pEpObjCAdapter/pEpObjCAdapter.xcworkspace/`

Build scheme "pEpObjCAdapter_iOS".

### Using terminal

`xcodebuild -workspace "pEpObjCAdapter.xcworkspace" -scheme "PEPObjCAdapter_iOS" -configuration RELEASE`

(or DEBUG)

### Build Dir & Build Artefacts

You can find the build artefacts in the `pEpMacOSAdapter/build` folder


## Build for macOS

### Using Xcode UI

`open pEpObjCAdapter/pEpObjCAdapter.xcworkspace/`

Build scheme "PEPObjCAdapter_macOS".

### Using terminal

`xcodebuild -workspace "pEpObjCAdapter.xcworkspace" -scheme "PEPObjCAdapter_macOS" -configuration RELEASE`

(or DEBUG)

### Using terminal

`xcodebuild -workspace "pEpObjCAdapter.xcworkspace" -scheme "PEPObjCAdapter_macOS" -configuration RELEASE`

(or DEBUG)

### Build Dir & Build Artefacts

You can find the build artefacts in the `pEpMacOSAdapter/build` folder


# HowToBuild pEpObjCAdapter for Linux

Only Debian 11 is currently tested.

Our GNUstep envirnoment must be setup. You can find HowTo setup GNUstep on Debian 11 [here](https://devdocs.pep.security/IPSec/Team%20%26%20Development/Objective-C/Cross%20Platform%20Objective-C%20%26%20Swift/Cross%20Platform%20Objective-C/VirtualBox%20Setup%20-%3E%20Debian%2011%20Plus%20GNUstep.html). There is also a Debian 11 Virtual Box image with GNUstep already setup (find info [here](https://devdocs.pep.security/IPSec/Team%20%26%20Development/Objective-C/Cross%20Platform%20Objective-C%20%26%20Swift/Cross%20Platform%20Objective-C/HowTo%20-%3E%20Build%20GNUstep%20On%20Debian%2011.html)).

## Get Dependencies
```
mkdir src_pEpObjCAdapter
cd src_pEpObjCAdapter
git clone http://pep-security.lu/gitlab/ipsec/pepgnustephelper.git
git clone https://gitea.pep.foundation/pep.foundation/pEpObjCAdapter.git
```

## Build for Linux
```
cd pEpObjCAdapter
make install messages=yes [shared=no] debug=[yes|no]
```
(Until now we failed linking to libpEpObjCAdapter statically due to not being able to link Categories).

### Build Dir & Build Artefacts

You can find the build artefact in `/usr/GNUstep/Local/Library/Libraries`.