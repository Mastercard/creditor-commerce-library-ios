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

struct DspManifest: Codable {
    let dspListVersion: Float
    let apps: [ManifestDSPDetails]
}

struct ManifestDSPDetails {
    let dspName: String
    let dspUseCaseType: Int
    let dspLogo: String
    let dspUniversalLink: String
    let dspUniqueID: String
    let dspLogoHash: String

    enum CodingKeys: String, CodingKey {
        case dspName
        case dspUseCaseType
        case dspLogo
        case dspUniversalLink
        case dspUniqueID = "dspUniqueId"
        case dspLogoHash
    }
}

extension ManifestDSPDetails: Codable {
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dspName = try container.decode(String.self, forKey: .dspName)
        if dspName.isEmpty {
            throw LibraryError.emptyDSPName
        }
        dspUseCaseType = try container.decode(Int.self, forKey: .dspUseCaseType)
        if dspUseCaseType == 0 {
            throw LibraryError.emptyDSPAPIVersion
        }
        dspLogo = try container.decode(String.self, forKey: .dspLogo)
        if dspLogo.isEmpty {
            throw LibraryError.emptyDSPLogo
        }
        dspUniversalLink = try container.decode(String.self, forKey: .dspUniversalLink)
        if dspUniversalLink.isEmpty {
            throw LibraryError.emptyDSPUniversalLink
        }
        dspUniqueID = try container.decode(String.self, forKey: .dspUniqueID)
        if dspUniqueID.isEmpty {
            throw LibraryError.emptyDSPID
        }
        dspLogoHash = try container.decode(String.self, forKey: .dspLogoHash)
        if dspLogoHash.isEmpty {
            throw LibraryError.emptyAppIcon
        }
    }
}
