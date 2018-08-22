# The RaspberryPi Thing in AWS-IoT 
### This application will publish messages to the topic "weatherUpdates/" in json
### format to give artificial weather updates to your mobile app

## Prerequisites
1. make sure you have aws-cli installed (or you can use the aws-console if it's easier)
2. to have aws-cli installed you'll need to use brew to install the latest version of python 
3. use pip to download the aws-cli
4. see https://docs.aws.amazon.com/cli/latest/reference/iot/index.html for more help and documentation

## Steps for creating your RaspberryPi thing
#### ssh into your raspberry pi

1. Generate a certificate 
$ aws iot create-keys-and-certificate --set-as-active --certificate-pem-outfile cert.pem --public-key-outfile publicKey.pem --private-key-outfile privateKey.pem

NOTE: your certificate arn you will need this when attaching a policy to your thing later

2. Create your thing
$ aws iot create-thing --thing-name "RaspberrypiThing"

3. Create a policy for your thing by creating a new json file 
$ touch policyDocument.json
edit the file to add the following
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

NOTE: This policy currently allows access to all resources and many different actions in aws-iot, this policy should be adjusted if you plan on using in a production environment

4. Create the policy
$ aws iot create-policy --policy-name "RasPolicy" --policy-document file://policyDocument.json

5. Attach the policy to your thing
$ aws iot attach-policy --policy-name "RasPolicy" --target "yourCertificateArn"

6. Attach a certificate to your thing
$ aws iot attach-thing-principal --thing-name "RaspberryPi" --principal "yourCertificateArn"

7. Download Root CA certificate
$ wget https://www.symantec.com/content/en/us/enterprise/verisign/roots/VeriSign-Class%203-Public-Primary-Certification-Authority-G5.pem
Then rename this file to "rootCA.pem"
$ mv “VeriSign-Class 3-Public-Primary-Certification-Authority-G5.pem” rootCA.pem

Note: If this doesn't work you can use any Root CA from AWS here under Server Authentication...
https://docs.aws.amazon.com/iot/latest/developerguide/managing-device-certs.html

8. You can either use the code in the /RaspberryPi-Thing/application/app directory or you can download aws sample Embedded C Sdk
$ git clone https://github.com/aws/aws-iot-device-sdk-embedded-C.git -b release

### I stepped through the sample code from aws and created my own project after I understood what the code does. My goal was to make a C program that is short and sweet because I felt that the embedded C sdk sample files were very large and intimidating. 
