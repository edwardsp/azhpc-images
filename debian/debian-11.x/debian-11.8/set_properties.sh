#!/bin/bash

export TOP_DIR=../../..
export COMMON_DIR=../../../common
export DEBIAN_COMMON_DIR=../../common
export TEST_DIR=../../../tests
export DISTRIBUTION=$(. /etc/os-release;echo $ID$VERSION_ID)
