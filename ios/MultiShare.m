/*
 * Copy from react-native `RCTActionSheetManager.m` and add `images` field.
 */

#import "MultiShare.h"

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTLog.h>
#import <React/RCTUIManager.h>
#import <React/RCTUtils.h>

@implementation MultiShare

RCT_EXPORT_MODULE()

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

/*
 * The `anchor` option takes a view to set as the anchor for the share
 * popup to point to, on iPads running iOS 8. If it is not passed, it
 * defaults to centering the share popup on screen without any arrows.
 */
- (CGRect)sourceRectInView:(UIView *)sourceView
             anchorViewTag:(NSNumber *)anchorViewTag
{
  if (anchorViewTag) {
    UIView *anchorView = [self.bridge.uiManager viewForReactTag:anchorViewTag];
    return [anchorView convertRect:anchorView.bounds toView:sourceView];
  } else {
    return (CGRect){sourceView.center, {1, 1}};
  }
}

/*
 * Convert the URL to UIImage instance to share as images in wechat
 */
- (void)addImageToItems:(NSMutableArray *)items
                  url:(NSURL *)URL
      failureCallback:(RCTResponseErrorBlock)failureCallback
{
  if ([URL.scheme.lowercaseString isEqualToString:@"data"]) {
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:URL
                                         options:(NSDataReadingOptions)0
                                           error:&error];
    if (!data) {
      failureCallback(error);
      return;
    }
    UIImage *image = [UIImage imageWithData:data];
    [items addObject:image];
  } else {
    UIImage *image = [UIImage imageWithContentsOfFile:URL.path];
    [items addObject:image];
  }
}

RCT_EXPORT_METHOD(showShareActionSheetWithOptions:(NSDictionary *)options
                  failureCallback:(RCTResponseErrorBlock)failureCallback
                  successCallback:(RCTResponseSenderBlock)successCallback)
{
  if (RCTRunningInAppExtension()) {
    RCTLogError(@"Unable to show action sheet from app extension");
    return;
  }
  
  NSMutableArray<id> *items = [NSMutableArray array];
  NSString *message = [RCTConvert NSString:options[@"message"]];
  if (message) {
    [items addObject:message];
  }
  NSURL *URL = [RCTConvert NSURL:options[@"url"]];
  if (URL) {
    if ([URL.scheme.lowercaseString isEqualToString:@"data"]) {
      NSError *error;
      NSData *data = [NSData dataWithContentsOfURL:URL
                                           options:(NSDataReadingOptions)0
                                             error:&error];
      if (!data) {
        failureCallback(error);
        return;
      }
      [items addObject:data];
    } else {
      [items addObject:URL];
    }
  }
  NSArray<NSURL *> *IMAGES = [RCTConvert NSURLArray:options[@"images"]];
  for (NSURL *image in IMAGES) {
    [self addImageToItems:items url:image failureCallback:failureCallback];
  }

  if (items.count == 0) {
    RCTLogError(@"No `url` or `message` to share");
    return;
  }
  
  UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
  
  NSString *subject = [RCTConvert NSString:options[@"subject"]];
  if (subject) {
    [shareController setValue:subject forKey:@"subject"];
  }
  
  NSArray *excludedActivityTypes = [RCTConvert NSStringArray:options[@"excludedActivityTypes"]];
  if (excludedActivityTypes) {
    shareController.excludedActivityTypes = excludedActivityTypes;
  }
  
  UIViewController *controller = RCTPresentedViewController();
  shareController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, __unused NSArray *returnedItems, NSError *activityError) {
    if (activityError) {
      failureCallback(activityError);
    } else {
      successCallback(@[@(completed), RCTNullIfNil(activityType)]);
    }
  };
  
  shareController.modalPresentationStyle = UIModalPresentationPopover;
  NSNumber *anchorViewTag = [RCTConvert NSNumber:options[@"anchor"]];
  if (!anchorViewTag) {
    shareController.popoverPresentationController.permittedArrowDirections = 0;
  }
  shareController.popoverPresentationController.sourceView = controller.view;
  shareController.popoverPresentationController.sourceRect = [self sourceRectInView:controller.view anchorViewTag:anchorViewTag];
  
  [controller presentViewController:shareController animated:YES completion:nil];
  
  shareController.view.tintColor = [RCTConvert UIColor:options[@"tintColor"]];
}

@end
