#import "ApputilsPlugin.h"

#import "AntiScrapingHandler.h"

static NSString *const AppUtilsAntiScrapingChannel =
    @"com.dootchi.apputils/anti_scraping";

@implementation ApputilsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:AppUtilsAntiScrapingChannel
            binaryMessenger:registrar.messenger];
  AntiScrapingHandler *handler = [[AntiScrapingHandler alloc] init];
  [registrar addMethodCallDelegate:handler channel:channel];
}

@end
