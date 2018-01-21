/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View,
  NativeModules,
  Image
} from 'react-native';
import GalleryManager from 'react-native-gallery-manager';

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' +
    'Cmd+D or shake for dev menu',
  android: 'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

export default class App extends Component<{}> {

  constructor(props) {
    super(props)
    GalleryManager.getAssets({type: 'all', limit: 10, startFrom: 0}).then((response)=> {
      console.log(response);
    })
    
  };
  
  render() {
    return (
      <Image style={styles.container} source={{uri: 'assets-library://asset/asset.jpeg?id=B84E8479-475C-4727-A4A4-B77AA9980897&ext=jpeg'}}/>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
