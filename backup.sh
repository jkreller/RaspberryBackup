#!/bin/bash
# Source: https://raspberry.tips/raspberrypi-einsteiger/raspberry-pi-datensicherung-erstellen and https://hobbyblogging.de/raspberry-pi-vollautomatisch-sichern
# Modified by Lukas Knoeller (hobbyblogging.de) and Julian Kreller
# Forked from https://github.com/lkn94/RaspberryBackup

#Variables
NAS_USER="user" #Change this to your NAS username
NAS_PW="password" #Change this to your NAS password
NAS_ADDRESS="192.168.0.123" #Change this to your NAS address
NAS_BACKUP_PATH="/directory/to/backups" #Change this to the path of the backups directory on your NAS

BACKUP_PATH="/mnt/nas"
BACKUP_NAME="backup"

BACKUP_FILE="${BACKUP_PATH}/${BACKUP_NAME}_$(date +%Y-%m-%d).img"

#Mount NAS
mount -t "cifs" -o "user=${NAS_USER},password=${NAS_PW},rw,file_mode=0777,dir_mode=0777" "//${NAS_ADDRESS}${NAS_BACKUP_PATH}" "${BACKUP_PATH}"

#Check if backup file exists already
if [ -f "${BACKUP_FILE}" ]
then
    echo -e "\e[91m\xe2\x9c\x98 Backup file ${BACKUP_FILE} exists already"
    exit 1
fi

#Create backup
dd if="/dev/mmcblk0" of="${BACKUP_FILE}" bs="1MB"

#Remove backups older than 90 days
find "${BACKUP_PATH}/${BACKUP_NAME}"* -type f -mtime +90 -exec rm {} \;

#Unmount NAS
umount "${BACKUP_PATH}"

if [ ${?} == 0 ]
then
    echo -e "\e[92m\xE2\x9C\x94 Backup file created successfully: ${BACKUP_FILE}"
fi
