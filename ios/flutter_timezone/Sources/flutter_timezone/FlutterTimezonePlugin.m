#import "./include/flutter_timezone/FlutterTimezonePlugin.h"

@implementation FlutterTimezonePlugin

- (NSLocale *)getPreferredLocale {
  NSArray *preferredLanguages = [NSLocale preferredLanguages];
  if ([preferredLanguages count] > 0) {
    NSString *preferredIdentifier = [preferredLanguages firstObject];
    return [[NSLocale alloc] initWithLocaleIdentifier:preferredIdentifier];
  }
  return [NSLocale currentLocale];
}
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
    NSString *localeIdentifier = call.arguments;
    NSLocale *locale = nil;
    
    if (localeIdentifier != nil && [localeIdentifier isKindOfClass:[NSString class]]) {
      NSLocale *requestedLocale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
      // Check if the locale is valid by verifying it has a valid language code
      if ([requestedLocale languageCode] != nil) {
        locale = requestedLocale;
      } else {
        locale = nil;
      }
    } else {
      locale = [self getPreferredLocale];
    }
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *localizedName = locale != nil ? [timeZone localizedName:NSTimeZoneNameStyleStandard locale:locale] : nil;
    
    result(@{
      @"identifier": [timeZone name],
      @"localizedName": localizedName,
      @"locale": [locale localeIdentifier]
    });
  } else if([@"getAvailableTimezones" isEqualToString:call.method]) {
    NSString *localeIdentifier = call.arguments;
    NSLocale *locale = nil;
    
    if (localeIdentifier != nil && [localeIdentifier isKindOfClass:[NSString class]]) {
      NSLocale *requestedLocale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
      // Check if the locale is valid by verifying it has a valid language code
      if ([requestedLocale languageCode] != nil) {
        locale = requestedLocale;
      } else {
        locale = nil;
      }
    } else {
      locale = [self getPreferredLocale];
    }
    
    NSArray *timezoneNames = [NSTimeZone knownTimeZoneNames];
    NSMutableArray *timezones = [[NSMutableArray alloc] initWithCapacity:[timezoneNames count]];
    
    for (NSString *timezoneName in timezoneNames) {
      NSTimeZone *timezone = [NSTimeZone timeZoneWithName:timezoneName];
      NSString *localizedName = locale != nil ? [timezone localizedName:NSTimeZoneNameStyleStandard locale:locale] : nil;
      
      [timezones addObject:@{
        @"identifier": timezoneName,
        @"localizedName": localizedName,
        @"locale": [locale localeIdentifier]
      }];
    }
    
    result(timezones);
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

@end
