#!/bin/bash

### START SETTINGS VARIABLES ###
# The 'REPORTOBJECTS' varialbe must be set to either 'true' or 'false' if set to true, the script will create a directory called 'objects' in which it will place a CSV for each bucket, containing every object in that bucket with it's URL. If a bucket is empty no report is created for it
# WARNING: if this is set to true and you have any buckets with a large number of objects, it could take a significant amount of time for this script to run
REPORTOBJECTS=false
# The 'D' variable is the delimiter. If you prefer tab seperated format change the value of this to "\t" instead.
D=","
# The 'FILEPATH' is where to put all the files, by default this is the current working directory, if you'd like the files to go somwhere else instead change the value for this, for example: FILEPATH="/path/to/put/files"
FILEPATH=`pwd`"/s3report"
### END SETTINGS VARIABLES ###

mkdir -p $FILEPATH
REPORTPATH=$FILEPATH"/report.csv"
BUCKETLIST=`aws s3api list-buckets`

if $REPORTOBJECTS ; then
    OBJECTDIR=$FILEPATH"/objects"
    mkdir -p $OBJECTDIR
fi
echo -e "Bucket Name"$D"Static Website Enabled"$D"Index Document"$D"Error Document"$D"Redirect To Host"$D"Date Created"$D"Region" > $REPORTPATH
for BUCKET in $(echo $BUCKETLIST | jq '.Buckets[].Name' | sed 's/"//g')
do
    echo -ne "                                                                                \r"
    echo -ne "Current Bucket: $BUCKET\r"
    
    if WEBJSON=`aws s3api get-bucket-website --bucket $BUCKET 2> /dev/null` ; then
        REDIR=`echo $WEBJSON | jq '.RedirectAllRequestsTo.HostName' | sed 's/"//g'`
        INDEXDOC=`echo $WEBJSON | jq '.IndexDocument.Suffix' | sed 's/"//g'`
        ERRORDOC=`echo $WEBJSON | jq '.ErrorDocument.Key' | sed 's/"//g'`
        STATICHOSTING=true
    else
        STATICHOSTING=false
        REDIR="N/A"
        INDEXDOC="N/A"
        ERRORDOC="N/A"
    fi
    
    if [ "$(aws s3api get-bucket-location --bucket $BUCKET | jq '.LocationConstraint')" = "null" ] ; then
        LOCATION=us-east-1
    else
        LOCATION=`aws s3api get-bucket-location --bucket $BUCKET | jq '.LocationConstraint' | sed 's/"//g'`
    fi
    CREATEDATE=`echo $BUCKETLIST | jq -c --arg BN $BUCKET '.Buckets[] | select(.Name == $BN) | .CreationDate' | sed 's/"//g'`
    echo -e $BUCKET$D$STATICHOSTING$D$INDEXDOC$D$ERRORDOC$D$REDIR$D$CREATEDATE$D$LOCATION >> $REPORTPATH

    if $REPORTOBJECTS ; then
        OBJECTLIST=`aws s3api list-objects --bucket $BUCKET --region $LOCATION | jq ".Contents[].Key"`
        if [ -n "$OBJECTLIST" ] ; then
            OBJECTPATH=$OBJECTDIR"/"$BUCKET".csv"
            echo -e "Object"$D"URL" > $OBJECTPATH
            for S3OBJECT in $(echo $OBJECTLIST | sed 's/"//g')
            do
                echo -e $S3OBJECT$D"HTTPS://"$BUCKET".s3.amazonaws.com/"$S3OBJECT >> $OBJECTPATH
            done
        fi
    fi
done
echo -ne "                                                                                \r"
echo "Done"
echo "Report saved to $REPORTPATH"
