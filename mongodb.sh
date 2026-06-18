#!/bin/bash

source ./common.sh

check_root  

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongo Repo"

dnf install mongodb-org -y  &>>$LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling Mongodb"

systemctl start mongod
VALIDATE $? "Starting Mongodb"

sed -i s/127.0.0.1/0.0.0.0/g /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"

print_total_time

