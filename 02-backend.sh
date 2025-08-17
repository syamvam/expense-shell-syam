#!/bin/bash
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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "expense user not exists... $G Creating $N"
    useradd expense &>>$LOG_FILE
    VALIDATE $? "Creating expense user"
else
    echo -e "expense user already exists...$Y SKIPPING $N"
fi
mkdir -p /app
VALIDATE $? "Creating app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip $>>$LOG_FILE
VALIDATE $? "Downloading backend applicationcode"

cd /app
VALIDATE $? "Moving to app folder"

unzip /tmp/backend.zip 
VALIDATE $? "Extracting backend zip"