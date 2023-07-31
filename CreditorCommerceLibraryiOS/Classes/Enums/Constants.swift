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

enum Constants {
    // Lifecycle ID key is used in univarsal link generation to append
    // lifecycle id for transaction.
    static let keyLifecycleID = "lc"

    // Business type key is used in univarsal link generation to append
    // business type for transaction.
    static let keyBusinessType = "tb"

    // Journey type key is used in univarsal link generation to append
    // journey type for transaction.
    static let keyJourneyType = "uc"

    static let x5uKey = "x5u"
    static let algKey = "alg"
    static let appsKey = "apps"
    static let https = "https"

    static let requestTimeout = TimeInterval(10)
    static let kContentType = "Content-Type"
    static let contentJSON = "application/json"
    static let contentURLEncoded = "application/x-www-form-urlencoded; charset=utf-8"

    static let frameworksPath = "Frameworks"
    static let frameworkName = "CreditorCommerceLibraryiOS.framework"
    static let jwsSegmentCount = 3
    static let jwsSegmentSeperator = "."
}
