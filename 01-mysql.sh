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
dnf list installed mysql
if [ $? -ne 0 ]
then 
   echo "MySql is not installed, going to install" | tee -a $LOG_FILE
   dnf install mysql-server -y &>>$LOG_FILE
   VALIDATE $? "Installing mysql"
else
   echo -e "$G MySql is already intalled $N skipping %N" | tee -a $LOG_FILE
fi
STARTED=$(systemctl is-active mysqld)
if [ $STARTED != 'active' ]
then 
    echo "Mysql is not started, going to start" | tee -a $LOG_FILE
    systemctl start mysqld &>>$LOG_FILE
    VALIDATE $? "starting mysql"
else
    echo -e " $G MySql is already started skipping $N" | tee -a $LOG_FILE   
fi

ENABLED=$(systemctl is-enabled mysqld)
if [ $ENABLED != 'enabled' ]
then 
    echo "Mysql is not enabled, going to enable" | tee -a $LOG_FILE
    systemctl enable mysqld &>>$LOG_FILE
    VALIDATE $? "enabling mysql"
else
    echo "MySql is already enabled skipping" | tee -a $LOG_FILE   
fi


mysql_secure_installation --set-root-pass ExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo "Mysql Password is not set , setting now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "SETTING UP ROOT PASSWORD"
else
    echo -e "Mysql root password is already setup $Y skipping $N" | tee -a $LOG_FILE
fi


