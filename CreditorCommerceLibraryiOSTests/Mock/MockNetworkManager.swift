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

import XCTest

@testable import CreditorCommerceLibraryiOS

typealias MockDataResult = Result<Data, LibraryError>

final class MockNetworkManager: NetworkManagerProtocol {

    func getURLSession() -> URLSession {
        return URLSession(configuration: .default)
    }

    private let mockDataResult: MockDataResult
    private let mockDownloadResult: MockDataResult?

    init(dataResult: MockDataResult, downloadResult: MockDataResult?) {
        mockDataResult = dataResult
        mockDownloadResult = downloadResult
    }

    func request(urlRequest: URLRequest, completion: @escaping DataTaskResult) throws {
        switch self.mockDataResult {
        case let .success(manifestData):
            completion(manifestData, HTTPURLResponse(), nil)
        case .failure:
            completion(nil, nil, NSError(domain: "NSURLErrorUnsupportedURL", code: NSURLErrorUnsupportedURL))
        }
    }

    func download(url: URL, completion: @escaping DataTaskResult) throws {
        switch self.mockDownloadResult! {
        case let .success(certData):
            completion(certData, HTTPURLResponse(), nil)
        case let .failure(error):
            completion(nil, nil, error)
        }
    }
}
