#!/bin/bash

cd /opt
tar xvf /opt/gdal-3.10.0.tar.gz
mkdir -p /opt/gdal-3.10.0/build
cd /opt/gdal-3.10.0/build
cmake -DCMAKE_PREFIX_PATH=/var/informix/ ..
cmake --build .
cmake --build . --target install
ogrinfo --formats | grep IDB
