#!/bin/bash

source ./common.sh

APP_NAME=redis
check_root

dnf list installed | grep redis &>>$LOG_FILE
if [ $? -ne 0 ]; then
    dnf module disable redis -y &>>$LOG_FILE
    dnf module enable redis:7 -y
    dnf install redis -y &>>$LOG_FILE
    VALIDATE $? "Enabling and installing Redis-7"
else
    echo -e "Redis already Installed $Y SKIPPING $N "
fi 

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis &>>$LOG_FILE
systemctl start redis 
VALIDATE $?  "Enabling and starting Redis"
