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

/// This is protocol class for NetworkManagerProtocol
protocol NetworkManagerProtocol {
    typealias DataTaskResult = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

    /// Data task request
    /// - Parameters:
    ///   - urlRequest: urlRequest
    ///   - completion: completion block with response data and error
    func request(urlRequest: URLRequest, completion: @escaping DataTaskResult) throws

    /// Download task request
    /// - Parameters:
    ///   - url: request url from which data will be downloaded
    ///   - completion: completion block with response data and error
    func download(url: URL, completion: @escaping DataTaskResult) throws

    /// Get URLSession
    ///  Return type: URLSession
    func getURLSession() -> URLSession
}

/// This class is to setup and configure data and download task requests.
final class NetworkManager: NSObject {
    // MARK: - Properties

    private var url: URL?
}

// MARK: - NetworkManagerProtocol

extension NetworkManager: NetworkManagerProtocol {

    func getURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.timeoutIntervalForRequest = Constants.requestTimeout
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return urlSession
    }

    func request(urlRequest: URLRequest, completion: @escaping DataTaskResult) throws {
        url = urlRequest.url
        getURLSession().dataTask(with: urlRequest, completionHandler: completion).resume()
    }

    func download(url: URL, completion: @escaping DataTaskResult) throws {
        getURLSession().downloadTask(
            with: URLRequest(url: url),
            completionHandler: { url, response, error in
                guard let certificateURL = url,
                      let certificateData = try? Data(contentsOf: certificateURL)
                else {
                    return completion(nil, response, error)
                }
                completion(certificateData, response, error)
            }
        ).resume()
    }
}

// MARK: - URLSessionDelegate

extension NetworkManager: URLSessionDelegate {
    func urlSession(
        _: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
        else {
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
            return
        }

        guard let url = self.url,
              challenge.protectionSpace.host == url.host,
              let serverTrust = challenge.protectionSpace.serverTrust,
              CertificateTrustService.evaluate(trust: serverTrust)
        else {
            return completionHandler(
                URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge,
                nil
            )
        }
        completionHandler(
            URLSession.AuthChallengeDisposition.useCredential,
            URLCredential(trust: serverTrust)
        )
    }
}
