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

final class URLRequestBuilder {

    static func buildURLRequest(endpoint: Endpoint) throws -> URLRequest {

        var requestURL = endpoint.baseURL
        if let path = endpoint.path {
            requestURL = requestURL.appendingPathComponent(path)
        }

        var request = URLRequest(url: requestURL)

        // Method
        request.httpMethod = endpoint.httpMethod.rawValue

        // Headers
        if let headers = endpoint.headers {
            request.allHTTPHeaderFields = headers
        }

        // JSON
        if let json = endpoint.jsonParameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: json)
            if request.value(forHTTPHeaderField: Constants.kContentType) == nil {
                request.setValue(Constants.contentJSON, forHTTPHeaderField: Constants.kContentType)
            }
        }

        // URL encoded params
        if let urlParameters = endpoint.urlParameters {
            if var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false) {
                urlParameters.forEach { key, value in
                    urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
                }
                request.url = urlComponents.url
            }
            if request.value(forHTTPHeaderField: Constants.kContentType) == nil {
                request.setValue(
                    Constants.contentURLEncoded,
                    forHTTPHeaderField: Constants.kContentType
                )
            }
        }
        return request
    }
}
