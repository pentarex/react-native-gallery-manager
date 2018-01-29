## Gallery Manager

####‼️Gallery manager for iOS and Android‼️

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

### NOTE: <span style="color:red">If you are using CameraRoll from react-native, you have to unlink it before using this library</span>

## Usage

```javascript
import GalleryManager from 'react-native-gallery-manager';
```

## Methods and Responses

#### Get Assets
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

#### Response

```javascript
{
   assets:[
      {
         type:'image',
         uri:'file:/storage/emulated/0/Download/ylo6z7D.jpg',
         id:38,
         filename:'ylo6z7D.jpg',
         width:3456,
         height:1944,
         creationDate:'1517064428',
         duration:0,
         mimeType:'image/jpeg'
      },
      {
         type:'image',
         uri:'file:/storage/emulated/0/Download/ylo6z7D (2).jpg',
         id:39,
         filename:'ylo6z7D (2).jpg',
         width:3456,
         height:1944,
         creationDate:'1517064428',
         duration:0,
         mimeType:'image/jpeg'
      },
      {
         type:'video',
         uri:'file:/storage/emulated/0/Download/708213662.mp4',
         id:36,
         filename:'708213662.mp4',
         width:1920,
         height:1080,
         creationDate:'1516975777',
         duration:19.186,
         mimeType:'video/mp4'
      },
      {
         type:'image',
         uri:'file:/storage/emulated/0/DCIM/Camera/IMG_20180126_090919.jpg',
         id:35,
         filename:'IMG_20180126_090919.jpg',
         width:640,
         height:480,
         creationDate:'1516975759',
         duration:0,
         mimeType:'image/jpeg'
      },
      {
         type:'image',
         uri:'file:/storage/emulated/0/DCIM/Camera/IMG_20180126_084854.jpg',
         id:34,
         filename:'IMG_20180126_084854.jpg',
         width:640,
         height:480,
         creationDate:'1516974534',
         duration:0,
         mimeType:'image/jpeg'
      },
      {
         type:'image',
         uri:'file:/storage/emulated/0/DCIM/Camera/IMG_20180126_084848.jpg',
         id:33,
         filename:'IMG_20180126_084848.jpg',
         width:640,
         height:480,
         creationDate:'1516974528',
         duration:0,
         mimeType:'image/jpeg'
      },
      {
         type:'image',
         uri:'file:/storage/emulated/0/DCIM/Camera/IMG_20180126_084843.jpg',
         id:32,
         filename:'IMG_20180126_084843.jpg',
         width:640,
         height:480,
         creationDate:'1516974523',
         duration:0,
         mimeType:'image/jpeg'
      }
   ],
   totalAssets:7,
   next:7,
   hasMore:false
}
```

#### Get Albums
```javascript
GalleryManager.getAlbums().then((response) => {

}).catch((err) => {
    // no rejects are defined currently on iOS
})
```

#### Response

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
        ],
    totalAlbums: 24 
}
```

#### Check Permission
```javascript
GalleryManager.requestAuthorization().then((response) => {
    // response = true || false
}).catch((err) => {
    // no rejects are defined currently on iOS
})
```


### Roadmap
* Resize Image
* Convert Video to mp4 (iOS only)


### Suggestions and forks are welcome




