#!/bin/bash
set -ex

# Build all dependencies for iOS arm64
make everything -f arm64.make

echo "iOS Dependencies Built Successfully into ../../deps/ios_dist"
