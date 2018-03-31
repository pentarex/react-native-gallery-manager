## Gallery Manager

#### Gallery manager for iOS and Android


## Installation

```bash
npm install --save react-native-gallery-manager
```

or

```bash
yarn add react-native-gallery-manager
```

and then

```bash
react-native link
```

<span style="color:red"> NOTE: If you are using CameraRoll from react-native, you have to unlink it before using this library</span>


## Issues
* If the image is not being shown in Android try the following
	* [increase fresco memory](https://medium.com/in-the-hudl/configure-fresco-in-react-native-28c2bc7dcc4d)
	* resizeMethod='resize' to the Image component
	* removeClippedSubviews={true} to ScrollView (FlatList, SectionList)
	* android:largeHeap="true" to the android manifest.xml in the application section (I dont recommend that but, you got to do, what you got to do....)

[#10569](https://github.com/facebook/react-native/issues/10569)
[#13600](https://github.com/facebook/react-native/issues/13600)
[#10470](https://github.com/facebook/react-native/issues/10470)



## Usage

```javascript
import GalleryManager from 'react-native-gallery-manager';
```

## Methods and Responses

### Get Assets
```javascript
GalleryManager.getAssets({
    type: 'all',             
    startFrom: 0,
}).then((response) => {

}).catch((err) => {
    // no rejects are defined currently on iOS
})
```

| Props        	| Type          	| Default | Notes  |
| ------------- 	|:-------------:	| :------:|:-----|
| type      		| String 			| 'all'|Type of the asset returned, can be 'image', 'video', 'all' |
| limit      		| Number 	     	| 10|how many asset to return in one call |
| startFrom 		| Number      	| 0|From which index to start |
| albumName 		| String      	| | Set the name of the album from which you want assets (Optional) |

##### Response

```javascript
{
   assets:[
      {
         type:'image',
         uri:'file:///storage/emulated/0/Download/ylo6z7D.jpg',
         id:38,
         filename:'ylo6z7D.jpg',
         width:3456,
         height:1944,
         creationDate:'1517064428',
         duration:0,
         mimeType:'image/jpeg'
      },
      ...
   ],
   totalAssets:7,
   next:7,
   hasMore:false
}
```

### Get Albums
```javascript
GalleryManager.getAlbums().then((response) => {

}).catch((err) => {
    // no rejects are defined currently on iOS
})
```

##### Response

```javascript
{ 
    albums: 
        [ 
            { 
            	assetCount: 616, title: 'WhatsApp' 
            },
            { 
            	assetCount: 6, title: 'Instagram' 
            },
            { 
            	assetCount: 1, title: 'Twitter' 
            },
            ...
        ],
    totalAlbums: 24 
}
```

### Check Permission
```javascript
GalleryManager.requestAuthorization(title, message).then((response) => {
    // response.isAuthorized = true || false
}).catch((err) => {
    
})
```
| Props        	| Type          	| Default | Notes  |
| ------------- 	|:-------------:	| :------:|:-----|
| title      		| String 			| | (Android) title of the dialog | 
| message      | String 	     	| | (Android) message in the dialog |

#### Convert Video (iOS only)
```javascript
GalleryManager.convertVideo({
	id: '98F14DF6-3BF9-4D1B-A6E0-0A36A25AE377/L0/001',
	convertTo: 'm4v',
	quality: 'low'
}).then((response) => {
	console.log(response);
}).catch((err) => {
   console.log(err)
});
```

| Props        	| Type          	| Default | Notes  |
| ------------- 	|:-------------:	| :------:|:-----|
| id      		| String 			| | The id of the video asset | 
| convertTo      | String 	     	| |Can be mpeg4, m4v or mov |
| quality 		| String      	| original |Can be original, high, medium, low |

##### Response
```javascript
{ 
  mimeType: 'video/x-m4v',
  path: 'file:///Users/pentarex/Library/Developer/CoreSimulator/Devices/81873DB4-A220-4F60-88B8-87521BB231E6/data/Containers/Data/Application/91EE6566-4D04-4E33-9608-EDB06DA6C6D2/Documents/8DAEDFBC-9E16-442D-A98F-E145F429DA0B.m4v',
  filename: '8DAEDFBC-9E16-442D-A98F-E145F429DA0B.m4v',
  type: 'video',
  duration: 19.185833333333335 
}
```
The reason the library is returning the path of the file in this format is that the video can be send later to server with fetch library. If the url starts with assets-library:// not with file:// react-native will not send it.



### Roadmap


### Suggestions and forks are welcome




