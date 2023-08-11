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

final class DSPService {
    typealias ManifestDetailsResult = Result<[ManifestDSPDetails], LibraryError>
    typealias DSPDetailsResult = Result<[DspDetails], LibraryError>

    // MARK: - Properties

    private let certificateTrustService = CertificateTrustService()
    private var dspManifestURL: URL?
    private let dspWebService: DSPWebServiceProtocol

    init(dspWebService: DSPWebServiceProtocol) {
        self.dspWebService = dspWebService
    }

    // MARK: - Public Methods

    func getDSPDetails(
        dspManifestUrl: String,
        isVerificationRequired: Bool,
        completion: @escaping (ManifestDetailsResult) -> Void
    ) throws {
        guard let manifestURL = URL(string: dspManifestUrl) else {
            return completion(.failure(.invalidManifestURL))
        }

        guard manifestURL.scheme == Constants.https else {
            return completion(.failure(.invalidURLProtocol))
        }

        dspManifestURL = manifestURL

        try dspWebService.fetchManifestData(manifestURL: manifestURL) { result in
            switch result {
            case let .success(manifestData):
                guard let jwsInput = String(data: manifestData, encoding: .utf8)?.urlSafe else {
                    return completion(.failure(.invalidManifestFile))
                }
                self.processManifestFileContents(
                    jwsString: jwsInput,
                    isVerificationRequired: isVerificationRequired,
                    completion: completion
                )
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    static func extractDSPDetails(manifestDSPDetails: [ManifestDSPDetails]) -> [DspDetails] {
        manifestDSPDetails.map {
            DspDetails(
                dspName: $0.dspName,
                dspUseCaseType: $0.dspUseCaseType,
                dspLogo: $0.dspLogo,
                dspUniqueID: $0.dspUniqueID,
                dspLogoHash: $0.dspLogoHash
            )
        }
    }

    static func universalLink(
        universalURL: URL,
        lifeCycleID: String,
        businessType: String,
        journeyType: String
    ) throws -> String {
        var urlComponents = URLComponents()
        urlComponents.scheme = universalURL.scheme
        urlComponents.host = universalURL.host
        urlComponents.path = universalURL.path
        urlComponents.queryItems = [
            URLQueryItem(name: Constants.keyLifecycleID, value: lifeCycleID),
            URLQueryItem(name: Constants.keyBusinessType, value: businessType),
            URLQueryItem(name: Constants.keyJourneyType, value: journeyType)
        ]
        guard let universalLinkString = urlComponents.url?.absoluteString.removingPercentEncoding else {
            throw LibraryError.technicalError
        }
        return universalLinkString
    }
}

extension DSPService {
    // MARK: - Private Methods

    private func processManifestFileContents(
        jwsString: String,
        isVerificationRequired: Bool,
        completion: @escaping (ManifestDetailsResult) -> Void
    ) {
        let jsonService = JSONWebSignatureService()
        do {
            try jsonService.decodeJWS(jws: jwsString) { [weak self] result in
                guard let self = self else {
                    return completion(.failure(.technicalError))
                }

                switch result {
                case let .success(token):
                    if isVerificationRequired {
                        self.processDecoded(jwsToken: token, completion: completion)
                    } else {
                        self.processPayload(jwsPayload: token.payload, completion: completion)
                    }

                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error as? LibraryError ?? .technicalError))
        }
    }

    private func processDecoded(
        jwsToken: JWSToken,
        completion: @escaping (ManifestDetailsResult) -> Void
    ) {
        guard let manifestURL = dspManifestURL else {
            return completion(.failure(.invalidManifestURL))
        }

        guard let certificate = jwsToken.header[Constants.x5uKey] as? String,
              let certificateChainURL = URL(string: certificate),
              certificateChainURL.host == manifestURL.host
        else {
            return completion(.failure(.invalidSignatureCertificateURL))
        }

        guard let algorithm = jwsToken.header[Constants.algKey] as? String else {
            return completion(.failure(.invalidSignatureAlgorithm))
        }

        getDSPManifestPublicKeyCertificateChain(url: certificateChainURL) { [weak self] result in
            guard let self = self else {
                return completion(.failure(.technicalError))
            }

            switch result {
            case let .success(chainData):
                self.processDecoded(
                    jwsToken: jwsToken,
                    certificateChainData: chainData,
                    algorithm: algorithm,
                    completion: completion
                )

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func getDSPManifestPublicKeyCertificateChain(
        url: URL,
        completion: @escaping (Result<Data, LibraryError>) -> Void
    ) {
        do {
            try dspWebService.downloadCertificate(url: url, completion: completion)
        } catch {
            completion(.failure(error as? LibraryError ?? .technicalError))
        }
    }

    private func processDecoded(
        jwsToken: JWSToken,
        certificateChainData: Data,
        algorithm: String,
        completion: (ManifestDetailsResult) -> Void
    ) {
        // Convert the PEM chain to a DER chain, fetch anchor certificates
        guard let pemEncodedChain = String(data: certificateChainData, encoding: .utf8)
        else {
            return completion(.failure(.emptyCertificateData))
        }

        let derEncodedChain =
            certificateTrustService.derCertificateChainForPEMChain(pemChain: pemEncodedChain)
        let cryptoService = CryptoService(certificateTrustService: certificateTrustService)
        do {
            guard try cryptoService.verify(
                signedData: jwsToken.signedData,
                signature: jwsToken.signature,
                certificateChain: derEncodedChain,
                algorithm: algorithm
            ) else {
                return completion(.failure(.signatureVerificationFailed))
            }
        } catch {
            return completion(.failure(error as? LibraryError ?? .signatureVerificationFailed))
        }

        processPayload(jwsPayload: jwsToken.payload, completion: completion)
    }

    private func processPayload(
        jwsPayload: [String: Any],
        completion: (ManifestDetailsResult) -> Void
    ) {
        guard let apps = jwsPayload[Constants.appsKey] as? [[String: Any]] else {
            return completion(.failure(.emptyDSPListFile))
        }

        var dspDetails = [ManifestDSPDetails]()
        apps.forEach {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: $0)
                let dspDetail = try JSONDecoder().decode(ManifestDSPDetails.self, from: jsonData)
                dspDetails.append(dspDetail)
            } catch {
                completion(.failure(error as? LibraryError ?? .invalidDSPDetail))
            }
        }

        guard !dspDetails.isEmpty else {
            return completion(.failure(.invalidDSPDetail))
        }
        completion(.success(dspDetails))
    }
}
