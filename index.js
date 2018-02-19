import {
    NativeModules
} from 'react-native';

const RNGalleryManager = NativeModules.RNGalleryManager;

const GalleryManager = {
    /**
     * Get Assets from the gallery
     * @param {object} params           Object with params
     * @param {string} params.type      Type of the asset. Can be - image, video, all
     * @param {number} params.limit     Number of assets returned
     * @param {number} params.startFrom From which index to start
     * @param {string} params.albumName If requesting items from album -> set the album name
     */
    getAssets(params) {
        return RNGalleryManager.getAssets(params);
    },

    /**
     * To Request authorization for access photos
     * returns Promise
     */
    requestAuthorization() {
        return RNGalleryManager.requestAuthorization();
    },

    /**
     * Get List with album names
     */
    getAlbums() {
        return RNGalleryManager.getAlbums();
    },

    /**
     * Convert video
     */
    convertVideo(params) {
        return RNGalleryManager.convertVideo(params);
    }
}

module.exports = GalleryManager;