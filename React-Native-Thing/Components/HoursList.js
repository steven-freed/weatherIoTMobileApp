import React, {Component} from 'react';
import {FlatList, View, Text, ActivityIndicator, Image, StyleSheet} from 'react-native';
import { ListItem } from "react-native-elements";

class HoursList extends Component {
  constructor(props) {
    super(props);

  // loads sample data
    this.data = [
     {degrees: "79°", hour: "10am", view: require('../assets/cloud.png')},
     {degrees: "79°", hour: "11am", view: require('../assets/cloud.png')},
     {degrees: "81°", hour: "12pm", view: require('../assets/sun.png')},
     {degrees: "82°", hour: "1pm", view: require('../assets/sun.png')},
     {degrees: "82°", hour: "2pm", view: require('../assets/sun.png')},
     {degrees: "81°", hour: "3pm", view: require('../assets/sun.png')},
     {degrees: "81°", hour: "4pm", view: require('../assets/sun.png')},
     {degrees: "80°", hour: "5pm", view: require('../assets/cloud.png')}
   ];

}

  render() {
    return (
        <FlatList
        showsHorizontalScrollIndicator = {false}
         horizontal
          data = {this.data}
          renderItem = { ({ item }) => (
            <View style = {{padding: 10, justifyContent: 'center', borderTopWidth: 0.5, borderBottomWidth: 0.5, borderColor: '#fff'}}>
            <Text style = {{color: 'white', paddingBottom: 5, textAlign: 'center'}}>{item.degrees}</Text>
              <Image source = {item.view} style = {{width: 25, height: 25, resizeMode: 'contain'}}/>
            <Text style = {{color: 'white', paddingTop: 5, textAlign: 'center'}}>{item.hour}</Text>
            </View>
          )}
          keyExtractor = {item => item.hour}
        />
    );
  }

}

export default HoursList;
