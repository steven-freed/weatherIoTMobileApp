#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>
#include <limits.h>
#include <string.h>
#include "aws_iot_config.h"
#include "aws_iot_log.h"
#include "aws_iot_version.h"
#include "aws_iot_mqtt_client_interface.h"

#define HOST_ADDRESS_SIZE 255

// certificate directory
char certDirectory[PATH_MAX + 1] = "../certs";

// mqtt host url from the aws_iot_config.h file
char HostAddress[HOST_ADDRESS_SIZE] = AWS_IOT_MQTT_HOST;

// mqtt port from the aws_iot_config.h file
uint32_t port = AWS_IOT_MQTT_PORT;

// Returns random view attribute for weather reading data
// 0 returns "Sunny", 1 returns "Cloudy"
char* getView() {

	if( (rand() % 2) == 0)
	{
		char* sun = "Sunny";
		return sun;
	} else {
		char* cloud = "Cloudy";
		return cloud;
	}

}

// parses input arguments for connecing to AWSIoT
void parseInputArgsForConnectParams(int argc, char **argv) {
	int opt;

	while(-1 != (opt = getopt(argc, argv, "h:p:c:x:"))) {
		switch(opt) {
			case 'h':
				strncpy(HostAddress, optarg, HOST_ADDRESS_SIZE);
				break;
			case 'p':
				port = atoi(optarg);
				break;
			case 'c':
				strncpy(certDirectory, optarg, PATH_MAX + 1);
				break;
			case '?':
				if(optopt == 'c') {
					IOT_ERROR("Option -%c requires an argument.", optopt);
				} else if(isprint(optopt)) {
					IOT_WARN("Unknown option `-%c'.", optopt);
				} else {
					IOT_WARN("Unknown option character `\\x%x'.", optopt);
				}
				break;
			default:
				IOT_ERROR("Error in command line argument parsing");
				break;
		}
	}

}

int main(int argc, char **argv) {

	char rootCA[PATH_MAX + 1];
	char clientCRT[PATH_MAX + 1];
	char clientKey[PATH_MAX + 1];
	char CurrentWD[PATH_MAX + 1];

	IoT_Error_t connectionStatus = FAILURE;

	// IoT Client Params for connection
	AWS_IoT_Client client;
	IoT_Client_Init_Params mqttInitParams = iotClientInitParamsDefault;
	IoT_Client_Connect_Params connectParams = iotClientConnectParamsDefault;

	// Messages to publish
	IoT_Publish_Message_Params paramsQOS0;
	char cPayload[100];

	parseInputArgsForConnectParams(argc, argv);

	// Directory of Certificates
	getcwd(CurrentWD, sizeof(CurrentWD));
	snprintf(rootCA, PATH_MAX + 1, "%s/%s/%s", CurrentWD, certDirectory, AWS_IOT_ROOT_CA_FILENAME);
	snprintf(clientCRT, PATH_MAX + 1, "%s/%s/%s", CurrentWD, certDirectory, AWS_IOT_CERTIFICATE_FILENAME);
	snprintf(clientKey, PATH_MAX + 1, "%s/%s/%s", CurrentWD, certDirectory, AWS_IOT_PRIVATE_KEY_FILENAME);
	
	// MQTT Client Configuration
	mqttInitParams.enableAutoReconnect = false; 
	mqttInitParams.pHostURL = HostAddress;
	mqttInitParams.port = port;
	mqttInitParams.pRootCALocation = rootCA;
	mqttInitParams.pDeviceCertLocation = clientCRT;
	mqttInitParams.pDevicePrivateKeyLocation = clientKey;
	mqttInitParams.mqttCommandTimeout_ms = 20000;
	mqttInitParams.tlsHandshakeTimeout_ms = 5000;
	mqttInitParams.isSSLHostnameVerify = true;

	// Initializes MQTT client
	connectionStatus = aws_iot_mqtt_init(&client, &mqttInitParams);
	if(SUCCESS != connectionStatus) {
		IOT_ERROR("aws_iot_mqtt_init returned error : %d ", connectionStatus);
		return connectionStatus;
	}

	connectParams.keepAliveIntervalInSec = 600;
	connectParams.isCleanSession = true;
	connectParams.MQTTVersion = MQTT_3_1_1;
	connectParams.pClientID = AWS_IOT_MQTT_CLIENT_ID;
	connectParams.clientIDLen = (uint16_t) strlen(AWS_IOT_MQTT_CLIENT_ID);
	connectParams.isWillMsgPresent = false;

	// Connects MQTT client
	IOT_INFO("Connecting...");
	rc = aws_iot_mqtt_connect(&client, &connectParams);
	if(SUCCESS != connectionStatus) {
		IOT_ERROR("Error(%d) connecting to %s:%d", connectionStatus, mqttInitParams.pHostURL, mqttInitParams.port);
		return connectionStatus;
	}

	// Parsing Payload to json format
	sprintf(cPayload, "{\n\"temperature\": %d,\"view\": \"%s\"\n}", (rand() % 105), getView());

	paramsQOS0.qos = QOS0;
	paramsQOS0.payload = (void *) cPayload;
	paramsQOS0.isRetained = 0;

	// keep publishing new weather readings until program is terminated
	while(SUCCESS == connectionStatus) 
	{
		// Max time the yield function will wait for read messages
		aws_iot_mqtt_yield(&client, 100);

		sleep(2); // delay message to make temperature readings seem more authentic
		sprintf(cPayload, "{\n\"temperature\": %d,\"view\": \"%s\"\n}", (rand() % 105), getView());
		paramsQOS0.payloadLen = strlen(cPayload);

		// 15 is str length of topic "weatherUpdates/"
		// publishes to topic
		aws_iot_mqtt_publish(&client, "weatherUpdates/", 15, &paramsQOS0);
	
	}

}
