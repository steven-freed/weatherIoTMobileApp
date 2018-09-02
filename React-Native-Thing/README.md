# The React Native Thing using AWS-IoT
### This mobile app will receive any messages published to the topic "weatherUpdates/"

## Prerequisites
1. Quick Start using Expo development server where you can easily launch your app
using a barcode scanner that wraps your app
https://facebook.github.io/react-native/docs/getting-started
OR
1. Production Start following the 'release' steps where you can launch your app
from anywhere without a development server needed
https://facebook.github.io/react-native/docs/running-on-device.html#2-configure-release-scheme


## Steps for creating your React-Native thing
1. Generate a certificate
$ aws iot create-keys-and-certificate --set-as-active --certificate-pem-outfile cert.pem --public-key-outfile publicKey.pem --private-key-outfile privateKey.pem

NOTE: your certificate arn you will need this when attaching a policy to your thing later

2. Create your thing
$ aws iot create-thing --thing-name "ReactNativeThing"

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
$ aws iot create-policy --policy-name "ReactNativePolicy" --policy-document file://policyDocument.json

5. Attach the policy to your thing
$ aws iot attach-policy --policy-name "ReactNativePolicy" --target "yourCertificateArn"

6. Go into your AWS-IoT Core console, click 'Settings' and note your 'Endpoint' and place it in the App.js file
