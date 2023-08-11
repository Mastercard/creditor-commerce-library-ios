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
import Security

final class CertificateTrustService {
    // MARK: - Constants
    private let pemPrefix = "-----BEGIN CERTIFICATE-----"
    private let pemSuffix = "-----END CERTIFICATE-----"

    // MARK: - Public methods

    func derCertificateChainForPEMChain(pemChain: String) -> [Data] {
        var chain = pemChain
        var certificates = [Data]()
        if let range = pemChain.range(of: pemSuffix) {
            var chainRange = NSRange(range, in: pemChain)
            while chain.count > 0 {
                var certificate = (chain as NSString).substring(to: chainRange.location + chainRange.length)
                certificate = certificate.trimmingCharacters(in: .whitespacesAndNewlines)
                if let certificateData = derCertificateForPEMCertificate(pemCertificate: certificate) {
                    certificates.append(certificateData)
                }
                chain = (chain as NSString).substring(from: chainRange.location + chainRange.length + 1)
                if chain.count > 0, let range = chain.range(of: pemSuffix) {
                    chainRange = NSRange(range, in: chain)
                }
            }
        }
        return certificates
    }

    func getPublicKeyAfterEvaluatingTrust(certificateChain: [Data]) -> SecKey? {
        // 1. Fetch list of SecCertificate
        let certificates = fetchSecurityCertificates(for: certificateChain)
        guard !certificates.isEmpty else {
            return nil
        }

        // 3. Check certificate chain trust
        var publicKey: SecKey?
        var secTrust: SecTrust?
        let policy = SecPolicyCreateBasicX509()

        if SecTrustCreateWithCertificates(certificates as CFArray, policy, &secTrust) == 0,
           let trust = secTrust {
            // Set trusted anchor certificate and evaluate the chain trust
            SecTrustSetAnchorCertificatesOnly(trust, true)
            if setTrust(anchorCertificates: certificates, trust: trust),
               CertificateTrustService.evaluate(trust: trust) {
                if #available(iOS 14.0, *) {
                    publicKey = SecTrustCopyKey(trust)
                } else {
                    publicKey = SecTrustCopyPublicKey(trust)
                }
            }
        }
        return publicKey
    }

    static func evaluate(trust: SecTrust) -> Bool {
        var trusted = true
        var error: CFError?
        trusted = SecTrustEvaluateWithError(trust, &error)
        return trusted
    }

    // MARK: - Private methods

    private func derCertificateForPEMCertificate(pemCertificate: String) -> Data? {
        var certificate = pemCertificate
        if certificate.hasPrefix(pemPrefix), certificate.hasSuffix(pemSuffix) {
            certificate = certificate.replacingOccurrences(of: pemPrefix, with: "")
            certificate = certificate.replacingOccurrences(of: pemSuffix, with: "")
        }
        return NSData(base64Encoded: certificate, options: .ignoreUnknownCharacters) as? Data
    }

    private func fetchSecurityCertificates(for certificatesData: [Data]) -> [SecCertificate] {
        var certificates = [SecCertificate]()
        certificatesData.forEach {
            if let secCertificate = SecCertificateCreateWithData(nil, $0 as CFData) {
                certificates.append(secCertificate)
            }
        }
        return certificates
    }

    private func setTrust(anchorCertificates: [SecCertificate], trust: SecTrust) -> Bool {
        if anchorCertificates.isEmpty {
            return false
        }
        return SecTrustSetAnchorCertificates(trust, anchorCertificates as CFArray) == errSecSuccess
    }
}
