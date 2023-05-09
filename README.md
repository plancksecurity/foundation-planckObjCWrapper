# How to build

## Deployment

On macOS, please be aware of these environment variables:

```
PER_MACHINE_DIRECTORY="/Library/Application Support/planck"
PER_USER_DIRECTORY=$HOME/.planck
```

## Required build tools

```
sudo port install git
sudo port install gmake
sudo port install autoconf
sudo port install libtool
sudo port install automake
sudo port install wget
sudo port install capnproto

pushd ~
git clone https://git.planck.security/foundation/yml2.git
popd

curl https://sh.rustup.rs -sSf | sh
```

Add this to ~/.profile or the _equivalent for your shell_ (create if it doesn't exist, but _please be aware of the consequences_):

```
source $HOME/.cargo/env
export PATH="$HOME/.cargo/bin:$PATH"
```

Restart your console or source the changed configuration files.

```
sudo port install pkgconfig
rustup update
```

Install Xcode (if not installed already)

## Apple IDs & Certificates

### Set up Xcode

You need to have an Apple ID configured in Xcode, for code signing. You can add one in the `Accounts` tab of the settings (menu `Xcode > Preferences...`).

Your Apple ID needs to be part of your development team.

## Setup instructions

```
mkdir src # parent directory of your choice
cd src

git clone https://git.planck.security/foundation/planckObjCWrapper.git

git clone https://git.planck.security/foundation/planckCoreV3.git
git clone https://git.planck.security/foundation/libPlanckTransport.git
git clone https://git.planck.security/foundation/planckCoreSequoiaBackend.git
git clone https://git.planck.security/foundation/libetpan.git
git clone https://git.planck.security/foundation/Pantomime.git
git clone https://git.planck.security/foundation/libAccountsettings.git

git clone https://git.planck.security/misc/ldns.git

git clone https://git.planck.security/iOS/planck-toolbox.git
git clone https://git.planck.security/iOS/common-dependency-build-helpers-4-apple-hardware.git
git clone https://git.planck.security/iOS/CocoaLumberjack.git

open planckObjCWrapper/build-mac/planckObjCWrapper.xcodeproj

```
