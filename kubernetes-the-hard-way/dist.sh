#!/bin/bash

# Parse command line arguments
SKIP_DOWNLOADS=false
for arg in "$@"; do
    case $arg in ("--skip-downloads")
            SKIP_DOWNLOADS=true
            shift
            ;;
    esac
done

pushd certs/
./gen-certs.sh
./dist-certs.sh

popd

if [ "$SKIP_DOWNLOADS" = false ]; then
    pushd downloads/
    ./download.sh
    ./prepare.sh
    popd
fi

pushd configs/
./gen-kubeconfigs.sh
./gen-encryption-config.sh
./dist-kubeconfigs.sh
./dist-encryption-config.sh

popd
./dist-etcd.sh
./dist-control-plane-binaries.sh