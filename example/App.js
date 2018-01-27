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
  Image,
  ScrollView
} from 'react-native';
import GalleryManager from 'react-native-gallery-manager';

export default class App extends Component<{}> {

  constructor(props) {
    super(props)
    this.state = {
      assets: []
    };
    GalleryManager.getAssets({type: 'all', limit: 10, startFrom: 0}).then((response)=> {
      this.setState({assets : response.assets});
      console.log(response);
    })
    
  };
  
  render() {
    return (
      <ScrollView style={styles.scrollView}>
        {this.state.assets.map((asset, index) => {
          return (<Image style={styles.img} source={{uri: asset.uri}} key={asset.id}/>);
        })}
      </ScrollView>
      
    );
  }
}

const styles = StyleSheet.create({
  scrollView: {
    flex: 1
  },
  img: {
    height: 200,
    width: 200
  },

});
