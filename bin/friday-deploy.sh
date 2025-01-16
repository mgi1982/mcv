#!/usr/bin/env bash

set -e

DAYOFWEEK=$(date +"%u")

if [ "$DAYOFWEEK" -eq 5 ]; then
  echo "┐┌┐┌┐┐┌┐┌┐";
  echo "┘└┘└┘\ₒ/";
  echo "┐┌┐┌┐ ∕      Friday";
  echo "┘└┘└┘ノ)";
  echo "┐┌┐┌┐        deploy,";
  echo "┘└┘└┘";
  echo "┐┌┐┌┐        good";
  echo "┘└┘└┘";
  echo "┐┌┐┌┐        luck!";
  echo "│││││";
  echo "┴┴┴┴┴";
fi
