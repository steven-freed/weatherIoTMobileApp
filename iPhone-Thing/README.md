# The iPhone Thing using AWS-IoT
This mobile app will receive any messages published to the topic "weatherUpdates/"
It will generate a certificate and attach your specified policy to it to allow you to recieve
messages published to your specified topic. It also allows you to delete a certificate incase
you want to create a new one for testing purposes.

## Prerequisites
1. make sure you have aws-cli installed (or you can use the aws-console if it's easier)
2. to have aws-cli installed you'll need to use brew to install the latest version of python
3. use pip to download the aws-cli
4. see https://docs.aws.amazon.com/cli/latest/reference/iot/index.html for more help and documentation

## Steps for creating your iPhone thing
1. No need to generate a certificate because our iOS app will create one in the app

2. Create your thing
```
$ aws iot create-thing --thing-name "iPhoneThing"
```

3. Create a policy for your thing by creating a new json file
```
$ touch policyDocument.json
```
edit the file to add the following
```
{
"Version": "2012-10-17",
"Statement": [
{
"Action": [
"iot:Publish",
"iot:Subscribe",
"iot:Connect",
"iot:Receive"
],
"Effect": "Allow",
"Resource": [
"*"
]
}
]
}
```
NOTE: This policy currently allows access to all resources and many different actions in aws-iot, this policy should be adjusted if you plan on using in a production environment

4. Create the policy
```
$ aws iot create-policy --policy-name "iPhonePolicy" --policy-document file://policyDocument.json
```

5. No need to attach the policy to our thing because the mobile app client will attach it for us when we specify the policy in the Constants.swift file

6. Fill in credentials in Constants.swift file, they can be found in your aws-console or through aws-cli
