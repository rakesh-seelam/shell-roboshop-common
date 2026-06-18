#!/bin/bash

source ./common.sh
APP_NAME=user

check_root
app_setup
nodejs_setup
systemd_setup

print_total_time