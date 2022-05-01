#!/bin/bash
set -e
USAGE="Usage: ./backup.sh [options]
Valid values for operation (o): backup, restore
Valid values for volume (v): db-data, drupal-data
Examples:
backup.sh -o backup -d db-data
"

operations=("backup" "restore")
volumes=("db-data" "drupal-data")

while getopts ":o:v:" OPTION
do
    case "${OPTION}" in
        o ) operation=$OPTARG;;
        v ) volume=$OPTARG;;
        : ) echo "${USAGE}" ; exit 1;;
        ? ) echo "${USAGE}" ; exit 1;;
    esac
done

if [ -z ${operation} ]; then
    echo "Operation parameter is required. Use 'backup' or 'restore'."
fi

if [ -z ${volume} ]; then
    echo "Volume parameter is required. Use 'db-data' or 'drupal-data' as volume."
fi

if [[ "$operation" = "backup" ]]; then
    if printf '%s\0' "${volumes[@]}" | grep -Fxqz "${volume}"; then
        echo "$operation of $volume will start now..."
        tar -cjf /backup/${volume}.tar.bz2 -C /volume/${volume} ./
    else
        echo "Invalid parameter. Use 'db-data' or 'drupal-data' as volume."
    fi
elif [[ "$operation" = "restore" ]]; then
    if printf '%s\0' "${volumes[@]}" | grep -Fxqz "${volume}"; then
        if [ -f "/backup/${volume}.tar.bz2" ]; then
            echo "$operation of $volume will start now..."
            rm -rf /volume/${volume}/* /volume/${volume}/..?* /volume/${volume}/.[!.]* ; tar -C /volume/${volume} -xjf /backup/${volume}.tar.bz2
        else
            echo "Nothing to restore. Skipping..."
        fi
    else
        echo "Invalid parameter. Use 'db-data' or 'drupal-data' as volume."
    fi 
else 
    echo "Invalid operation. Use 'backup' or 'restore'."
fi