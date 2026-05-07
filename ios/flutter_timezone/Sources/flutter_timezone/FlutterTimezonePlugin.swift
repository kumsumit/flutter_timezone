import Flutter
import Foundation

public class FlutterTimezonePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_timezone", binaryMessenger: registrar.messenger())
    let instance = FlutterTimezonePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getLocalTimezone":
      let locale = locale(from: call.arguments)
      result(timezoneInfo(for: TimeZone.current, locale: locale))
    case "getAvailableTimezones":
      let locale = locale(from: call.arguments)
      let timezones: [[String: Any]] = TimeZone.knownTimeZoneIdentifiers.compactMap { identifier in
        guard let timeZone = TimeZone(identifier: identifier) else {
          return nil
        }
        return timezoneInfo(for: timeZone, locale: locale)
      }
      result(timezones)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func locale(from argument: Any?) -> Locale? {
    guard let localeIdentifier = argument as? String else {
      return Locale(identifier: Locale.preferredLanguages.first ?? Locale.current.identifier)
    }

    guard !localeIdentifier.isEmpty else {
      return nil
    }

    let locale = NSLocale(localeIdentifier: localeIdentifier)
    return locale.object(forKey: .languageCode) == nil ? nil : locale as Locale
  }

  private func timezoneInfo(for timeZone: TimeZone, locale: Locale?) -> [String: Any] {
    [
      "identifier": timeZone.identifier,
      "localizedName": locale.flatMap {
        timeZone.localizedName(for: .standard, locale: $0)
      } ?? NSNull(),
      "locale": locale?.identifier ?? NSNull(),
    ]
  }
}
