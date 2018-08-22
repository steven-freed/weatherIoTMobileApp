//
//  ViewController.swift
//  IoTWeather
//
//  Created by steven freed on 8/17/18.
//  Copyright © 2018 steven freed. All rights reserved.
//

import UIKit
import AWSIoT

class ConnectionViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var connected = false // check if you are connected to IoT
    var connectViewController : UIViewController!
    
    var iotDataManager: AWSIoTDataManager!
    var iotManager: AWSIoTManager!
    var iot: AWSIoT!
    
    // topic we are subscribed to
    var topic: String = "weatherUpdates/"
    
    // MARK: - User wants to connect or disconnect from AWSIoT
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        
        sender.isEnabled = false
        
        func mqttEventCallback( _ status: AWSIoTMQTTStatus )
        {
            DispatchQueue.main.async {
                
                // connection status
                switch(status)
                {
                case .connecting:
                    mqttStatus = "Connecting..."
                    self.logTextView.text = mqttStatus
                    
                case .connected:
                    mqttStatus = "Connected"
                    sender.setTitle( "Disconnect", for:UIControlState())
                    self.activityIndicatorView.stopAnimating()
                    self.connected = true
                    sender.isEnabled = true
                    let uuid = UUID().uuidString;
                    let defaults = UserDefaults.standard
                    let certificateId = defaults.string( forKey: "certificateId")
                    self.logTextView.text = "Using certificate:\n\(certificateId!)\n\n\nClient ID:\n\(uuid)"
                    self.subscribeToWeatherUpdates()
                    
                case .disconnected:
                    mqttStatus = "Disconnected"
                    self.activityIndicatorView.stopAnimating()
                    self.logTextView.text = nil
                    
                case .connectionRefused:
                    mqttStatus = "Connection Refused"
                    self.activityIndicatorView.stopAnimating()
                    self.logTextView.text = mqttStatus
                    
                case .connectionError:
                    mqttStatus = "Connection Error"
                    self.activityIndicatorView.stopAnimating()
                    self.logTextView.text = mqttStatus
                    
                case .protocolError:
                    mqttStatus = "Protocol Error"
                    self.activityIndicatorView.stopAnimating()
                    self.logTextView.text = mqttStatus
                    
                default:
                    mqttStatus = "Unknown State"
                    self.activityIndicatorView.stopAnimating()
                    self.logTextView.text = mqttStatus
                }
                
            }
        }
        
        
        // checks if user is connected
        if (connected == false)
        {
            activityIndicatorView.startAnimating()
            
            let defaults = UserDefaults.standard
            var certificateId = defaults.string( forKey: "certificateId")
            let uuid = UUID().uuidString;
 
                // If no certificate id exists
                if (certificateId == nil)
                {
                    
                    DispatchQueue.main.async {
                        self.logTextView.text = "No identity found, creating one..."
                    }
                    
                    // Creates and stores the certificate id in UserDefaults
                    let csrDictionary = [ "commonName": CertificateSigningRequestCommonName, "countryName": CertificateSigningRequestCountryName, "organizationName":CertificateSigningRequestOrganizationName, "organizationalUnitName":CertificateSigningRequestOrganizationalUnitName ]
                    
                    // Creates keys and a certificate
                    self.iotManager.createKeysAndCertificate(fromCsr: csrDictionary, callback: {  (response ) -> Void in
                        if (response != nil)
                        {
                            defaults.set(response?.certificateId, forKey:"certificateId")
                            defaults.set(response?.certificateArn, forKey:"certificateArn")
                            certificateId = response?.certificateId
                            print("response: [\(String(describing: response))]")
                            
                            DispatchQueue.main.async {
                            
                            self.deleteButton.setTitle( "Delete Certificate", for:UIControlState())
                            self.deleteButton.isEnabled = true
                            }
                                
                            let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest()
                            attachPrincipalPolicyRequest?.policyName = PolicyName
                            attachPrincipalPolicyRequest?.principal = response?.certificateArn
                            
                            // Attach the policy to the certificate
                            self.iot.attachPrincipalPolicy(attachPrincipalPolicyRequest!).continueWith (block: { (task) -> AnyObject? in
                                if let error = task.error {
                                    print("failed to attach policy: \(error)")
                                }
                                
                                // Connect to the AWS IoT platform
                                if (task.error == nil)
                                {
                                    DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                                        self.logTextView.text = "Using certificate: \(certificateId!)"
                                        self.iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:certificateId!, statusCallback: mqttEventCallback)
                                        
                                    })
                                }
                                return nil
                            })
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                sender.isEnabled = true
                                self.activityIndicatorView.stopAnimating()
                                self.logTextView.text = "Unable to create keys and/or certificate, check values in Constants.swift"
                            }
                        }
                        
                    })
                    
            } else // if a certificate id does exist
            {
                let uuid = UUID().uuidString;
                
                // Connect to AWS IoT
                iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:certificateId!, statusCallback: mqttEventCallback)
            }
            
        } else // user is connected and wants to disconnect
        {
            activityIndicatorView.startAnimating()
            logTextView.text = "Disconnecting..."
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                
                self.iotDataManager.disconnect();
                
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.connected = false
                    sender.setTitle( "Connect", for:UIControlState())
                    sender.isEnabled = true
                
                }
            }
        }
        
    }
    
    // MARK: - User wants to delete their current certificate and keys
    @IBAction func deleteCertificateTapped(_ sender: UIButton)
    {
        
        self.logTextView.text = "deleting identity..."

        let defaults = UserDefaults.standard
        let certificateId = defaults.string( forKey: "certificateId")
        let certificateArn = defaults.string( forKey: "certificateArn")
        
        // checks for your existing certificate's id
        if certificateId != nil
        {
            let iot = AWSIoT.default()
            
            let updateCertificateRequest = AWSIoTUpdateCertificateRequest()
            updateCertificateRequest?.certificateId = certificateId
            updateCertificateRequest?.latestStatus = .inactive
            
            // updates certificate to inactive, * mandatory before deletion *
            iot.updateCertificate( updateCertificateRequest! ).continueWith(block:{ (task) -> AnyObject? in
                
                if let error = task.error {
                    print("update cert failed: [\(error)]")
                }
    
                if (task.error == nil)
                {
                    let certificateArn = defaults.string( forKey: "certificateArn")
                    let detachPolicyRequest = AWSIoTDetachPrincipalPolicyRequest()
                    detachPolicyRequest?.principal = certificateArn
                    detachPolicyRequest?.policyName = PolicyName
                    
                    // Detach policy from certificate
                    iot.detachPrincipalPolicy(detachPolicyRequest!).continueWith(block: { (task) -> AnyObject? in
                        if let error = task.error {
                            print("detach policy failed: [\(error)]")
                        }
                      
                        if (task.error == nil)
                        {
                            let deleteCertificateRequest = AWSIoTDeleteCertificateRequest()
                            deleteCertificateRequest?.certificateId = certificateId
    
                            // Delete certificate
                            iot.deleteCertificate(deleteCertificateRequest!).continueWith(block: { (task) -> AnyObject? in
                                
                                if let error = task.error {
                                    print("delete cert failed: [\(error)]")
                                }
                             
                                if (task.error == nil)
                                {
                    
                                    // If certificate deleted successfully then remove its credentials from UserDefaults
                                    if (AWSIoTManager.deleteCertificate() != true)
                                    {
                                        print("error deleting certificate")
                                    } else
                                    {
                                        defaults.removeObject(forKey: "certificateId")
                                        defaults.removeObject(forKey: "certificateArn")
                                        DispatchQueue.main.async {
                                            
                                        sender.setTitle( "No Certificate", for:UIControlState())
                                        sender.isEnabled = false
                                        self.logTextView.text = "Certificate Deleted!"
                                        }
                                    }
                                }
                                return nil
                            })
                        }
                        return nil
                    })
                }
                return nil
            })
            
        } else // Error has occurred, this should not be possible
        {
            print("certificate id == nil")
        }

}
    
    // MARK: - Checks for user connection and latest weather updates
    override func viewWillAppear(_ animated: Bool) {
        
        // Check if user is still connected
        if mqttStatus == "Connected"
        {
            self.subscribeToWeatherUpdates()
        }
        
        // checks for last weather update
        if PersistentStore.requestReading() != nil
        {
            let reading: WReading = PersistentStore.requestReading()!
            let temp = String(describing: reading.temp)
            let view = reading.view!
            let json = "{\n\"temperature\": \(temp)\n\"view\": \(view)\n}"
            self.logTextView.text = json
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let certId = defaults.string( forKey: "certificateId")
        
        // Sets delete certificate button
        if certId != nil
        {
        self.deleteButton.isEnabled = true
        } else
        {
        self.deleteButton.isEnabled = false
        }
        
        // Init IoT
        // Set up Cognito
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegion, identityPoolId: CognitoIdentityPoolId)
        let iotEndPoint = AWSEndpoint(urlString: IOT_ENDPOINT)
        
        // Config AWS control plane
        let iotConfiguration = AWSServiceConfiguration(region: AWSRegion, credentialsProvider: credentialsProvider)
        
        // Config AWS data
        let iotDataConfiguration = AWSServiceConfiguration(region: AWSRegion,
                                                           endpoint: iotEndPoint,
                                                           credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = iotConfiguration
        iotManager = AWSIoTManager.default()
        iot = AWSIoT.default()
        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: ASWIoTDataManager)
        iotDataManager = AWSIoTDataManager(forKey: ASWIoTDataManager)
    }
    
    // MARK: - Subscribes user to weather updates when they are connected
    func subscribeToWeatherUpdates()
    {
        let iotDataManager = AWSIoTDataManager(forKey: ASWIoTDataManager)
        
        iotDataManager.subscribe(toTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce, messageCallback: {
            (payload) ->Void in
            
            let stringValue = String(data: payload, encoding: .utf8)
           
            DispatchQueue.main.async {
                self.logTextView.text = stringValue as! String
            }
            
            do {
                
                let data = payload.base64EncodedData()
                let dict = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                
                // Save update to Core Data
                let temp = Int16(bitPattern: dict["temperature"]! as! UInt16)
                let view = String(describing: dict["view"]!)
                
                print(temp)
                print(view)
                
                PersistentStore.saveReading(temp: temp, view: view)
                
            } catch {
                print(error)
            }
        })
    }
    
    
    
}

