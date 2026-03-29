#import "./include/flutter_timezone/FlutterTimezonePlugin.h"

@implementation FlutterTimezonePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_timezone"
            binaryMessenger:[registrar messenger]];
  FlutterTimezonePlugin* instance = [[FlutterTimezonePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (NSLocale *)preferredLocale {
  NSString *preferredIdentifier = NSLocale.preferredLanguages.firstObject;
  if (preferredIdentifier.length == 0) {
    return NSLocale.currentLocale;
  }

  return [[NSLocale alloc] initWithLocaleIdentifier:preferredIdentifier];
}

- (NSLocale *)localeFromArgument:(id)argument {
  if (![argument isKindOfClass:[NSString class]]) {
    return [self preferredLocale];
  }

  NSString *localeIdentifier = (NSString *)argument;
  if (localeIdentifier.length == 0) {
    return nil;
  }

  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
  NSString *languageCode = [locale objectForKey:NSLocaleLanguageCode];
  if (languageCode.length == 0) {
    return nil;
  }

  return locale;
}

- (NSDictionary *)timezoneInfoForTimeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale {
  NSString *localizedName = nil;
  NSString *localeIdentifier = nil;

  if (locale != nil) {
    localizedName = [timeZone localizedName:NSTimeZoneNameStyleStandard locale:locale];
    localeIdentifier = locale.localeIdentifier;
  }

  return @{
    @"identifier": timeZone.name,
    @"localizedName": localizedName ?: [NSNull null],
    @"locale": localeIdentifier ?: [NSNull null],
  };
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getLocalTimezone" isEqualToString:call.method]) {
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSLocale *locale = [self localeFromArgument:call.arguments];
    result([self timezoneInfoForTimeZone:timeZone locale:locale]);
  } else if([@"getAvailableTimezones" isEqualToString:call.method]) {
    NSLocale *locale = [self localeFromArgument:call.arguments];
    NSMutableArray<NSDictionary *> *timezones = [NSMutableArray array];
    for (NSString *timezoneName in [NSTimeZone knownTimeZoneNames]) {
      NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:timezoneName];
      if (timeZone != nil) {
        [timezones addObject:[self timezoneInfoForTimeZone:timeZone locale:locale]];
      }
    }
    result(timezones);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
