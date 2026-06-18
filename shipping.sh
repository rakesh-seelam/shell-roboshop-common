#!/bin/bash

source ./common.sh
APP_NAME=shipping
MYSQL_HOST=mysql.rakesh.bond


check_root
app_setup
java_setup
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loaded data into MySQL"
else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi

print_total_time