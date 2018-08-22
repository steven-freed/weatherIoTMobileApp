#ifndef SRC_SHADOW_IOT_SHADOW_CONFIG_H_
#define SRC_SHADOW_IOT_SHADOW_CONFIG_H_

// Get from console
 // =================================================
 #define AWS_IOT_MQTT_HOST              "__________.iot.yourRegion.amazonaws.com" // REST-Api endpoint for your thing shadow
 #define AWS_IOT_MQTT_CLIENT_ID         "client-id" // client id should be unique for each thing
 #define AWS_IOT_MY_THING_NAME 		   "RaspberryPi" // thing name
 #define AWS_IOT_ROOT_CA_FILENAME       "rootCA.pem" // name of rootCA file
 #define AWS_IOT_CERTIFICATE_FILENAME   "cert.pem.crt" // name of cert file
 #define AWS_IOT_PRIVATE_KEY_FILENAME   "privateKey.pem.key" // name of private key file

 #define AWS_IOT_MQTT_TX_BUF_LEN 512 
 #define AWS_IOT_MQTT_RX_BUF_LEN 512 
 #define AWS_IOT_MQTT_NUM_SUBSCRIBE_HANDLERS 5 

 // Thing Shadow configuration
 #define SHADOW_MAX_SIZE_OF_RX_BUFFER (AWS_IOT_MQTT_RX_BUF_LEN+1) 
 #define MAX_SIZE_OF_UNIQUE_CLIENT_ID_BYTES 80  
 #define MAX_SIZE_CLIENT_ID_WITH_SEQUENCE MAX_SIZE_OF_UNIQUE_CLIENT_ID_BYTES + 10 
 #define MAX_SIZE_CLIENT_TOKEN_CLIENT_SEQUENCE MAX_SIZE_CLIENT_ID_WITH_SEQUENCE + 20 
 #define MAX_ACKS_TO_COMEIN_AT_ANY_GIVEN_TIME 10 
 #define MAX_THINGNAME_HANDLED_AT_ANY_GIVEN_TIME 10 
 #define MAX_JSON_TOKEN_EXPECTED 120 
 #define MAX_SHADOW_TOPIC_LENGTH_WITHOUT_THINGNAME 60
 #define MAX_SIZE_OF_THING_NAME 20 
 #define MAX_SHADOW_TOPIC_LENGTH_BYTES MAX_SHADOW_TOPIC_LENGTH_WITHOUT_THINGNAME + MAX_SIZE_OF_THING_NAME 

 #define DISABLE_METRICS false

 #endif 
