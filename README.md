## Gallery Manager

Gallery manager for iOS and Android (android under development)

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

## Usage

```javascript
import GalleryManager from 'react-native-gallery-manager';
```

## Methods and Responses

#### Get Assets
```javascript
/**
 * Get Assets from the gallery
 * @param {object} params           Object with params
 * @param {string} params.type      Type of the asset. Can be - image, video, all
 * @param {number} params.limit     Number of assets returned
 * @param {number} params.startFrom From which index to start
 * @param {string} params.albumName If requesting items from album -> set the album name
 */
GalleryManager.getAssets({
    type: 'image',              // Type of the asset. Can be - image, video, all (default image)
    limit: 5,                   // Number of assets returned (default 10)
    startFrom: 0,               // From which index to start (default 0) 
    albumName: 'Instagram'      // If requesting items from album -> set the album name (Optional)
}).then((response) => {

}).catch((err) => {
    // no rejects are defined currently on iOS
})
```

#### Response

```json
{ totalAssets: 7771,
  assets: 
   [ { asset: 
        { creationDate: null,
          mimeType: 'image/png',
          duration: 0,
          id: '9A303CC7-65AB-4661-A10D-35BBCCC54EEE/L0/001',
          width: 750,
          height: 1334,
          filename: 'IMG_2864.PNG',
          type: 'image',
          uri: 'assets-library://asset/asset.png?id=9A303CC7-65AB-4661-A10D-35BBCCC54EEE&ext=png' } },
     { asset: 
        { creationDate: null,
          mimeType: 'image/png',
          duration: 0,
          id: 'D9EEB5DC-46BB-4FD0-B1B9-539FFCA36BCD/L0/001',
          width: 750,
          height: 1334,
          filename: 'IMG_2862.PNG',
          type: 'image',
          uri: 'assets-library://asset/asset.png?id=D9EEB5DC-46BB-4FD0-B1B9-539FFCA36BCD&ext=png' } },
     { asset: 
        { creationDate: null,
          mimeType: 'video/quicktime',
          duration: 32.69,
          id: 'F5FBF7A9-8321-4081-AB1A-03E189B778F7/L0/001',
          width: 1080,
          height: 1920,
          filename: 'IMG_2861.MOV',
          type: 'video',
          uri: 'assets-library://asset/asset.mov?id=F5FBF7A9-8321-4081-AB1A-03E189B778F7&ext=mov' } },
     { asset: 
        { creationDate: null,
          mimeType: 'image/jpeg',
          duration: 0,
          id: '413D14D6-21A1-4366-8FCF-78B0843C0FDE/L0/001',
          width: 2096,
          height: 3724,
          filename: '1223951E-2F69-4C70-B720-FD1FFD75067D.jpg',
          type: 'image',
          uri: 'assets-library://asset/asset.jpeg?id=413D14D6-21A1-4366-8FCF-78B0843C0FDE&ext=jpeg' } } ],
  end_index: 4,
  hasMore: true }
```

#### Get Albums
```javascript
/**
 * Get List with album names
 */
GalleryManager.getAlbums()
.then((response) => {

}).catch((err) => {
    // no rejects are defined currently on iOS
})
```

#### Response

```json
{ 
    albums: 
        [ 
            { assetCount: 616, title: 'WhatsApp' },
            { assetCount: 6, title: 'Instagram' },
            { assetCount: 1, title: 'Twitter' },
        ],
    totalAlbums: 24 
}
```




