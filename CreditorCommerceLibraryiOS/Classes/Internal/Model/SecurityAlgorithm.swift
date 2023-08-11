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

// https://datatracker.ietf.org/doc/html/rfc7518#section-3.1
enum SecurityAlgorithm: String {
    /// HMAC using SHA-256
    case HS256

    /// HMAC using SHA-384
    case HS384

    /// HMAC using SHA-512
    case HS512

    /// RSASSA-PKCS1-v1_5 using SHA-256
    case RS256

    /// RSASSA-PKCS1-v1_5 using SHA-384
    case RS384

    /// RSASSA-PKCS1-v1_5 using SHA-256
    case RS512

    /// RSASSA-PSS using SHA-256 and MGF1 with SHA-256
    case PS256

    /// RSASSA-PSS using SHA-384 and MGF1 with SHA-384
    case PS384

    /// RSASSA-PSS using SHA-512 and MGF1 with SHA-512
    case PS512

    /// ECDSA P-256 using SHA-256
    case ES256

    /// ECDSA P-384 using SHA-384
    case ES384

    /// ECDSA P-521 using SHA-512
    case ES512

    var secKeyAlgorithm: SecKeyAlgorithm? {
        switch self {
        case .RS256:
            return .rsaSignatureMessagePKCS1v15SHA256
        case .RS384:
            return .rsaSignatureMessagePKCS1v15SHA384
        case .RS512:
            return .rsaSignatureMessagePKCS1v15SHA512
        case .PS256:
            return .rsaSignatureMessagePSSSHA256
        case .PS384:
            return .rsaSignatureMessagePSSSHA384
        case .PS512:
            return .rsaSignatureMessagePSSSHA512
        default:
            return nil
        }
    }
}
