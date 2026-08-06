//
//  DpSDK.h
//  DpSDK
//
//  Created by huafeng on 2022/9/29.
//

#import <Foundation/Foundation.h>

//! Project version number for DpSDK.
FOUNDATION_EXPORT double DpSDKVersionNumber;

//! Project version string for DpSDK.
FOUNDATION_EXPORT const unsigned char DpSDKVersionString[];


// In this header, you should import all the public headers of your framework using statements like #import <DpSDK/PublicHeader.h>


@interface DpSDK : NSObject
//初始化
+ (bool) dpInit;

//获取dp-ticket
+ (NSString*) dpGetTicket;

//上报当前设备数据
+ (bool) ReportDeviceStatus:(NSString*)label;

@end
