#!/bin/bash

source ./scripts/config.sh
source ./scripts/drivechain_testing.sh

SKIP_CLONE=0
SKIP_BUILD=0
SKIP_CHECK=0
SKIP_REPLACE_TIP=0
SKIP_RESTART=0
SKIP_SHUTDOWN=0
INCOMPATIBLE_BDB=0
WARNING_ANSWER="yes"

for arg in "$@"
do
    if [ "$arg" == "--help" ]; then
        echo "The following command line options are available:"
        echo "--skip_clone"
        echo "--skip_build"
        echo "--skip_check"
        echo "--skip_replace_tip"
        echo "--skip_restart"
        echo "--skip_shutdown"
        echo "--with-incompatible-bdb"
        exit
    elif [ "$arg" == "--skip_clone" ]; then
        SKIP_CLONE=1
    elif [ "$arg" == "--skip_build" ]; then
        SKIP_BUILD=1
    elif [ "$arg" == "--skip_check" ]; then
        SKIP_CHECK=1
    elif [ "$arg" == "--skip_replace_tip" ]; then
        SKIP_REPLACE_TIP=1
    elif [ "$arg" == "--skip_restart" ]; then
        SKIP_RESTART=1
    elif [ "$arg" == "--skip_shutdown" ]; then
        SKIP_SHUTDOWN=1
    elif [ "$arg" == "--with-incompatible-bdb" ]; then
        INCOMPATIBLE_BDB=1
    fi
done

clear
echo -e "\e[32mYou should probably run this in a VM\e[0m"
echo

# Clone repositories
if [ $SKIP_CLONE -ne 1 ]; then
    echo "Cloning repositories"
    git clone https://github.com/LayerTwo-labs/mainchain.git
fi

# L1 build 
if [ $SKIP_BUILD -ne 1 ]; then
    echo "Building mainchain"
    cd mainchain

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update
        sudo apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3

        # Download and build dependencies
        make -C ./depends download-linux
        make -C ./depends -j4

        # Configure and build the mainchain
        ./autogen.sh
        CONFIG_SITE=$PWD/depends/x86_64-pc-linux-gnu/share/config.site ./configure 
        make -j $(nproc)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install automake libtool boost miniupnpc openssl pkg-config protobuf qt5 zmq

        # Download and build dependencies
        make -C ./depends download-osx
        make -C ./depends -j4

        # Configure and build the mainchain
        ./autogen.sh
        CONFIG_SITE=$PWD/depends/x86_64-apple-darwin11/share/config.site ./configure
        make -j $(sysctl -n hw.ncpu)
    elif [[ "$OSTYPE" == "msys" ]]; then
        sudo apt-get install g++-mingw-w64-x86-64 build-essential libtool autotools-dev automake libssl-dev libevent-dev pkg-config bsdmainutils curl git python3-setuptools python-is-python3

        # Configure the Windows toolchain
        sudo update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

        # Download and build dependencies
        make -C ./depends download-win
        make -C ./depends HOST=x86_64-w64-mingw32 -j4

        # Configure and build the mainchain
        ./autogen.sh
        CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site ./configure
        make -j $(nproc)
    fi
    cd ..
fi

# Create drivechain configuration file
echo "Create drivechain configuration file"
mkdir -p ~/.drivechain/
touch ~/.drivechain/drivechain.conf
echo "rpcuser=drivechain" >> ~/.drivechain/drivechain.conf
echo "rpcpassword=L2L" >> ~/.drivechain/drivechain.conf
echo "server=1" >> ~/.drivechain/drivechain.conf
