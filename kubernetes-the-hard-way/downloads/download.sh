#!/bin/bash

wget -q --show-progress --https-only --timestamping -P ./ -i downloads-$(dpkg --print-architecture).txt