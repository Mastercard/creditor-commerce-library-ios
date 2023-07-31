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

final class CreditorCommerceLibraryiOSTests: XCTestCase {
    private let httpResponseErrorDomain = "HttpResponseErrorDomain"

    func testValidManifestData() {
        let dataResult = MockDataResult.success(DSPTestData.validJWSContent.data(using: .utf8)!)
        let downloadDataResult: MockDataResult = MockDataResult.success(DSPTestData.validCerificateData)
        configureMockNetwork(dataResult: dataResult, downloadDataResult: downloadDataResult)

        let getDSPDetailsExpectation = XCTestExpectation(description: "GetDSPDetailsExpectation")
        CreditorCommerceLibraryWrapper.getDspDetails(
            dspManifestUrl: MockData.validURL
        ) { (result: Result<[DspDetails], LibraryError>) in
            switch result {
            case let .success(dspDetails):
                let testDSPDetails = MockData.dspDetails(json: DSPTestData.validDSPDetailsJsonData)
                XCTAssert(dspDetails == testDSPDetails)
            case let .failure(error):
                XCTFail(error.info.description)
            }
            getDSPDetailsExpectation.fulfill()
        }
        wait(for: [getDSPDetailsExpectation], timeout: Constants.requestTimeout)
    }

    func testInvalidManifestData() {
        let dataResult = MockDataResult.success(DSPTestData.invalidJWSContent.data(using: .utf8)!)
        let downloadDataResult: MockDataResult = MockDataResult.success(DSPTestData.validCerificateData)
        configureMockNetwork(dataResult: dataResult, downloadDataResult: downloadDataResult)

        let getDSPDetailsExpectation = XCTestExpectation(description: "GetDSPDetailsExpectation")
        CreditorCommerceLibraryWrapper.getDspDetails(
            dspManifestUrl: MockData.validURL
        ) { (result: Result<[DspDetails], LibraryError>) in
            if case let .failure(error) = result {
                XCTAssert(error == .invalidManifestFile) // invalidManifestData
            } else {
                XCTFail("`getDSPDetails` should throw an error as `invalidManifestFile`.")
            }
            getDSPDetailsExpectation.fulfill()
        }
        wait(for: [getDSPDetailsExpectation], timeout: Constants.requestTimeout)
    }

    func testInvalidManifestURL() {
        let dataResult = MockDataResult.failure(LibraryError.invalidManifestURL)
        configureMockNetwork(dataResult: dataResult)

        let getDSPDetailsExpectation = XCTestExpectation(description: "GetDSPDetailsExpectation")

        CreditorCommerceLibraryWrapper.getDspDetails(
            dspManifestUrl: MockData.invalidManifestURL
        ) { (result: Result<[DspDetails], LibraryError>) in
            if case let .failure(error) = result {
                XCTAssert(error == .invalidManifestURL)
            } else {
                XCTFail("`getDSPDetails` should throw an error as `invalidManifestURL`.")
            }
            getDSPDetailsExpectation.fulfill()
        }

        wait(for: [getDSPDetailsExpectation], timeout: Constants.requestTimeout)
    }

    func testInvalidCertificatePath() {
        let dataResult = MockDataResult.success(DSPTestData.invalidCertificatePathJWSContent.data(using: .utf8)!)
        configureMockNetwork(dataResult: dataResult)

        let getDSPDetailsExpectation = XCTestExpectation(description: "GetDSPDetailsExpectation")

        CreditorCommerceLibraryWrapper.getDspDetails(
            dspManifestUrl: MockData.invalidCertURL
        ) { (result: Result<[DspDetails], LibraryError>) in
            if case let .failure(error) = result {
                XCTAssert(error == .invalidManifestFile) // invalidSignatureCertificateURL
            } else {
                XCTFail("`getDSPDetails` should throw an error as `invalidManifestFile`.")
            }
            getDSPDetailsExpectation.fulfill()
        }

        wait(for: [getDSPDetailsExpectation], timeout: Constants.requestTimeout)
    }

    func testInvalidDSPName() {
        let dataResult = MockDataResult.success(DSPTestData.invalidDSPNameJWSContent.data(using: .utf8)!)
        let downloadDataResult: MockDataResult = MockDataResult.success(DSPTestData.validCerificateData)
        configureMockNetwork(dataResult: dataResult, downloadDataResult: downloadDataResult)

        let getDSPDetailsExpectation = XCTestExpectation(description: "GetDSPDetailsExpectation")

        CreditorCommerceLibraryWrapper.getDspDetails(
            dspManifestUrl: MockData.invalidDSPNameURL
        ) { (result: Result<[DspDetails], LibraryError>) in
            if case let .failure(error) = result {
                XCTAssert(error == .invalidManifestFile) // emptyDSPName
            } else {
                XCTFail("`getDSPDetails` should throw an error as `invalidManifestFile`.")
            }
            getDSPDetailsExpectation.fulfill()
        }

        wait(for: [getDSPDetailsExpectation], timeout: Constants.requestTimeout)
    }

    func testInvalidHost() {
        let dataResult = MockDataResult.success(DSPTestData.invalidHostJWSContent.data(using: .utf8)!)
        configureMockNetwork(dataResult: dataResult)

        let getDSPDetailsExpectation = XCTestExpectation(description: "GetDSPDetailsExpectation")

        CreditorCommerceLibraryWrapper.getDspDetails(
            dspManifestUrl: MockData.invalidURL
        ) { (result: Result<[DspDetails], LibraryError>) in
            if case let .failure(error) = result {
                XCTAssert(error == .invalidManifestFile) // invalidSignatureCertificateURL
            } else {
                XCTFail("`getDSPDetails` should throw an error as `invalidManifestFile`.")
            }
            getDSPDetailsExpectation.fulfill()
        }

        wait(for: [getDSPDetailsExpectation], timeout: Constants.requestTimeout)
    }

    func testInvalidURLProtocol() {
        let getDSPDetailsExpectation = XCTestExpectation(description: "GetDSPDetailsExpectation")

        CreditorCommerceLibraryWrapper.getDspDetails(
            dspManifestUrl: MockData.insecureURL
        ) { (result: Result<[DspDetails], LibraryError>) in
            if case let .failure(error) = result {
                XCTAssert(error == .invalidURLProtocol)
            } else {
                XCTFail("`getDSPDetails` should throw an error as `invalidManifestFile`.")
            }
            getDSPDetailsExpectation.fulfill()
        }

        wait(for: [getDSPDetailsExpectation], timeout: Constants.requestTimeout)
    }

    func testInvalidHeaderData() {
        let dataResult = MockDataResult.success(DSPTestData.invalidHeaderJWSContent.data(using: .utf8)!)
        configureMockNetwork(dataResult: dataResult)

        let invalidManifestDataExpectation =
            XCTestExpectation(description: "InvalidManifestDataExpectation")
        CreditorCommerceLibraryWrapper.getDspDetails(
            dspManifestUrl: MockData.validURL
        ) { (result: Result<[DspDetails], LibraryError>) in
            if case let .failure(error) = result {
                XCTAssert(error == .invalidManifestFile)
            } else {
                XCTFail("`getDSPDetails` should throw an error as `invalidManifestFile`.")
            }
            invalidManifestDataExpectation.fulfill()
        }
        wait(for: [invalidManifestDataExpectation], timeout: Constants.requestTimeout)
    }

    func testInvalidPayloadData() {
        let dataResult = MockDataResult.success(DSPTestData.invalidPayloadJWSContent.data(using: .utf8)!)
        configureMockNetwork(dataResult: dataResult)

        let invalidManifestDataExpectation =
            XCTestExpectation(description: "InvalidManifestDataExpectation")
        CreditorCommerceLibraryWrapper.getDspDetails(
            dspManifestUrl: MockData.validURL
        ) { (result: Result<[DspDetails], LibraryError>) in
            if case let .failure(error) = result {
                XCTAssert(error == .invalidManifestFile)
            } else {
                XCTFail("`getDSPDetails` should throw an error as `invalidManifestFile`.")
            }
            invalidManifestDataExpectation.fulfill()
        }
        wait(for: [invalidManifestDataExpectation], timeout: Constants.requestTimeout)
    }

    func testInvalidSignatureData() {
        let dataResult = MockDataResult.success(DSPTestData.invalidSignatureJWSContent.data(using: .utf8)!)
        configureMockNetwork(dataResult: dataResult)

        let invalidManifestDataExpectation =
            XCTestExpectation(description: "InvalidManifestDataExpectation")
        CreditorCommerceLibraryWrapper.getDspDetails(
            dspManifestUrl: MockData.validURL
        ) { (result: Result<[DspDetails], LibraryError>) in
            if case let .failure(error) = result {
                XCTAssert(error == .invalidManifestFile)
            } else {
                XCTFail("`getDSPDetails` should throw an error as `invalidManifestFile`.")
            }
            invalidManifestDataExpectation.fulfill()
        }
        wait(for: [invalidManifestDataExpectation], timeout: Constants.requestTimeout)
    }

    func testGenerateUniversalLinkAPI() {
        let generateUniversalLinkExpectation = XCTestExpectation(
            description: "GenerateUniversalLinkExpectation"
        )
        assertGenerateUniversalLink(
            lifecycleID: "75246384027649",
            businessType: 2,
            journeyType: .requestToLink
        ) { result in
            switch result {
            case let .success(link):
                let expectedLink = MockData.universalLink(
                    lifecycleID: "75246384027649",
                    businessType: 2,
                    journeyType: .requestToLink
                )
                XCTAssertEqual(link, expectedLink)
            case let .failure(error):
                XCTFail(error.info.description)
            }
            generateUniversalLinkExpectation.fulfill()
        }
        wait(for: [generateUniversalLinkExpectation], timeout: Constants.requestTimeout)
    }

    func testInvalidLifecycleID() {
        let invalidLifecycleIDExpectation = XCTestExpectation(
            description: "InvalidLifecycleIDExpectation"
        )
        assertGenerateUniversalLink(
            lifecycleID: "",
            businessType: 2,
            journeyType: .requestToLink
        ) { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, .invalidLifecycleID)
            } else {
                XCTFail("`generateUniversalLink` API should be failed.")
            }
            invalidLifecycleIDExpectation.fulfill()
        }
        wait(for: [invalidLifecycleIDExpectation], timeout: Constants.requestTimeout)
    }

    func testInvalidBusinessType() {
        let invalidBusinessTypeExpectation = XCTestExpectation(
            description: "InvalidBusinessTypeExpectation"
        )
        assertGenerateUniversalLink(
            lifecycleID: "75246384027649",
            businessType: 0,
            journeyType: .requestToLink
        ) { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, .invalidBusinessType)
            } else {
                XCTFail("`generateUniversalLink` API should be failed.")
            }
            invalidBusinessTypeExpectation.fulfill()
        }
        wait(for: [invalidBusinessTypeExpectation], timeout: Constants.requestTimeout)
    }

    func testInvokeAppAPI() {
        assertInvokeApp(
            lifecycleID: "745363486257238",
            businessType: 2,
            journeyType: .requestToPay
        )
    }

    func testGetDSPDetails() {
        assertGetDSPDetails(timeout: Constants.requestTimeout * 10)
    }

    func testGetDSPDetailsAPIWithoutVerification() {
        assertGetDSPDetails(isVerificationRequired: false, timeout: Constants.requestTimeout * 10)
    }
}

extension CreditorCommerceLibraryiOSTests {
    private func configureMockNetwork(
        dataResult: MockDataResult, downloadDataResult: MockDataResult? = nil) {
        let mockNetwork = MockNetworkManager(dataResult: dataResult, downloadResult: downloadDataResult)
        let dspWebService = DSPWebService(networkManager: mockNetwork)
        CreditorCommerceLibraryWrapper.dspService = DSPService(dspWebService: dspWebService)
    }

    private func assertGetDSPDetails(
        isVerificationRequired _: Bool = true,
        timeout: TimeInterval = Constants.requestTimeout,
        completion: (([DspDetails]?) -> Void)? = nil
    ) {
        var dspDetailsList = [DspDetails]()
        let getDSPDetailsExpectation = XCTestExpectation(description: "GetDSPDetailsExpectation")
        CreditorCommerceLibraryWrapper.getDspDetails(
            dspManifestUrl: MockData.validURL
        ) { (result: Result<[DspDetails], LibraryError>) in
            switch result {
            case let .success(dspDetails):
                dspDetailsList = dspDetails
                let testDSPDetails = MockData.dspDetails(json: DSPTestData.validDSPDetailsJsonData)
                XCTAssertEqual(dspDetails, testDSPDetails)
            case let .failure(error):
                XCTFail(error.info.description)
            }
            getDSPDetailsExpectation.fulfill()
        }
        wait(for: [getDSPDetailsExpectation], timeout: timeout)

        completion?(dspDetailsList)
    }

    private func assertGenerateUniversalLink(
        lifecycleID: String,
        businessType: Int,
        journeyType: JourneyType,
        completion: (Result<String, LibraryError>) -> Void
    ) {
        let dataResult = MockDataResult.success(DSPTestData.validJWSContent.data(using: .utf8)!)
        let downloadDataResult: MockDataResult = MockDataResult.success(DSPTestData.validCerificateData)
        configureMockNetwork(dataResult: dataResult, downloadDataResult: downloadDataResult)

        var dspDetail: DspDetails?
        let getDSPDetailsExpectation = XCTestExpectation(description: "GetDSPDetailsExpectation")
        assertGetDSPDetails { dspDetailsList in
            dspDetail = dspDetailsList?.first
            getDSPDetailsExpectation.fulfill()
        }

        CreditorCommerceLibraryWrapper.generateUniversalLink(
            dspID: dspDetail?.dspUniqueID ?? "",
            lifeCycleID: lifecycleID,
            businessType: businessType,
            journeyType: journeyType,
            completionHandler: completion
        )
        wait(for: [getDSPDetailsExpectation], timeout: Constants.requestTimeout * 8)
    }

    private func assertInvokeApp(
        lifecycleID: String,
        businessType: Int,
        journeyType: JourneyType
    ) {
        let dataResult = MockDataResult.success(DSPTestData.validJWSContent.data(using: .utf8)!)
        let downloadDataResult: MockDataResult = MockDataResult.success(DSPTestData.validCerificateData)
        configureMockNetwork(dataResult: dataResult, downloadDataResult: downloadDataResult)

        var dspDetail: DspDetails?
        let getDSPDetailsExpectation = XCTestExpectation(description: "GetDSPDetailsExpectation")
        assertGetDSPDetails { dspDetailsList in
            dspDetail = dspDetailsList?.first
            getDSPDetailsExpectation.fulfill()
        }

        let invokeAppExpectation = XCTestExpectation(description: "InvokeAppExpectation")
        CreditorCommerceLibraryWrapper.invokeApp(
            dspID: dspDetail?.dspUniqueID ?? "",
            lifeCycleID: lifecycleID,
            businessType: businessType,
            journeyType: journeyType
        ) { result in
            switch result {
            case let .success(invoked):
                print("App Invoked? \(invoked)")
                XCTAssertFalse(invoked)
            case let .failure(error):
                XCTAssertEqual(error, .unableToInvokeDSP)
            }
            invokeAppExpectation.fulfill()
        }
        wait(
            for: [getDSPDetailsExpectation, invokeAppExpectation],
            timeout: Constants.requestTimeout * 2
        )
    }
}
