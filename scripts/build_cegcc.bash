#!/bin/bash -uex

SCRIPT_BASE=$(cd $(dirname $0); pwd)
: ${WORKSPACE:=${HOME}/work}

# setup
mkdir -p ${WORKSPACE}
cd ${WORKSPACE}

# clone
git clone https://github.com/MaxKellermann/cegcc-build.git
cd cegcc-build
git submodule update --init

# build
mkdir -p ${WORKSPACE}/cegcc-working
cd ${WORKSPACE}/cegcc-working
${WORKSPACE}/cegcc-build/build.sh --prefix=${WORKSPACE}/cegcc --parallelism $(nproc)

# compress
cd ${WORKSPACE}
XZ_OPT="-T0" tar Jcf cegcc.tar.xz cegcc