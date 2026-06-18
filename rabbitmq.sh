#!/bin/bash

source ./common.sh
APP_NAME=rabbitmq

check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Added RabbitMQ repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server
VALIDATE $? "Enabling and Starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "created user and gien permissions"

print_total_time