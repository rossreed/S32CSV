#!/bin/bash

# The 'D' variable is the delimiter. If you prefer tab seperated format change the value of this to "\t" instead.
D="\t"
FILEPATH="report.csv"

BUCKETLIST=`aws s3api list-buckets`

TOTAL=`echo $BUCKETLIST | jq '.Buckets[].Name' | wc -l`
CURRENT=0

echo -e "Bucket Name"$D"Static Website Enabled"$D"Index Document"$D"Error Document"$D"Redirect To Host"$D"Date Created"$D"Region" > $FILEPATH
for BUCKET in $(echo $BUCKETLIST | jq '.Buckets[].Name' | sed 's/"//g')
do
    echo -ne "                                                                                \r"
    echo -ne "Current Bucket: $BUCKET\r"
    if WEBJSON=`aws s3api get-bucket-website --bucket $BUCKET 2> /dev/null` ; then
        REDIR=`echo $WEBJSON | jq '.RedirectAllRequestsTo.HostName' | sed 's/"//g'`
        INDEXDOC=`echo $WEBJSON | jq '.IndexDocument.Suffix' | sed 's/"//g'`
        ERRORDOC=`echo $WEBJSON | jq '.ErrorDocument.Key' | sed 's/"//g'`
        STATICHOSTING=TRUE
    else
        STATICHOSTING=FALSE
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
    echo -e $BUCKET$D$STATICHOSTING$D$INDEXDOC$D$ERRORDOC$D$REDIR$D$CREATEDATE$D$LOCATION >> $FILEPATH
done
echo -ne "                                                                                \r"
echo "Done"
echo "Report saved to $FILEPATH"
