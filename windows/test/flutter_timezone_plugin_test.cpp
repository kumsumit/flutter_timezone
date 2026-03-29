#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <memory>
#include <string>
#include <variant>

#include "flutter_timezone_plugin.h"

namespace flutter_timezone {
    namespace test {

        namespace {
            using flutter::EncodableValue;
            using flutter::EncodableMap;
            using flutter::MethodCall;
            using flutter::MethodResultFunctions;

        }  // namespace

        static bool isTimezoneInfoMap(const EncodableValue& value) {
            if (std::holds_alternative<EncodableMap>(value)) {
                const auto& map = std::get<EncodableMap>(value);
                const auto identifier = map.find(EncodableValue("identifier"));
                if (identifier == map.end()) {
                    return false;
                }

                if (!std::holds_alternative<std::string>(identifier->second)) {
                    return false;
                }

                return !std::get<std::string>(identifier->second).empty();
            }
            return false;
        }

        TEST(FlutterTimezonePlugin, GetAvailableTimezones) {
            FlutterTimezonePlugin plugin;
            // Save the reply value from the success callback.
            std::vector<EncodableValue> resultVector;

            // Call the method and store the result in the result_vector.
            plugin.HandleMethodCall(
                MethodCall(kGetAvailableTimezones, std::make_unique<EncodableValue >()),
                std::make_unique<MethodResultFunctions<>>(
                    [&resultVector](const EncodableValue* result) {
                        resultVector = std::get<std::vector<EncodableValue>>(*result);
                    },
                    nullptr, nullptr)
            );

            // Since the exact count and values vary by host, just ensure that it's a list of non-empty strings
            EXPECT_GE(resultVector.size(), 1);
            for (const auto& value : resultVector) {
                EXPECT_TRUE(isTimezoneInfoMap(value));
            }
        }

        TEST(FlutterTimezonePlugin, GetLocalTimezone) {
            FlutterTimezonePlugin plugin;
            // Save the reply value from the success callback.
            EncodableValue resultValue;

            // Call the method and store the result in the resultString.
            plugin.HandleMethodCall(
                MethodCall(kGetLocalTimezone, std::make_unique<EncodableValue>()),
                std::make_unique<MethodResultFunctions<>>(
                    [&resultValue](const EncodableValue* result) {
                        resultValue = *result;
                    },
                    nullptr, nullptr));

            EXPECT_TRUE(isTimezoneInfoMap(resultValue));
        }
    }  // namespace test
}  // namespace flutter_timezone
