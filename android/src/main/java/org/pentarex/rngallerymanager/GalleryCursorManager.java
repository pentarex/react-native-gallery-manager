package org.pentarex.rngallerymanager;

import android.content.ContentResolver;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;

/**
 * Created by pentarex on 26.01.18.
 */

public class GalleryCursorManager {

    public static Cursor getAssetCursor(String requestedType, String albumName, ReactApplicationContext reactContext) {
        String[] projection = new String[]{
                MediaStore.Images.Media.DATE_ADDED,
                MediaStore.Images.Media.MIME_TYPE,
                MediaStore.Images.Media.DATA,
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Video.Media.DURATION,
                MediaStore.Images.Media._ID,
                MediaStore.Images.Media.WIDTH,
                MediaStore.Images.Media.HEIGHT,
                MediaStore.Images.Media.TITLE,
                MediaStore.Files.FileColumns.MEDIA_TYPE,
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME
        };


        String selection;
        switch (requestedType.toLowerCase()){
            case "image": {
                selection = MediaStore.Files.FileColumns.MEDIA_TYPE + "=" + MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE;
                break;
            }
            case "video": {
                selection = MediaStore.Files.FileColumns.MEDIA_TYPE + "=" + MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO;
                break;
            }
            default: {
                selection = MediaStore.Files.FileColumns.MEDIA_TYPE + "=" + MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE
                        + " OR "
                        + MediaStore.Files.FileColumns.MEDIA_TYPE + "=" + MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO;
                break;
            }
        }

        String[] selectionArgs = null;
        if (albumName != null) {
            selection += ") AND (" + MediaStore.Images.Media.BUCKET_DISPLAY_NAME + "= ?";
            selectionArgs = new String[] { albumName };
        }

        String sortByAndLimit = MediaStore.Files.FileColumns.DATE_ADDED + " DESC ";

        ContentResolver contentResolver = reactContext.getContentResolver();
        Uri queryUri = MediaStore.Files.getContentUri("external");

        return contentResolver.query(queryUri, projection, selection, selectionArgs, sortByAndLimit);
    }

    public static Cursor getAlbumCursor(ReactApplicationContext reactContext) {
        String[] projection = new String[] {
                MediaStore.Images.ImageColumns.BUCKET_DISPLAY_NAME,
                MediaStore.Images.ImageColumns.BUCKET_ID,
                MediaStore.Images.ImageColumns.DATE_MODIFIED,
                MediaStore.Images.ImageColumns.DATA,
                MediaStore.Video.VideoColumns.BUCKET_DISPLAY_NAME,
                MediaStore.Video.VideoColumns.BUCKET_ID,
                MediaStore.Video.VideoColumns.DATE_MODIFIED,
                MediaStore.Video.VideoColumns.DATA,
                "count(_data) as assetCount"
        };

        ContentResolver contentResolver = reactContext.getContentResolver();
        Uri queryUri = MediaStore.Files.getContentUri("external");
        String BUCKET_GROUP_BY = MediaStore.Files.FileColumns.MEDIA_TYPE + "=" + MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE
                + " OR "
                + MediaStore.Files.FileColumns.MEDIA_TYPE + "=" + MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO
                + " and 1) GROUP BY 1,(2";


        return contentResolver.query(queryUri, projection, BUCKET_GROUP_BY, null, null);

    }
}
