#!/bin/bash
#!/bin/bash
LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

mkdir -p $LOGS_FOLDER

USERID=$(id -u)
echo "UserID is $USERID"

R="\e[31m"
G="\e[32m"
CHECK_ROOT(){
if [ $USERID -ne 0 ]
then
   echo -e "$R Please run the script with root privileges $N" | tee -a &>>$LOG_FILE
   exit 1
fi

}
VALIDATE (){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is $R Failed $N" | tee -a &>>$LOG_FILE
    else
        echo -e "$2 is $G Success $N" | tee -a &>>$LOG_FILE
    fi        
}

echo "Scripts started executing at : $(date)" | tee -a $LOG_FILE
CHECK_ROOT

dnf install mysql-server -y
VALIDATE $? "Installing mysql"

systemctl enable mysqld
VALIDATE $? "enabling mysql"

systemctl start mysqld
VALIDATE $? "started mysql server"


mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "SETTING UP ROOT PASSWORD"
