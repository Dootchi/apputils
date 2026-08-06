#import <Foundation/Foundation.h>

#import "DpSDK.h"

double DpSDKVersionNumber = 1.0;
const unsigned char DpSDKVersionString[] = "simulator-unavailable";

@implementation DpSDK

+ (bool)dpInit {
  return false;
}

+ (NSString *)dpGetTicket {
  return @"";
}

+ (bool)ReportDeviceStatus:(NSString *)label {
  (void)label;
  return false;
}

@end
