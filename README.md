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
sudo port install mercurial
sudo port install gmake
sudo port install autoconf
sudo port install libtool
sudo port install automake
sudo port install wget
sudo port install capnproto
pushd ~
hg clone https://pep.foundation/dev/repos/yml2/
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
mkdir local

export MACOSX_DEPLOYMENT_TARGET=10.10

git clone -b OpenSSL_1_1_1g https://github.com/openssl/openssl.git
pushd "openssl"
./Configure --prefix=$(pwd)/../local/ --openssldir=$(pwd)/../local/ssl darwin64-x86_64-cc
make
make install
popd

<<<<<<< HEAD
						git clone https://github.com/fdik/libetpan
						pushd libetpan
						./autogen.sh --prefix=$(pwd)/../local/
						make install
						popd

=======
>>>>>>> 1.1.250
GMP_VERSION="6.1.2"
GMP_DIR="gmp-${GMP_VERSION}"
TARBALL="gmp-${GMP_VERSION}.tar.bz2"
wget -nc https://gmplib.org/download/gmp/"${TARBALL}"
tar xvf "${TARBALL}"
pushd ${GMP_DIR}
PKG_CONFIG_ALLOW_CROSS=1 PKG_CONFIG_PATH=$(pwd)/../local/lib/pkgconfig ./configure --host=${HOST} --prefix=$(pwd)/../local/
make -j4
make install
popd
rm -rf "${TARBALL}"

HOST="x86_64-apple-darwin10.0.0"

NETTLE_VERSION="3.4.1"
NETTLE_DIR="nettle-${NETTLE_VERSION}"
TARBALL=nettle-${NETTLE_VERSION}.tar.gz
wget -nc https://ftp.gnu.org/gnu/nettle/nettle-${NETTLE_VERSION}.tar.gz
tar xvf "${TARBALL}"
pushd ${NETTLE_DIR}
PKG_CONFIG_ALLOW_CROSS=1 PKG_CONFIG_PATH=$(pwd)/../local/lib/pkgconfig ./configure --host=${HOST} --prefix=$(pwd)/../local/ --with-lib-path=$(pwd)/../local/lib --with-include-path=$(pwd)/../local/include
make -j4
make install
popd
rm -rf "${TARBALL}"

git clone -b "pep-engine" --depth 1 https://gitlab.com/sequoia-pgp/sequoia.git
pushd sequoia
make build-release PYTHON=disable
make install PYTHON=disable PREFIX=$(pwd)/../local/
popd

git clone git://github.com/vlm/asn1c.git
pushd asn1c
git checkout tags/v0.9.28 -b pep-engine
autoreconf -iv
./configure --prefix=$(pwd)/../local/
make install
popd

ICONV_VERSION="1.16"
ICONV_DIR="libiconv-${ICONV_VERSION}"
TARBALL="libiconv-${ICONV_VERSION}.tar.gz"
wget -nc https://ftp.gnu.org/pub/gnu/libiconv/${TARBALL}
tar xvf "${TARBALL}"
pushd ${ICONV_DIR}
./configure --prefix=$(pwd)/../local/ --enable-static
make -j 4
make install
popd

<<<<<<< HEAD
# //BUFF: weget and build libz too and link it to libetpan. Rm linking dynamic lib in client afterwards.

git clone https://github.com/fdik/libetpan
pushd libetpan
# //BUFF: This is not working (afaics). libetpan is still using the systems dynamic iconv lib. I was unable yet to force libetpan to use libiconv.a
=======
#TODO: weget and build libz too and link it to libetpan. Rm linking dynamic lib in client afterwards.

git clone https://github.com/fdik/libetpan
pushd libetpan
#ToDo: This is not working (afaics). libetpan is still using the systems dynamic iconv lib. I was unable yet to force libetpan to use libiconv.a
>>>>>>> 1.1.250
unset CFLAGS
unset LDFLAGS
export LDFLAGS="-Wl/Users/buff/workspace/pEp/src_pEpObjCAdapter_macOS/local/libiconv.a" 
./autogen.sh --prefix=$(pwd)/../local/ --enable-shared=no
make install
popd
#BAD, required due to ios libetpan sub project. RM after moving out of project or even better being able to build macOS libetpan with the Xcode project
rm -rf libetpan
git clone https://pep-security.lu/gitlab/misc/libetpan.git

git clone https://pep-security.lu/gitlab/misc/sqlite.git
git clone https://gitea.pep.foundation/pEp.foundation/pEpEngine
hg clone https://pep.foundation/dev/repos/pEpObjCAdapter
```

## Build

=======
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
