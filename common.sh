#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.rakesh.bond
MYSQL_HOST=mysql.rakesh.bond
SCRIPT_START_TIME=$(date +%s) 

mkdir -p $LOG_FOLDER

echo "$(date "+%Y-%m-%d %H:%M:%S") | Script execution started at: $(date)" | tee -a $LOG_FILE 

check_root(){
if [ $USER_ID -ne 0 ]; then
   echo -e " $R Run this script as root user $N " | tee -a $LOG_FILE
   exit 1
fi
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
      echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2: $R FAILURE $N" | tee -a $LOG_FILE
      exit 1
    else
      echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2: $G Success $N" | tee -a $LOG_FILE
    fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling nodejs-20"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $? "Installing Dependencies"
}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven"

    cd /app
    mvn clean package &>>$LOG_FILE
    VALIDATE $? "Installing and Building $APP_NAME"

    mv target/$APP_NAME-1.0.jar $APP_NAME.jar 
    VALIDATE $? "Moving and Renaming $APP_NAME"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installed Python"

    cd /app 
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"
}

app_setup(){
    #Creating system user
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "Creating System User"
    else
    echo -e "Roboshop User already exists $Y SKIPPING $N"
    fi

    #Creating app
    mkdir -p /app 
    VALIDATE $? "Creating temporary directory"

    curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $APP_NAME Code"

    cd /app
    VALIDATE $? "Moving to App directory"

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    unzip /tmp/$APP_NAME.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping $APP_NAME code"
}

systemd_setup(){
    cp $SCRIPT_DIR/$APP_NAME.service /etc/systemd/system/$APP_NAME.service
    VALIDATE $? "Copying $APP_NAME service"

    systemctl daemon-reload
    VALIDATE $? "Reloading Daemon"

    systemctl enable $APP_NAME &>>$LOG_FILE
    systemctl start $APP_NAME
    VALIDATE $? "Enabling and Starting $APP_NAME"
}

app_restart(){
    systemctl restart $APP_NAME
    VALIDATE $? "Restarting $APP_NAME"
}

print_total_time(){
    SCRIPT_END_TIME=$(date +%s) 
    TOTAL_TIME=$(( $SCRIPT_END_TIME - $SCRIPT_START_TIME ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script executed in: $G $TOTAL_TIME $N" | tee -a $LOG_FILE
}