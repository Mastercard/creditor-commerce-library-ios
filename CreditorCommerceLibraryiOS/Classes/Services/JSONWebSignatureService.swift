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

/// To store decoded JWS Token (jwsHeader, jwsPayload, jwsSignature, signedData)
struct JWSToken {
    var header: [String: Any]
    var payload: [String: Any]
    var signature: Data
    var signedData: Data
}

// Parse the JWS token to extract jwsHeader, jwsPayload and jwsSignature values
final class JSONWebSignatureService {

    /// Decodes JWS token and extracts the header, payload and signature data from it.
    /// - Parameters:
    ///   - jws: manifest file contents (jws token in encoded form)
    ///   - completion: returns parsed data of header, payload, signature and signed data
    func decodeJWS(
        jws: String,
        completion: @escaping (Result<JWSToken, LibraryError>) -> Void
    ) throws {
        let segments = jws.components(separatedBy: Constants.jwsSegmentSeperator)
        guard segments.count == Constants.jwsSegmentCount else {
            return completion(.failure(.invalidManifestData))
        }

        // JWS Input: "<header>.<payload>.<signature>"
        // segments[0] = header, segments[1] = payload, segments[2] = signature
        guard !segments[0].isEmpty else {
            return completion(.failure(.emptyHeader))
        }
        guard !segments[1].isEmpty else {
            return completion(.failure(.emptyPayload))
        }
        guard !segments[2].isEmpty else {
            return completion(.failure(.emptySignature))
        }

        let header: [String: Any] = try segments[0].decodeToJSON
        let payload: [String: Any] = try segments[1].decodeToJSON
        let signature = try segments[2].urlSafeBase64Decoded

        // Signed Data: utf8_encoding_data("<header>.<payload>")
        guard let singedData = "\(segments[0]).\(segments[1])".data(using: .utf8) else {
            return completion(.failure(.emptySignedData))
        }

        completion(.success(
            JWSToken(header: header, payload: payload, signature: signature, signedData: singedData)
        ))
    }
}
