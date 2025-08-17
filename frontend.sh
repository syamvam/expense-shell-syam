#!/bin/bash
LOGS_FOLDER="/var/log/backend"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

mkdir -p $LOGS_FOLDER

USERID=$(id -u)
echo "UserID is $USERID"

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
if [ $USERID -ne 0 ]
then
   echo -e "$R Please run the script with root privileges $N" | tee -a $LOG_FILE
   exit 1
fi

}
VALIDATE (){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is $R Failed $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is $G Success $N" | tee -a $LOG_FILE
    fi        
}

echo "Scripts started executing at : $(date)" | tee -a $LOG_FILE
CHECK_ROOT


dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Instaling nginx" 

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$LOG_FILE
unzip /tmp/frontend.zip
VALIDATE $? "Extract frontend code"

systemctl restart nginx
VALIDATE $? "Restarting nginx"


