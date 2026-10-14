#import "AntiScrapingHandler.h"

#import <DpSDK/DpSDK.h>
#import <TargetConditionals.h>

static NSString *const AppUtilsCuidArgumentKey = @"cuid";
static NSString *const AppUtilsDpCuidKey = @"DP_CUID";

@interface AntiScrapingHandler ()
@property(nonatomic, assign) BOOL initialized;
@property(nonatomic, strong) dispatch_queue_t workerQueue;
@end

@implementation AntiScrapingHandler

- (instancetype)init {
  self = [super init];
  if (self) {
    dispatch_queue_attr_t queueAttributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0);
    _workerQueue = dispatch_queue_create("ai.socialapps.apputils.anti-scraping", queueAttributes);
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  if ([call.method isEqualToString:@"antiScraping.initialize"]) {
    NSString *cuid = @"";
    if ([call.arguments isKindOfClass:[NSDictionary class]]) {
      id value = ((NSDictionary *)call.arguments)[AppUtilsCuidArgumentKey];
      if ([value isKindOfClass:[NSString class]]) {
        cuid = value;
      }
    }

    [self runAsyncWithResult:result operation:^id _Nullable(FlutterError **error) {
      [[NSUserDefaults standardUserDefaults] setObject:cuid forKey:AppUtilsDpCuidKey];
      [self ensureInitialized:error];
      return nil;
    }];
    return;
  }

  if ([call.method isEqualToString:@"antiScraping.getTicket"]) {
    [self runAsyncWithResult:result operation:^id _Nullable(FlutterError **error) {
      if (![self ensureInitialized:error]) {
        return nil;
      }
      NSString *ticket = [DpSDK dpGetTicket] ?: @"";
      NSLog(@"[DpSdk] getTicket -> %@", ticket);
      return ticket;
    }];
    return;
  }

  if ([call.method isEqualToString:@"antiScraping.reportDeviceStatus"]) {
    NSString *label = nil;
    if ([call.arguments isKindOfClass:[NSDictionary class]]) {
      id value = ((NSDictionary *)call.arguments)[@"label"];
      if ([value isKindOfClass:[NSString class]]) {
        label = value;
      }
    }
    if (label.length == 0) {
      result([FlutterError errorWithCode:@"invalid_argument"
                                 message:@"label must not be empty."
                                 details:nil]);
      return;
    }

    [self runAsyncWithResult:result operation:^id _Nullable(FlutterError **error) {
      if (![self ensureInitialized:error]) {
        return nil;
      }
      return @([DpSDK ReportDeviceStatus:label]);
    }];
    return;
  }

  result(FlutterMethodNotImplemented);
}

- (BOOL)ensureInitialized:(FlutterError **)error {
#if TARGET_OS_SIMULATOR
  NSLog(@"[DpSdk] sdk_unavailable: simulator is not supported");
  if (error != NULL) {
    *error = [FlutterError
        errorWithCode:@"sdk_unavailable"
               message:@"DpSDK is unavailable in the iOS simulator. Use a physical device."
               details:nil];
  }
  return NO;
#else
  if (self.initialized) {
    return YES;
  }

  @try {
    if (![DpSDK dpInit]) {
      NSLog(@"[DpSdk] initialization_failed: dpInit returned false");
      if (error != NULL) {
        *error = [FlutterError errorWithCode:@"initialization_failed"
                                     message:@"DpSDK initialization returned false."
                                     details:nil];
      }
      return NO;
    }
    self.initialized = YES;
    return YES;
  } @catch (NSException *exception) {
    NSLog(@"[DpSdk] initialization_failed exception: %@", exception.reason);
    if (error != NULL) {
      *error = [FlutterError errorWithCode:@"initialization_failed"
                                   message:@"DpSDK initialization raised an exception."
                                   details:exception.reason];
    }
    return NO;
  }
#endif
}

- (void)runAsyncWithResult:(FlutterResult)result
                 operation:(id _Nullable (^)(FlutterError **error))operation {
  dispatch_async(self.workerQueue, ^{
    FlutterError *error = nil;
    id value = nil;
    @try {
      value = operation(&error);
    } @catch (NSException *exception) {
      NSLog(@"[DpSdk] native_error exception: %@", exception.reason);
      error = [FlutterError errorWithCode:@"native_error"
                                  message:@"Unexpected DpSDK exception."
                                  details:exception.reason];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      result(error ?: value);
    });
  });
}

@end
