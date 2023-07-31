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

import UIKit

/// Provides helper functions to get DSP details, generate universal links and invoke DSP apps.
public final class CreditorCommerceLibraryWrapper {
    private static var manifestDSPDetails: [ManifestDSPDetails] = []
    static var dspService = DSPService(dspWebService: DSPWebService(networkManager: NetworkManager()))

    private init() {
        /// Instance for this class should not be created as this class has static APIs.
        /// Hence, making the class initializer as a private.
    }

    /// Provides list of `DspDetails` to merchant or `LibraryError`
    /// - Parameters:
    ///     - dspManifestUrl: File url which contains list of available DSP's.
    ///     - isVerificationRequired: If false, method will skip signing verification while fetching
    ///       DSP details. Default is `true`.
    ///     - completionHandler: Library callback return Success & Failure response to merchant.
    public static func getDspDetails(
        dspManifestUrl: String,
        isVerificationRequired: Bool = true,
        completionHandler: @escaping (Result<[DspDetails], LibraryError>) -> Void
    ) {
        do {
            try dspService.getDSPDetails(
                dspManifestUrl: dspManifestUrl,
                isVerificationRequired: isVerificationRequired
            ) { result in
                switch result {
                case let .success(manifestDetails):
                    self.manifestDSPDetails = manifestDetails
                    completionHandler(
                        .success(DSPService.extractDSPDetails(manifestDSPDetails: manifestDetails))
                    )
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            }
        } catch {
            completionHandler(.failure(error as? LibraryError ?? .technicalError))
        }
    }

    /// Generates parameterised universal link for selected dsp.
    /// - Parameters:
    ///     - dspID: Dsp unique ID of selected DSP for which universal link needs to be generate.
    ///     - lifeCycleID: Lifecycle ID for selected payment.
    ///     - businessType: Business type for selected payment.
    ///     - journeyType: Journey type for selected payment.
    ///     - completionHandler: Library callback return Success & Failure response to merchant.
    public static func generateUniversalLink(
        dspID: String,
        lifeCycleID: String,
        businessType: Int,
        journeyType: JourneyType,
        completionHandler: (Result<String, LibraryError>) -> Void
    ) {
        guard let dspDetail = manifestDSPDetails.first(where: { $0.dspUniqueID == dspID }) else {
            return completionHandler(.failure(.invalidDspID))
        }

        guard let universalURL = URL(string: dspDetail.dspUniversalLink) else {
            return completionHandler(.failure(.invalidManifestFile))
        }

        guard !lifeCycleID.isEmpty else {
            return completionHandler(.failure(.invalidLifecycleID))
        }

        guard businessType > 0 else {
            return completionHandler(.failure(.invalidBusinessType))
        }

        guard journeyType == .requestToLink || journeyType == .requestToPay else {
            return completionHandler(.failure(.invalidJourneyType))
        }

        do {
            let universalLink = try DSPService.universalLink(
                universalURL: universalURL,
                lifeCycleID: lifeCycleID.base64Encoded,
                businessType: "\(businessType)".base64Encoded,
                journeyType: journeyType.rawValue.base64Encoded
            )
            completionHandler(.success(universalLink))
        } catch {
            completionHandler(.failure(error as? LibraryError ?? .technicalError))
        }
    }

    /// Invoke dsp app by generating universal link.
    /// - Parameters:
    ///     - dspID: Dsp unique ID of selected DSP for which universal link needs to be generate.
    ///     - lifeCycleID: Lifecycle ID for selected payment.
    ///     - businessType: Business type for selected payment.
    ///     - journeyType: Journey type for selected payment.
    ///     - completionHandler: Library callback return Success & Failure response to merchant.
    public static func invokeApp(
        dspID: String,
        lifeCycleID: String,
        businessType: Int,
        journeyType: JourneyType,
        completionHandler: @escaping (Result<Bool, LibraryError>) -> Void
    ) {
        dispatchPrecondition(condition: .onQueue(.main))

        generateUniversalLink(
            dspID: dspID,
            lifeCycleID: lifeCycleID,
            businessType: businessType,
            journeyType: journeyType
        ) { result in

            switch result {
            case let .success(universalLink):
                guard let universalLinkURL = URL(string: universalLink) else {
                    completionHandler(.failure(.unableToInvokeDSP))
                    return
                }

                if UIApplication.shared.canOpenURL(universalLinkURL) {
                    UIApplication.shared.open(
                        universalLinkURL,
                        options: [:],
                        completionHandler: nil
                    )
                    completionHandler(.success(true))
                } else {
                    completionHandler(.failure(.unableToInvokeDSP))
                }
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
}
