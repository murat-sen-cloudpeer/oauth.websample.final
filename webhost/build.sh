#!/bin/bash

##############################################
# Build the web host ready for local execution
##############################################

#
# Install node dependencies
#
rm -rf node_modules
npm install
if [ $? -ne 0 ]; then
    echo 'Problem encountered installing webhost dependencies'
    exit 1
fi