# pgv-local-s3-and-lambda

AWS S3 と Lambda のローカル環境(閉塞環境用)動作環境

# 動作確認済

- [x] Ubuntu 18.04 LTS
- [x] Mac OSX
- [ ] Windows 10


# 動作確認

```
$ docker-compose up -d
$ docker-compose ps | grep minio
pgv-local-s3-and-lambda_minio_1_30efa2df88de           /usr/bin/docker-entrypoint ...   Up (healthy)   0.0.0.0:19000->9000/tcp
```

-> http://localhost:19000/minio/mybucket/

## (参考) awscliでminioを利用

```
$ aws configure --profile minio
AWS Access Key ID [None]: AKIA_MINIO_ACCESS_KEY
AWS Secret Access Key [None]: minio_secret_key
Default region name [None]: us-east-1
Default output format [None]: json

$ aws --profile minio --endpoint-url http://localhost:19000 s3 ls
2018-12-12 23:35:33 mybucket

// s3(profile=deafult) to tmp
$ aws s3 cp s3://pgv-test-data/test8 /tmp/test8 --recursive
$ du -sh /tmp/test8
81M     /tmp/test8

// tmp to minio(profile=mino)
$ aws s3 cp /tmp/test8 --profile minio --endpoint-url http://localhost:19000 s3://mybucket/test8 --recursive
$ du -sh data/minio/data/mybucket/test8
81M     data/minio/data/mybucket/test8

$ aws --profile minio --endpoint-url http://localhost:19000 s3 ls s3://mybucket/
 PRE test8/
```

--------------

# (参考) S3 event notificationの実装

Minio Event notification

S3互換のフォーマット(らしい)
https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/notification-content-structure.html

例:

```
{
   "Records":[
      {
         "eventVersion":"2.0",
         "eventSource":"aws:s3",
         "awsRegion":"us-east-1",
         "eventTime":"1970-01-01T00:00:00.000Z",
         "eventName":"ObjectCreated:Put",
         "userIdentity":{
            "principalId":"AIDAJDPLRKLG7UEXAMPLE"
         },
         "requestParameters":{
            "sourceIPAddress":"127.0.0.1"
         },
         "responseElements":{
            "x-amz-request-id":"C3D13FE58DE4C810",
            "x-amz-id-2":"FMyUVURIY8/IgAtTv8xRjskZQpcIZ9KG4V5Wp6S7S/JRWeUWerMUE5JgHvANOjpD"
         },
         "s3":{
            "s3SchemaVersion":"1.0",
            "configurationId":"testConfigRule",
            "bucket":{
               "name":"mybucket",
               "ownerIdentity":{
                  "principalId":"A3NL1KOZZKExample"
               },
               "arn":"arn:aws:s3:::mybucket"
            },
            "object":{
               "key":"HappyFace.jpg",
               "size":1024,
               "eTag":"d41d8cd98f00b204e9800998ecf8427e",
               "versionId":"096fKKXTRTtl3on89fVO.nfljtsv6qko",
               "sequencer":"0055AED6DCD90281E5"
            }
         }
      }
   ]
}
```

bucket = json["Records"][0]["s3"]["bucket"]["name"]
filename = json["Records"][0]["s3"]["object"]["key"]
filesize = json["Records"][0]["s3"]["object"]["size"]
