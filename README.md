# S32CSV
S32CSV is a quick and dirty shell script that utilizes the AWS CLI to create a report of all your S3 buckets and their attributes organized in either CSV or TSV format. The default location for the exported data is a file named `report.csv` in your current working directory
## Requirements
* OSX or Linux
* [AWS CLI](http://aws.amazon.com/cli/)
* [jq](http://stedolan.github.io/jq/)
* IAM User with **at least** `s3:ListAllMyBuckets`, `s3:GetBucketLocation`, and `s3:GetBucketWebsite` permission. Here is an example IAM policy that will apply the minimum required permissions.

```json
{
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation",
                "s3:GetBucketWebsite"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
```
## Installation
```
git clone git@github.com:rossreed/S32CSV.git
```
## Usage
```
cd S32CSV/
./s32csv.sh
```