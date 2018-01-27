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
    fetchResults = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
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
  
  [fetchResults enumerateObjectsAtIndexes:indexSet options:NSEnumerationConcurrent usingBlock:^(PHAsset * _Nonnull asset, NSUInteger index, BOOL * _Nonnull stop) {
    // Check if the requested limit is reached
    if (limit - 1 == index) {
      *stop = YES; // stop the iteration
    }
    
    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset ];
    if ([resources count] < 1) return;
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
                        @"uri": [self buildAssetUri:[asset localIdentifier] extension:extension],
                        @"duration": @([asset duration])
                        }];
  }];
  
  
  
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



// Get the media type
-(NSString *)getMediaType:(PHAssetMediaType)mediaType
{
  if(mediaType == PHAssetMediaTypeVideo) return @"video";
  if(mediaType == PHAssetMediaTypeImage) return @"image";
  return @"unknown";
}

// Build asset url out of localIdentifier and extension
-(NSString *)buildAssetUri:(NSString *)localIdentifier extension:(CFStringRef)extension
{
  NSRange range = [localIdentifier rangeOfString:@"/"];
  if (range.location != NSNotFound) {
    NSString *identifier = [localIdentifier substringWithRange:NSMakeRange(0, range.location)];
    // assets-library://asset/asset.JPG?id=762BFA34-62B1-40FF-B214-44BDE5E98B34&ext=JPG
    NSString *uri = [NSString stringWithFormat:@"assets-library://asset/asset.%@?id=%@&ext=%@", extension, identifier, extension];
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
