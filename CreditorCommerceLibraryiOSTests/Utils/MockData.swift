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

import XCTest

@testable import CreditorCommerceLibraryiOS

enum MockData {
    static let validURL = "https://zts4.co.uk/zapp-creditor-commerce/cdn-files/dsplist-signed"
    static let invalidURL = "https://zts4.co.uk/zapp-creditor-commerce/cdn-files/dsplist-invalidul"
    static let invalidManifestURL = "https://zts4.co.uk/zapp-creditor-commerce/cdn-files/dsplist-signed2"
    static let invalidCertURL = "https://zts4.co.uk/zapp-creditor-commerce/cdn-files/dsplist-invalidcertificatepath"
    static let invalidDSPNameURL = "https://zts4.co.uk/zapp-creditor-commerce/cdn-files/dsplist-invaliddspname"
    static let insecureURL = "http://zts4.co.uk/zapp-creditor-commerce/cdn-files/dsplist-signed"
    static let validUniversalURL = "https://ahi1.zts2.co.uk/"

    private static let mockURL = URL(string: "https://www.example.com")!
    static func mockHTTPResponse(statusCode: Int) -> HTTPURLResponse? {
        HTTPURLResponse(
            url: mockURL,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
    }

    static func dspDetails(json: Data) -> [DspDetails] {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: json)
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
            return try JSONDecoder().decode([DspDetails].self, from: jsonData)
        } catch {
            XCTFail("dspDetails Error: \(error)")
            return []
        }
    }

    static func universalLink(
        link: String = MockData.validUniversalURL,
        lifecycleID: String,
        businessType: Int,
        journeyType: JourneyType
    ) -> String {
        do {
            return try DSPService.universalLink(
                universalURL: URL(string: link)!,
                lifeCycleID: lifecycleID.base64Encoded,
                businessType: "\(businessType)".base64Encoded,
                journeyType: journeyType.rawValue.base64Encoded
            )
        } catch {
            XCTFail(error.localizedDescription)
            return ""
        }
    }
}
