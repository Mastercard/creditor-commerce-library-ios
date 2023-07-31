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

/// Errors thrown by `CreditorCommerceLibraryWrapper` functions.
///
/// - SeeAlso: `CreditorCommerceLibraryWrapper` protocol.
public enum LibraryError: Int, Error {
    /// If DSP ID is empty OR Universal Link is empty or nil.
    case invalidDspID = 1001

    /// If Lifecycle ID is nil or undefined.
    case invalidLifecycleID = 1002

    /// If Business Type is 0
    case invalidBusinessType = 1003

    /// If Journey type Value is Invalid
    case invalidJourneyType = 1004

    /// When passed manifest file url is empty or unreachable.
    case invalidManifestURL = 1005

    ///  When manifest CDN URL is not having secure protocol such as HTTPS.
    case invalidURLProtocol = 1006

    /// When manifest file has invalid content.
    case invalidManifestFile = 1007

    /// When generated universal link can not open via sdk.
    case unableToInvokeDSP = 1101

    /// When unbale to get response form manifest CDN location in given time.
    case timeoutError = 1102

    /// When no internet connection available in to make API call in library.
    case networkError = 1103

    /// An error occured within the SDK code itself.
    ///
    /// Please raise a bug if you encounter this error.
    case technicalError = 1105

    /// Error Description
    public var description: String {
        switch self {
        case .invalidDspID:
            return ConstantStrings.kErrorInvalidDSPID
        case .invalidLifecycleID:
            return ConstantStrings.kErrorInvalidLifecycleID
        case .invalidBusinessType:
            return ConstantStrings.kErrorInvalidBusinessType
        case .invalidJourneyType:
            return ConstantStrings.kErrorInvalidJourneyType
        case .invalidManifestURL:
            return ConstantStrings.kErrorInvalidManifestURL
        case .invalidURLProtocol:
            return ConstantStrings.kErrorInvalidProtocol
        case .invalidManifestFile:
            return ConstantStrings.kErrorInvalidManifestFile
        case .unableToInvokeDSP:
            return ConstantStrings.kErrorInInvokeDSP
        case .timeoutError:
            return ConstantStrings.kErrorTimeout
        case .networkError:
            return ConstantStrings.kErrorInternetConnection
        case .technicalError:
            return ConstantStrings.kErrorTechnical
        }
    }

    public var info: (code: Int, description: String) {
        (code: rawValue, description: description)
    }

    /// Below errors are for internal purpose only to differentiate the signing verification errors.
    static let emptyDSPListFile = LibraryError.invalidManifestFile
    static let emptyDSPID = LibraryError.invalidManifestFile
    static let emptyDSPName = LibraryError.invalidManifestFile
    static let emptyDSPAPIVersion = LibraryError.invalidManifestFile
    static let emptyDSPLogo = LibraryError.invalidManifestFile
    static let emptyDSPUniversalLink = LibraryError.invalidManifestFile
    static let emptyAppIcon = LibraryError.invalidManifestFile
    static let invalidEncoding = LibraryError.invalidManifestFile
    static let invalidDSPDetail = LibraryError.invalidManifestFile

    /// Signed manifest & signature validation
    static let invalidManifestData = LibraryError.invalidManifestFile
    static let emptyPayload = LibraryError.invalidManifestFile
    static let invalidSignatureCertificateURL = LibraryError.invalidManifestFile
    static let invalidSignedCertificate = LibraryError.invalidManifestFile
    static let signatureVerificationFailed = LibraryError.invalidManifestFile
    static let invalidPublicKey = LibraryError.invalidManifestFile
    static let emptyHeader = LibraryError.invalidManifestFile
    static let emptySignature = LibraryError.invalidManifestFile
    static let emptySignedData = LibraryError.invalidManifestFile
    static let invalidSignatureAlgorithm = LibraryError.invalidManifestFile
    static let emptyCertificateData = LibraryError.invalidManifestFile
}
