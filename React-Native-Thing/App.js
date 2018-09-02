import React from 'react';
import { Dimensions, StyleSheet, Text, View, ImageBackground, FlatList, ScrollView, Animated } from 'react-native';
import { createBottomTabNavigator } from 'react-navigation';
import IonIcon from 'react-native-vector-icons/Ionicons';

// AWS Amplify
import Amplify, { API } from 'aws-amplify';
import PubSub from '@aws-amplify/pubsub';
import { AWSIoTProvider } from '@aws-amplify/pubsub/lib/Providers';
Amplify.configure({
    Auth: {
        // Amazon Cognito Identity Pool ID
        identityPoolId: 'us-east-1:________________',
        // Amazon Cognito Region
        region: 'us-east-1'
    }
});
Amplify.addPluggable(new AWSIoTProvider({
     aws_pubsub_region: 'us-east-1',
     aws_pubsub_endpoint: 'wss://____________.iot.us-east-1.amazonaws.com/mqtt',
   }));
PubSub.configure();

// Custom Components
import HoursList from './Components/HoursList';
import DaysList from './Components/DaysList';

// Constants
const DEVICE_WIDTH = Dimensions.get('window').width
const HEADER_MAX_HEIGHT = 120
const HEADER_MIN_HEIGHT = 80
const HEADER_SCROLL_DIST = HEADER_MAX_HEIGHT - HEADER_MIN_HEIGHT
const views = {
  "Sunny": require('./assets/Sunny.png'),
  "Cloudy": require('./assets/Cloudy.png')
}

class WeatherScreen extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      scrollY: new Animated.Value(0),
      temp: "0",
      view: views["Sunny"],
      viewText: "Sunny"
    }

  }

// Subscribe to Mqtt topic 'weatherUpdates/'
  async componentDidMount() {

    await PubSub.subscribe('weatherUpdates/').subscribe({
    next: data => this.setState({temp: data.value.temperature, view: views[data.value.view], viewText: data.value.view}),
    error: error => console.error(error),
    close: () => console.log('Done')
    });

  }

  render() {

    // Animations
    const headerHeight = this.state.scrollY.interpolate({
      inputRange: [0, HEADER_SCROLL_DIST],
      outputRange: [HEADER_MAX_HEIGHT, HEADER_MIN_HEIGHT],
      extrapolate: 'clamp',
    })

    const tempOpacity = this.state.scrollY.interpolate({
      inputRange: [0, HEADER_SCROLL_DIST / 5, HEADER_SCROLL_DIST / 4, HEADER_SCROLL_DIST / 3, HEADER_SCROLL_DIST / 2, HEADER_SCROLL_DIST],
      outputRange: [1, 0.8, 0.5, 0.3, 0.1, 0],
      extrapolate: 'clamp',
    })

    return (
         <ImageBackground source={this.state.view} style={{flex: 1}}>

         <Animated.View style = {{height: headerHeight, top: 0, left: 0, right: 0, paddingTop: 50}}>
         <Text  adjustsFontSizeToFit style={{color: '#fff', fontSize: 42, textAlign: 'center'}}>Colts Neck</Text>
         <Text  adjustsFontSizeToFit style={{color: '#fff', fontSize: 38, textAlign: 'center'}}>{this.state.viewText}</Text>
         </Animated.View>

         <ScrollView onScroll = {Animated.event(
           [{nativeEvent: {contentOffset: {y: this.state.scrollY} } }]
         )}
         showsVerticalScrollIndicator = {false} scrollEventThrottle={16} contentContainerStyle = {{flexGrow: 1, justifyContent: 'space-between'}}>
         <Animated.Text style={{color: '#fff', fontSize: 80, textAlign: 'center', paddingBottom: 30, paddingTop: 30, opacity: tempOpacity}}>{this.state.temp}°</Animated.Text>
         <HoursList/>
         <DaysList/>
         </ScrollView>

        </ImageBackground>
    );
  }

}

// Bottom Tab Bar
export default createBottomTabNavigator(
  {
    Weather: WeatherScreen
  },
  {
    navigationOptions: ({ navigation }) => ({
      tabBarIcon: ({ focused, tintColor }) => {
        const { routeName } = navigation.state;

        let iconName = `ios-sunny${focused ? '' : '-outline'}`;

       return <IonIcon name={iconName} size={25} color={tintColor}/>;
      },
    }),
    tabBarOptions: {
      activeTintColor: 'black',
      inactiveTintColor: 'gray',
    },
  }
);
