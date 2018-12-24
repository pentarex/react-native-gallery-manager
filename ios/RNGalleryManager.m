#import "RNGalleryManager.h"

#import <React/RCTLog.h>
#import <React/RCTConvert.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <Photos/Photos.h>

@implementation RCTConvert (PHAssetGroup)

+(NSPredicate *) PHAssetType:(id)json
{
  static NSDictionary<NSString *, NSPredicate *> *options;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    options = @{
                @"image": [NSPredicate predicateWithFormat:@"(mediaType = %d)", PHAssetMediaTypeImage],
                @"video": [NSPredicate predicateWithFormat:@"(mediaType = %d)", PHAssetMediaTypeVideo],
                @"all": [NSPredicate predicateWithFormat:@"(mediaType = %d) || (mediaType = %d)", PHAssetMediaTypeImage, PHAssetMediaTypeVideo]
                };
  });
  
  NSPredicate *filter = options[json ?: @"image"];
  if (!filter) {
    RCTLogError(@"Invalid type option: '%@'. Expected one of 'image',"
                "'video' or 'all'.", json);
  }
  return filter ?: [NSPredicate predicateWithFormat:@"(mediaType = %d) || (mediaType = %d)", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
}

+(NSString *) PHCompressType:(id)json
{
  static NSDictionary<NSString *, NSString *> *options;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    options = @{
                @"original": AVAssetExportPresetPassthrough,
                @"low": AVAssetExportPresetLowQuality,
                @"medium": AVAssetExportPresetMediumQuality,
                @"high": AVAssetExportPresetHighestQuality,
                };
  });
  
  NSString *filter = options[json ?: AVAssetExportPresetPassthrough];
  if (!filter) {
    RCTLogError(@"Invalid type option: '%@'. Expected one of 'original',"
                "'low', 'medium' or 'high'.", json);
  }
  return filter ?: AVAssetExportPresetPassthrough;
}

+(AVFileType) PHFileType:(id)json
{
  static NSDictionary<NSString *, AVFileType> *options;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    options = @{
                @"mpeg4": AVFileTypeMPEG4,
                @"m4v": AVFileTypeAppleM4V,
                @"mov": AVFileTypeQuickTimeMovie
                };
  });
  
  AVFileType filter = options[json ?: AVFileTypeMPEG4];
  if (!filter) {
    RCTLogError(@"Invalid type option: '%@'. Expected one of 'mpeg4',"
                "'m4v' or 'mov'.", json);
  }
  return filter ?: AVFileTypeMPEG4;
}


@end



@implementation RNGalleryManager
RCT_EXPORT_MODULE();

/* Get the assets from the gallery */
RCT_EXPORT_METHOD(getAssets:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  checkPhotoLibraryConfig(); // check if the permission is set in info.plist
  NSPredicate *predicate = [RCTConvert PHAssetType:params[@"type"]]; // can be video, image or all
  NSUInteger limit = [RCTConvert NSInteger:params[@"limit"]] ?: 10; // how many assets to return DEFAULT 10
  NSUInteger startFrom = [RCTConvert NSInteger:params[@"startFrom"]] ?: 0; // from which index should start DEFAULT 0
  NSString *albumName = [RCTConvert NSString:params[@"albumName"]] ?: @""; // album name
  
  
  // Build the options based on the user request (currently only type of assets)
  PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
  fetchOptions.predicate = predicate;
  fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
  
  
  PHFetchResult<PHAsset *> * _Nonnull fetchResults;
  if (![albumName isEqualToString:@""])
  {
    PHFetchOptions *albumFetchOptions = [[PHFetchOptions alloc] init];
    albumFetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", albumName];
    __block PHAssetCollection *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                                     subtype:PHAssetCollectionSubtypeAny
                                                                                     options:albumFetchOptions].firstObject;
    fetchResults = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
  }
  else
  {
    
    fetchResults = [PHAsset fetchAssetsWithOptions:fetchOptions]; // get the assets
  }
  
  BOOL __block hasMore = NO;
  NSInteger endIndex = startFrom + limit;
  NSMutableArray<NSDictionary<NSString *, id> *> *assets = [NSMutableArray new];
  NSIndexSet *indexSet = [NSIndexSet alloc];
  int resultsLeft = (int)[fetchResults count] - (int)(startFrom + limit);
  if ( resultsLeft > 0)
  {
    indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(startFrom, limit)];
    hasMore = YES; // check if there are more results
  }
  else
  {
    indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(startFrom, (int)[fetchResults count] - startFrom)];
    endIndex = (int)[fetchResults count]-1;
  }
  
  NSArray<PHAsset*>  *results = [fetchResults objectsAtIndexes:indexSet];
  
  for (PHAsset* asset in results) {
    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset ];
    if ([resources count] < 1) continue;
    NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
    NSString *uit = ((PHAssetResource*)resources[0]).uniformTypeIdentifier;
    NSString *mimeType = (NSString *)CFBridgingRelease(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef _Nonnull)(uit), kUTTagClassMIMEType));
    CFStringRef extension = UTTypeCopyPreferredTagWithClass((__bridge CFStringRef _Nonnull)(uit), kUTTagClassFilenameExtension);
    
    [assets addObject:@{
                        @"type": [self getMediaType:([asset mediaType])],
                        @"width": @([asset pixelWidth]),
                        @"height": @([asset pixelHeight]),
                        @"filename": orgFilename ?: @"",
                        @"mimeType": mimeType ?: @"",
                        @"id": [asset localIdentifier],
                        @"creationDate": [asset creationDate],
                        @"uri": [self buildAssetUri:[asset localIdentifier] extension:extension lowQ:NO],
                        @"lowQualityUri": [self buildAssetUri:[asset localIdentifier] extension:extension lowQ:YES],
                        @"duration": @([asset duration])
                        }];
  }
  
  // resolve
  resolve(
          @{
            @"assets": assets,
            @"hasMore": @(hasMore),
            @"next": @(endIndex),
            @"totalAssets": @(fetchResults.count)
            }
          );
  
  // reject
  
  
}

/* Get list of albums */
RCT_EXPORT_METHOD(getAlbums: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  checkPhotoLibraryConfig(); // check if the permission is set in info.plist
  PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
  PHFetchResult<PHAssetCollection *> * _Nonnull albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
  
  NSMutableArray<NSDictionary<NSString *, id> *> *result = [NSMutableArray new];
  [albums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull album, NSUInteger index, BOOL * _Nonnull stop) {
    [result addObject:@{
                        @"title": [album localizedTitle],
                        @"assetCount": @([album estimatedAssetCount])
                        }];
  }];
  
  resolve(
          @{
            @"albums": result,
            @"totalAlbums": @(albums.count)
            }
          );
  
  
}

RCT_EXPORT_METHOD(convertVideo:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  
  // Converting the params from the user
  NSString *assetId = [RCTConvert NSString:params[@"id"]] ?: @"";
  AVFileType outputFileType = [RCTConvert PHFileType:params[@"convertTo"]] ?: AVFileTypeMPEG4;
  NSString *pressetType = [RCTConvert PHCompressType:params[@"quality"]] ?: AVAssetExportPresetPassthrough;
  
  // Throwing some errors to the user if he is not careful enough
  if ([assetId isEqualToString:@""]) {
    NSError *error = [NSError errorWithDomain:@"RNGalleryManager" code: -91 userInfo:nil];
    reject(@"Missing Parameter", @"id is mandatory", error);
    return;
  }
  
  // Getting Video Asset
  NSArray* localIds = [NSArray arrayWithObjects: assetId, nil];
  PHAsset * _Nullable videoAsset = [PHAsset fetchAssetsWithLocalIdentifiers:localIds options:nil].firstObject;
  
  // Getting information from the asset
  NSString *mimeType = (NSString *)CFBridgingRelease(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef _Nonnull)(outputFileType), kUTTagClassMIMEType));
  CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(mimeType), NULL);
  NSString *extension = (NSString *)CFBridgingRelease(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension));
  
  // Creating output url and temp file name
  NSURL * _Nullable temDir = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
  NSString *newFileName = [[NSUUID UUID] UUIDString];
  NSString *tempName = [NSString stringWithFormat: @"%@.%@", newFileName, extension];
  NSURL *outputUrl = [NSURL fileURLWithPath:[temDir.path stringByAppendingPathComponent:tempName]];
  
  // Setting video export session options
  PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
  videoRequestOptions.networkAccessAllowed = YES;
  videoRequestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
  
  // Creating new export session
  [[PHImageManager defaultManager] requestExportSessionForVideo:videoAsset options:videoRequestOptions exportPreset:pressetType resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
    
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = outputFileType;
    exportSession.outputURL = outputUrl;
    // Converting the video and waiting to see whats going to happen
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
      switch ([exportSession status])
      {
        case AVAssetExportSessionStatusFailed:
        {
          NSError* error = exportSession.error;
          NSString *codeWithDomain = [NSString stringWithFormat:@"E%@%zd", error.domain.uppercaseString, error.code];
          reject(codeWithDomain, error.localizedDescription, error);
          break;
        }
        case AVAssetExportSessionStatusCancelled:
        {
          NSError *error = [NSError errorWithDomain:@"RNGalleryManager" code: -91 userInfo:nil];
          reject(@"Cancelled", @"Export canceled", error);
          break;
        }
        case AVAssetExportSessionStatusCompleted:
        {
          resolve(
                  @{
                    @"type": @"video",
                    @"filename": tempName ?: @"",
                    @"mimeType": mimeType ?: @"",
                    @"path": outputUrl.absoluteString,
                    @"duration": @([videoAsset duration])
                    }
                  );
          break;
        }
        default:
        {
          NSError *error = [NSError errorWithDomain:@"RNGalleryManager" code: -91 userInfo:nil];
          reject(@"Unknown", @"Unknown status", error);
          break;
        }
      }
    }];
  }];
  
  
  
  
  
}

/* To Request Authorization for photos */
RCT_EXPORT_METHOD(requestAuthorization:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    
    resolve(@{
              @"isAuthorized" : @((BOOL)(status == PHAuthorizationStatusAuthorized))
              });
  }];
}


// Get the media type
-(NSString *)getMediaType:(PHAssetMediaType)mediaType
{
  if(mediaType == PHAssetMediaTypeVideo) return @"video";
  if(mediaType == PHAssetMediaTypeImage) return @"image";
  return @"unknown";
}

// Build asset url out of localIdentifier and extension
-(NSString *)buildAssetUri:(NSString *)localIdentifier extension:(CFStringRef)extension lowQ:(Boolean)lowq
{
  NSRange range = [localIdentifier rangeOfString:@"/"];
  if (range.location != NSNotFound) {
    NSString *identifier = [localIdentifier substringWithRange:NSMakeRange(0, range.location)];
    // assets-library://asset/asset.JPG?id=762BFA34-62B1-40FF-B214-44BDE5E98B34&ext=JPG
    NSString *uri;
    if (lowq) {
      uri = [NSString stringWithFormat:@"lowq-assets-library://asset/asset.%@?id=%@&ext=%@", extension, identifier, extension];
    } else {
      uri = [NSString stringWithFormat:@"assets-library://asset/asset.%@?id=%@&ext=%@", extension, identifier, extension];
    }
    
    return uri;
  }
  return @"";
}

// check if the permission is set in info.plist
static void checkPhotoLibraryConfig()
{
#if RCT_DEV
  if (![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"]) {
    RCTLogError(@"NSPhotoLibraryUsageDescription key must be present in Info.plist to use camera roll.");
  }
#endif
}

@end

