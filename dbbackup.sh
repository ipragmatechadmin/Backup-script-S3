#Save dbbacku.sh 

#!/bin/bash
## Specify the name of the database that you want to backup

# Database credentials
USER="DB-USER"
PASSWORD="PASSWORD"
HOST="DB-host-name"
DB_NAME="Database-name"

#Backup_Directory_Locations
BACKUPROOT="/tmp/backups"
TSTAMP=$(date +"%d-%b-%Y-%H-%M-%S")
S3BUCKET="s3://s3bucket"
#LOG_ROOT="logs/dump.log"

#mysqldump  -h <HOST>  -u <USER>  --database <DB_NAME>  -p"password" > $BACKUPROOT/$DB_NAME-$TSTAMP.sql

#or

mysqldump -h$HOST -u$USER $DB_NAME -p$PASSWORD | gzip -9 > $BACKUPROOT/$DB_NAME-$TSTAMP.sql.gz

if [ $? -ne 0 ]
 then
 mkdir /tmp/$TSTAMP
 s3cmd put -r /tmp/$TSTAMP $S3BUCKET/
 s3cmd sync -r $BACKUPROOT/ $S3BUCKET/$TSTAMP/
 rm -rf $BACKUPROOT/*
else
 s3cmd sync -r $BACKUPROOT/ $S3BUCKET/$TSTAMP/
 rm -rf $BACKUPROOT/*
fi
