#!/bin/bash -uex

SCRIPT_BASE=$(cd $(dirname $0); pwd)
: ${CT_CONFIG:=${SCRIPT_BASE}/../files/ct-ng_dot_config_arm926ejs}
: ${WORKSPACE:=${HOME}/work}

# setup
mkdir -p ${WORKSPACE}/ct-ng_build/
cp ${CT_CONFIG} ${WORKSPACE}/ct-ng_build/.config
cd ${WORKSPACE}/ct-ng_build/

# build
CT_PREFIX="${WORKSPACE}/x-tools" ct-ng build -j

# compress
cd ${WORKSPACE}/x-tools/
XZ_OPT="-T0" tar Jcf arm-none-eabi.tar.xz arm-none-eabi

