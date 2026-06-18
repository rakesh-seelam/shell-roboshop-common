# #!/bin/bash

# USER_ID=$(id -u)
# LOG_FOLDER="/var/log/shell-roboshop"
# LOG_FILE="$LOG_FOLDER/$0.log"
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"
# SCRIPT_DIR=$PWD
# SCRIPT_START_TIME=$(date +%s) 

# mkdir -p $LOG_FOLDER

# echo "$(date "+%Y-%m-%d %H:%M:%S") | Script execution started at: $(date)" | tee -a $LOG_FILE 

# check_root(){
# if [ $USER_ID -ne 0 ]; then
#    echo "Run this script as root user" | tee -a $LOG_FILE
#    exit 1
# fi
# }

# VALIDATE(){
#     if [ $1 -ne 0 ]; then
#       echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2: $R FAILURE $N" | tee -a $LOG_FILE
#       exit 1
#     else
#       echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2: $G Success $N" | tee -a $LOG_FILE
#     fi
# }

# nodejs_setup(){
#     dnf list installed | grep nodejs &>>$LOG_FILE
#     if [ $? -ne 0 ]; then
#         dnf module disable nodejs -y &>>$LOG_FILE
#         VALIDATE $? "Disabling nodejs"

#         dnf module enable nodejs:20 -y &>>$LOG_FILE
#         VALIDATE $? "Enabling nodejs-20"

#         dnf install nodejs -y &>>$LOG_FILE
#         VALIDATE $? "Installing nodejs"

#         npm install &>>$LOG_FILE
#         VALIDATE $? "Installing Dependencies"
#     else 
#     echo -e "nodejs is already installed $Y SKIPPING $N"
#     fi
# }

# java_setup(){
#     dnf install maven -y &>>$LOG_FILE
#     VALIDATE $? "Installing Maven"

#     cd /app
#     mvn clean package &>>$LOG_FILE
#     VALIDATE $? "Installing and Building shipping"

#     mv target/shipping-1.0.jar shipping.jar 
#     VALIDATE $? "Moving and Renaming shipping"
# }

# python_setup(){
#     dnf install python3 gcc python3-devel -y &>>$LOG_FILE
#     VALIDATE $? "Installed Python"

#     cd /app 
#     pip3 install -r requirements.txt &>>$LOG_FILE
#     VALIDATE $? "Installing dependencies"
# }

# app_setup(){
#     #Creating system user
#     id roboshop &>>$LOG_FILE
#     if [ $? -ne 0 ]; then
#         useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
#         VALIDATE $? "Creating System User"
#     else
#     echo -e "Roboshop User already exists $Y SKIPPING $N"
#     fi

#     #Creating app
#     mkdir -p /app 
#     VALIDATE $? "Creating temporary directory"

#     curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip &>>$LOG_FILE
#     VALIDATE $? "Downloading $APP_NAME Code"

#     cd /app
#     VALIDATE $? "Moving to App directory"

#     rm -rf /app/*
#     VALIDATE $? "Removing existing code"

#     unzip /tmp/$APP_NAME.zip &>>$LOG_FILE
#     VALIDATE $? "Unzipping $APP_NAME code"
# }

# systemd_setup(){
#     cp $SCRIPT_DIR/$APP_NAME.service /etc/systemd/system/$APP_NAME.service
#     VALIDATE $? "Copying catalagoue service"

#     systemctl daemon-reload
#     VALIDATE $? "Reloading Daemon"

#     systemctl enable $APP_NAME &>>$LOG_FILE
#     systemctl start $APP_NAME
#     VALIDATE $? "Enabling and Starting $APP_NAME"
# }

# app_restart(){
#     systemctl restart $APP_NAME
#     VALIDATE $? "Restarting $APP_NAME"
# }

# print_total_time(){
#     SCRIPT_END_TIME=$(date +%s) 
#     TOTAL_TIME=$((SCRIPT_END_TIME-SCRIPT_START_TIME))
#     echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script executed in: $G $TOTAL_TIME $N" | tee -a $LOG_FILE
# }

#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
MONGODB_HOST=mongodb.rakesh.bond
MYSQL_HOST=mysql.rakesh.bond

mkdir -p $LOGS_FOLDER

echo "$(date "+%Y-%m-%d %H:%M:%S") | Script started executing at: $(date)" | tee -a $LOGS_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disabling NodeJS Default version"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling NodeJS 20"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Install NodeJS"

    npm install  &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}

java_setup(){
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Installing Maven"

    cd /app 
    mvn clean package &>>$LOGS_FILE
    VALIDATE $? "Installing and Building $APP_NAME"

    mv target/$APP_NAME-1.0.jar $APP_NAME.jar 
    VALIDATE $? "Moving and Renaming $APP_NAME"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
    VALIDATE $? "Installing Python"

    cd /app 
    pip3 install -r requirements.txt &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}

app_setup(){
    # creating system user
    id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "Creating system user"
    else
        echo -e "Roboshop user already exist ... $Y SKIPPING $N"
    fi

    # downloading the app
    mkdir -p /app 
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip  &>>$LOGS_FILE
    VALIDATE $? "Downloading $APP_NAME code"

    cd /app
    VALIDATE $? "Moving to app directory"

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    unzip /tmp/$APP_NAME.zip &>>$LOGS_FILE
    VALIDATE $? "Uzip $APP_NAME code"
}

systemd_setup(){
    cp $SCRIPT_DIR/$APP_NAME.service /etc/systemd/system/$APP_NAME.service
    VALIDATE $? "Created systemctl service"

    systemctl daemon-reload
    systemctl enable $APP_NAME  &>>$LOGS_FILE
    systemctl start $APP_NAME
    VALIDATE $? "Starting and enabling $APP_NAME"
}

app_restart(){
    systemctl restart $APP_NAME
    VALIDATE $? "Restarting $APP_NAME"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script execute in: $G $TOTAL_TIME seconds $N" | tee -a $LOGS_FILE
}