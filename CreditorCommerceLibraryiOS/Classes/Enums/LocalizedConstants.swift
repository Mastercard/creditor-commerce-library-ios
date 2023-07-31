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

/// Define localized string constants here
enum ConstantStrings {
    static let kErrorInvalidDSPID = "error_invalid_dsp_id".localized
    static let kErrorInvalidLifecycleID = "error_invalid_lifecycle_id".localized
    static let kErrorInvalidBusinessType = "error_invalid_business_type".localized
    static let kErrorInvalidJourneyType = "error_invalid_journey_type".localized
    static let kErrorInvalidManifestURL = "error_invalid_manifest_url".localized
    static let kErrorInvalidProtocol = "error_invalid_protocol".localized
    static let kErrorInvalidManifestFile = "error_invalid_manifest_file".localized
    static let kErrorInInvokeDSP = "error_invoke".localized
    static let kErrorTimeout = "error_timeout".localized
    static let kErrorInternetConnection = "error_no_internet".localized
    static let kErrorTechnical = "error_technical".localized
}

// MARK: - String Extenstion

extension String {
    var localized: String {
        let bundle = Bundle(
            url: Bundle.main.bundleURL
                .appendingPathComponent(Constants.frameworksPath)
                .appendingPathComponent(Constants.frameworkName)
        ) ?? Bundle.main
        return NSLocalizedString(
            self,
            tableName: nil,
            bundle: bundle,
            value: "",
            comment: ""
        )
    }
}
