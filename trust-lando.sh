#!/usr/bin/env bash

set -e

sudo trust anchor ~/.lando/certs/lndo.site.pem
sudo trust anchor ~/.lando/certs/lndo.site.crt
