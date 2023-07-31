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

/// DSP details required to generate universal link for payments.
public struct DspDetails: Equatable {
    /// :nodoc:
    public let dspName: String

    /// :nodoc:
    public let dspUseCaseType: Int

    /// :nodoc:
    public let dspLogo: String

    /// :nodoc:
    public let dspUniqueID: String

    /// :nodoc:
    public let dspLogoHash: String
}

extension DspDetails {
    enum CodingKeys: String, CodingKey {
        case dspName
        case dspUseCaseType
        case dspLogo
        case dspUniqueID = "dspUniqueId"
        case dspLogoHash
    }
}

extension DspDetails: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dspName = try container.decode(String.self, forKey: .dspName)
        dspUseCaseType = try container.decode(Int.self, forKey: .dspUseCaseType)
        dspLogo = try container.decode(String.self, forKey: .dspLogo)
        dspUniqueID = try container.decode(String.self, forKey: .dspUniqueID)
        dspLogoHash = try container.decode(String.self, forKey: .dspLogoHash)
    }
}
