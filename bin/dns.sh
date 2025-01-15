#!/usr/bin/env bash

set -e

echo 'nameserver 1.1.1.1
nameserver 8.8.8.8' | sudo tee /etc/resolv.conf > /dev/null
