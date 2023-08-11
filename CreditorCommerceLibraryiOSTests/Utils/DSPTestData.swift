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

class DSPTestData: NSObject {
    private class TestClass {}

    static let testBundle = Bundle(for: DSPTestData.self)

    static var testDataDictionary: [String: String] {
        guard let bundlePath = testBundle.path(forResource: "TestJWSStrings", ofType: "strings"),
              let dictionary = NSDictionary(contentsOfFile: bundlePath) as? [String: String]
        else {
            return [:]
        }
        return dictionary
    }

    static var validJWSContent: String {
        testDataDictionary["valid-jws-content"] ?? ""
    }

    static var invalidJWSContent: String {
        testDataDictionary["invalid-jws-content"] ?? ""
    }

    static var invalidManifestURLContent: String {
        testDataDictionary["invalid-manifest-url-content"] ?? ""
    }

    static var invalidDSPNameJWSContent: String {
        testDataDictionary["invalid-dsp-name"] ?? ""
    }

    static var invalidCertificatePathJWSContent: String {
        testDataDictionary["invalid-certificate-path-content"] ?? ""
    }

    static var invalidHostJWSContent: String {
        testDataDictionary["invalid-host"] ?? ""
    }

    static var invalidHeaderJWSContent: String {
        testDataDictionary["invalid-jws-content-header"] ?? ""
    }

    static var invalidPayloadJWSContent: String {
        testDataDictionary["invalid-jws-content-payload"] ?? ""
    }

    static var invalidSignatureJWSContent: String {
        testDataDictionary["invalid-jws-content-signature"] ?? ""
    }

    static var validJWSHeader: [String: Any] {
        guard let jwsHeader = testDataDictionary["invalid-jws-content-signature"],
              let headerData = jwsHeader.data(using: .utf8),
              let header = try? JSONSerialization.jsonObject(with: headerData) as? [String: Any]
        else {
            return [:]
        }
        return header
    }

    static var validCerificateData: Data {
        let bundlePath = testBundle.path(
            forResource: "tes-jws-verification-certificate",
            ofType: "cer"
        )
        return NSData(contentsOfFile: bundlePath ?? "") as? Data ?? Data()
    }

    static var validDSPDetailsJsonData: Data {
        jsonData(from: "ValidDSPDetails")
    }

    static var invalidDSPDetailsJsonData: Data {
        jsonData(from: "InvalidDSPDetails")
    }

    static var invalidDSPNameJsonData: Data {
        jsonData(from: "InvalidDSPName")
    }
}

extension DSPTestData {
    private static func jsonData(from file: String) -> Data {
        guard let bundlePath = testBundle.path(forResource: file, ofType: "json"),
              let jsonData = NSData(contentsOfFile: bundlePath) as? Data
        else { return Data() }
        return jsonData
    }
}
