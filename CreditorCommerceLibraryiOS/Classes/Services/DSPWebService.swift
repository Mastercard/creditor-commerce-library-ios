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

protocol DSPWebServiceProtocol {
    typealias ManifestDataResult = Result<Data, LibraryError>

    func fetchManifestData(manifestURL: URL,
                           completion: @escaping (ManifestDataResult) -> Void) throws

    func downloadCertificate(url: URL, completion: @escaping (ManifestDataResult) -> Void) throws
}

final class DSPWebService: DSPWebServiceProtocol {

    private let statusOK = 200
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    /// Fetches manifest data from the provided manifest URL.
    /// - Parameters:
    ///   - manifestURL: url from which manifest data to be fetched.
    ///   - completion: completion handler with success and failure
    func fetchManifestData(
        manifestURL: URL,
        completion: @escaping (ManifestDataResult) -> Void
    ) throws {
        let endpoint = Endpoint(baseURL: manifestURL, httpMethod: .get)
        let urlRequest = try URLRequestBuilder.buildURLRequest(endpoint: endpoint)
        try networkManager.request(urlRequest: urlRequest, completion: { data, response, error in
            if let err = error as? NSError {
                switch err.code {
                case NSURLErrorTimedOut:
                    completion(.failure(.timeoutError))
                case NSURLErrorUnsupportedURL:
                    completion(.failure(.invalidManifestURL))
                case NSURLErrorNotConnectedToInternet,
                     NSURLErrorNetworkConnectionLost,
                     NSURLErrorDataNotAllowed,
                     NSURLErrorDNSLookupFailed,
                     NSURLErrorDataLengthExceedsMaximum:
                    completion(.failure(.networkError))
                default:
                    completion(.failure(.technicalError))
                }
            } else if let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode != self.statusOK {
                completion(.failure(.invalidManifestURL))
            } else if let manifestData = data {
                completion(.success(manifestData))
            }
        })
    }

    /// Downloads the certificate from the provide certificate path url.
    /// - Parameters:
    ///   - url: url from which certificate data to be downloaded.
    ///   - completion: completion handler with success and failure
    func downloadCertificate(url: URL, completion: @escaping (ManifestDataResult) -> Void) throws {
        try networkManager.download(url: url, completion: { data, response, error in
            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == self.statusOK
            else {
                return completion(.failure(.invalidSignatureCertificateURL))
            }

            guard let certificateData = data else {
                return completion(.failure(.emptyCertificateData))
            }

            completion(.success(certificateData))
        })
    }
}
