//
//  CategoriesRepositoryTests.swift
//  Cafeyn_screenTests
//
//  Created by Antoine Antoiniol on 14/10/2024.
//
import XCTest

class CategoriesRepositoryTests: XCTestCase {
    
    var repository: CategoriesRepository!
    var mockAPIService: MockHTTPManager!
    
    override func setUp() {
        super.setUp()
        
        // Initialize the mock HTTPmanager
        mockAPIService = MockHTTPManager()
        
        // Initialize the repository with the mock service
        repository = CategoriesRepository(apiService: mockAPIService)
    }
    
    override func tearDown() {
        repository = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    func testGetCategories_Success() {
        // Simulate successful API response with mock data
        let mockCategories = [Category(id: "1", name: Name(raw: "News", key: "topic.news"), subTopics: nil)]
        let mockData = try! JSONEncoder().encode(mockCategories) // Create mock JSON data
        mockAPIService.mockData = mockData
        
        let expectation = self.expectation(description: "Fetching categories succeeds")
        
        repository.getCategories { result in
            switch result {
            case .success(let categories):
                XCTAssertEqual(categories.count, 1) // Expecting one category
                XCTAssertEqual(categories.first?.name.raw, "News") // Check the name of the category
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testGetCategories_Failure() {
        // Simulate API error
        mockAPIService.shouldFail = true
        
        let expectation = self.expectation(description: "Fetching categories fails")
        
        repository.getCategories { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, APIError.invalidResponse) // Check that the error matches
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testGetCategories_DecodingFailure() {
        // Simulate decoding error by passing invalid data
        let invalidData = "Invalid JSON".data(using: .utf8)!
        mockAPIService.mockData = invalidData
        
        let expectation = self.expectation(description: "Decoding failure")
        
        repository.getCategories { result in
            switch result {
            case .success:
                XCTFail("Expected decoding failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, APIError.decodingFailed(NSError(domain: "", code: 0, userInfo: nil)))
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
