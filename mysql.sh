#!/bin/bash

source ./common.sh 
APP_NAME=mysql

check_root

dnf list installed | grep mysql &>>$LOG_FILE
if [ $? -ne 0 ]; then
    dnf install mysql-server -y &>>$LOG_FILE
    VALIDATE $? "installing Mysql server"
else
   echo -e "MySQL Already installed $Y SKIPPING $N "
fi

systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld  
VALIDATE $? "enabling and starting  mysqld"

read -s -p "Enter MySQL Root Password: " MYSQL_ROOT_PASSWORD 

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "Setup root password"

print_total_time