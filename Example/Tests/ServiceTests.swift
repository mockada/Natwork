import XCTest
import Natwork
@testable import Natwork_Example

final class ServiceTests: XCTestCase {
    private var networkMock: NetworkMock?
    private var sut: Service?
    
    override func setUp() {
        networkMock = NetworkMock()

        guard let networkMock = networkMock else { return }
        sut = Service(network: networkMock)
        super.setUp()
    }

    override func tearDown() {
        networkMock = nil
        sut = nil

        super.tearDown()
    }
}

extension ServiceTests {
    func testFetchData() {
        let expectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        networkMock?.fetchDataEndpointExpectedResult = .success([Response.fixture()])
        
        sut?.fetchData { result in
            XCTAssertEqual(result, .success([.fixture()]))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testUpdateData() {
        let expectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        networkMock?.fetchDataEndpointExpectedResult = .success(Response.fixture())
        
        sut?.updateData(request: .fixture()) { result in
            XCTAssertEqual(result, .success(Response.fixture()))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
}
