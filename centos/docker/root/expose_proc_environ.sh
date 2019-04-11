#!/usr/bin/env bash

set -e

ENV_FILE="/tmp/proc_$1_environ"
touch ${ENV_FILE}
echo "" | tee ${ENV_FILE} 1>&2

# see: https://unix.stackexchange.com/questions/146995/inherit-environment-variables-in-systemd-docker-container
# Import our environment variables from systemd
# This reads /proc/1/envion, which is the environment given to PID 1, but is delimited by nulls.
while IFS= read -r -d '' line ; do
    #(>&2 echo ${line})
    var_name=$(echo ${line} | cut -d '=' -f 1)
    var_value=$(echo ${line} | cut -d '=' -f 2-)
    echo "export ${var_name}=\"${var_value}\"" | tee -a ${ENV_FILE} 1>&2
    eval "export ${var_name}=\"${var_value}\""
done <"/proc/$1/environ"

chmod 777 ${ENV_FILE}
