import React, {Component} from 'react';
import {FlatList, View, Text, Image} from 'react-native';

class DaysList extends Component {
  constructor(props) {
    super(props);

    this.data = [
      {day: "Sunday", high: 81, low: 70, view: require('../assets/cloud.png')},
      {day: "Monday", high: 82, low: 70, view: require('../assets/sun.png')},
      {day: "Tuesday", high: 82, low: 69, view: require('../assets/cloud.png')},
      {day: "Wednesday", high: 89, low: 73, view: require('../assets/sun.png')},
      {day: "Thursday", high: 90, low: 71, view: require('../assets/sun.png')},
      {day: "Friday", high: 78, low: 68, view: require('../assets/cloud.png')},
      {day: "Saturday", high: 75, low: 68, view: require('../assets/cloud.png')}
    ];
  }

  render() {
    return (
      <FlatList
        showsVerticalScrollIndicator = {false}
        vertical
        data = {this.data}
        renderItem = { ({item}) => (
          <View style = {{flexDirection: 'row', paddingTop: 5, paddingBottom: 5}}>
          <Text style = {{fontSize: 18, flex: 1, color: 'white', paddingLeft: 10, justifyContent: 'flex-start'}}>{item.day}</Text>
          <Image source = {item.view} style = {{flex: 1, width: 25, height: 25, resizeMode: 'contain', justifyContent: 'center'}}/>
          <Text style = {{fontSize: 18, flex: 0.5, color: 'white'}}>82</Text>
          <Text style = {{fontSize: 18, flex: 0.5, opacity: 0.8, color: 'white', justifyContent: 'flex-end', paddingRight: 10}}>69</Text>
          </View>
        )}
        keyExtractor = {item => item.day}
      />
    )
  }

}

export default DaysList;
