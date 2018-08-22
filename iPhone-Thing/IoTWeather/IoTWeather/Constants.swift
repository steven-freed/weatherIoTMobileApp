//
//  Constants.swift
//  IoTWeather
//
//  Created by steven freed on 8/17/18.
//  Copyright © 2018 steven freed. All rights reserved.
//

import Foundation
import AWSCore

/*
 The only thing you need to enter for this app to run are the 5 constants below,
 if it does not work make sure your policy document is correct for your identity pool
 and IoT 'thing'
 
 NOTE: It is mandatory for these to be set for this application to run
 */
let AWSRegion = AWSRegionType.USEast1
let CognitoIdentityPoolId = "yourRegion:________________"
let IOT_ENDPOINT = "https://______.iot.yourRegion.amazonaws.com"
let PolicyName = "iPhonePolicy"
let CertificateSigningRequestCountryName = "US"

// If using only for development purposes you can leave these as is
let CertificateSigningRequestCommonName = "IoTWeather Application"
let CertificateSigningRequestOrganizationName = "Your Organization"
let CertificateSigningRequestOrganizationalUnitName = "Your Organizational Unit"
let ASWIoTDataManager = "MyIotDataManager"

// mqtt flag for connection status in ConnectViewController
var mqttStatus = "Disconnected"
