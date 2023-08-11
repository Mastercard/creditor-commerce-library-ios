//
//  Copyright© 2021 Mastercard
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

extension String {
    /// Assuming the current string is base64 encoded, this property returns a String
    /// initialized by converting the current string into Unicode characters, encoded to
    /// utf8. If the current string is not base64 encoded, nil is returned instead.
    var base64Decoded: String {
        get throws {
            guard let base64 = Data(base64Encoded: self),
                  let decodedString = String(data: base64, encoding: .utf8)
            else {
                throw LibraryError.invalidEncoding
            }
            return decodedString
        }
    }

    /// Returns a base64 representation of the current string, or nil if the
    /// operation fails.
    var base64Encoded: String {
        get throws {
            guard let utf8 = data(using: .utf8) else {
                throw LibraryError.invalidEncoding
            }
            return utf8.base64EncodedString()
        }
    }

    /// Returns json dictionary by decoding json data.
    var decodeToJSON: [String: Any] {
        get throws {
            do {
                let decodedData = try urlSafeBase64Decoded
                guard let json = try JSONSerialization.jsonObject(
                    with: decodedData
                ) as? [String: Any] else {
                    throw LibraryError.invalidEncoding
                }
                return json
            } catch {
                throw LibraryError.invalidEncoding
            }
        }
    }

    var urlSafe: String {
        replacingOccurrences(of: "=", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns url safe base64 decoded `Data`
    var urlSafeBase64Decoded: Data {
        get throws {
            var base64String =
                replacingOccurrences(of: "-", with: "+")
                    .replacingOccurrences(of: "_", with: "/")
            if (count % 4) != 0 {
                let paddedLength = count + (4 - (count % 4))
                base64String = base64String.padding(
                    toLength: paddedLength,
                    withPad: "=",
                    startingAt: 0
                )
            }
            guard let decodedData = Data(base64Encoded: base64String) else {
                throw LibraryError.invalidEncoding
            }
            return decodedData
        }
    }

    /// Returns base64 encoded string
    /// - Parameter data: to be encoded in base64 format
    /// - Returns: url safe base64 encoded string
    static func urlSafeBase64Encoded(data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}
