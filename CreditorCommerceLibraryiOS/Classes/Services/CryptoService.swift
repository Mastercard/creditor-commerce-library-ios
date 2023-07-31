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

import CommonCrypto
import Foundation

/// Verifies and validates the signed data (header and payload) against signature.
final class CryptoService {
    // MARK: - Properties

    private var certificateTrustService: CertificateTrustService

    // MARK: - Intializers

    init(certificateTrustService: CertificateTrustService) {
        self.certificateTrustService = certificateTrustService
    }

    // MARK: - Public Methods

    func verify(
        signedData: Data,
        signature: Data,
        certificateChain: [Data],
        algorithm: String
    ) throws -> Bool {
        guard let publicKey = certificateTrustService.getPublicKeyAfterEvaluatingTrust(
            certificateChain: certificateChain
        ) else {
            throw LibraryError.invalidPublicKey
        }

        guard let secAlgorithm = SecurityAlgorithm(rawValue: algorithm)?.secKeyAlgorithm,
              SecKeyIsAlgorithmSupported(publicKey, .verify, secAlgorithm)
        else {
            throw LibraryError.invalidSignatureAlgorithm
        }

        var verificationError: Unmanaged<CFError>?
        return SecKeyVerifySignature(
            publicKey,
            secAlgorithm,
            signedData as CFData,
            signature as CFData,
            &verificationError
        )
    }
}
