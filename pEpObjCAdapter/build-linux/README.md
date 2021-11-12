# HowToBuild pEpObjCAdapter for Linux

Only Debian 11 is currently tested.

Our GNUstep envirnoment must be setup. You can find HowTo setup GNUstep on Debian 11 [here](https://devdocs.pep.security/IPSec/Team%20%26%20Development/Objective-C/Cross%20Platform%20Objective-C%20%26%20Swift/Cross%20Platform%20Objective-C/VirtualBox%20Setup%20-%3E%20Debian%2011%20Plus%20GNUstep.html). There is also a Debian 11 Virtual Box image with GNUstep already setup (find info [here](https://devdocs.pep.security/IPSec/Team%20%26%20Development/Objective-C/Cross%20Platform%20Objective-C%20%26%20Swift/Cross%20Platform%20Objective-C/HowTo%20-%3E%20Build%20GNUstep%20On%20Debian%2011.html)).

## Install Required Tools

````

apt install sudo curl git build-essential python3 clang pkg-config nettle-dev capnproto libssl-dev python3-lxml libtool autoconf uuid-dev sqlite3 libsqlite3-dev
curl https://sh.rustup.rs -sSf | sh
source ~/.bashrc
``

## Install Dependencies
```
mkdir src_pEpObjCAdapter
cd src_pEpObjCAdapter
git clone http://pep-security.lu/gitlab/ipsec/common-dependency-build-helpers-4-linux.git
cd common-dependency-build-helpers-4-linux
sh build.sh
cd ..
git clone http://pep-security.lu/gitlab/ipsec/pepgnustephelper.git
git clone https://gitea.pep.foundation/pep.foundation/pEpObjCAdapter.git
```

## Build for Linux

```
cd pEpObjCAdapter/pEpObjCAdapter/build-linux
make install messages=yes shared=yes debug=yes
```

## Known Issues

Until now we failed linking to libpEpObjCAdapter statically due to not being able to link Categories.

### Build Dir & Build Artefacts

You can find the build artefacts in `/usr/GNUstep/Local/Library/Libraries`.