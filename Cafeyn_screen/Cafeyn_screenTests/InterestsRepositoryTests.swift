//
//  InterestsRepositoryTests.swift
//  Cafeyn_screenTests
//
//  Created by Antoine Antoiniol on 14/10/2024.
//

import XCTest

class InterestsRepositoryTests: XCTestCase {
    
    var interestsRepository: InterestsRepository!
    var mockHTTPManager: MockHTTPManager!
    
    override func setUp() {
        super.setUp()
        mockHTTPManager = MockHTTPManager()
        interestsRepository = InterestsRepository(apiService: mockHTTPManager)
        //Clear UserDefaults before each test
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    override func tearDown() {
        interestsRepository = nil
        mockHTTPManager = nil
        super.tearDown()
    }
    
    //Test to load interets list if no data
    func testLoadSelectedInterests_WhenNoData_ReturnsEmptyArray() {
        let interests = interestsRepository.loadSelectedInterests()
        XCTAssertTrue(interests.isEmpty, "Expected no interests when UserDefaults is empty")
    }
    
    //Test to save interets
    func testSaveSelectedInterests_SavesDataCorrectly() {
        let interests: [Name] = [Name(raw: "Interest1", key: "Q452718"), Name(raw: "Interest2", key: "Q345698")]
        interestsRepository.saveSelectedInterests(interests)
        
        let loadedInterests = interestsRepository.loadSelectedInterests()
        XCTAssertEqual(loadedInterests.count, 2, "Expected to load 2 interests")
        XCTAssertEqual(loadedInterests, interests, "Loaded interests do not match saved interests")
    }
    
    //Test to clear interets and userdefaults
    func testClearSelectedInterests_ClearsUserDefaults() {
        let interests: [Name] = [Name(raw: "Interest1", key: "Q452718")]
        interestsRepository.saveSelectedInterests(interests)
        
        interestsRepository.clearSelectedInterests()
        let loadedInterests = interestsRepository.loadSelectedInterests()
        
        XCTAssertTrue(loadedInterests.isEmpty, "Expected interests to be cleared from UserDefaults")
    }
    
    //Test to save interets with successful request
    func testSaveCategoriesSelection_SuccessfulAPIRequest() {
        let expectation = self.expectation(description: "API call should succeed")
        
        let ids = ["1", "2", "3"]
        // Simulate successful API call
        mockHTTPManager.shouldFail = false
        
        interestsRepository.saveCategoriesSelection(ids: ids) { result in
            switch result {
            case .success:
                XCTAssertEqual(self.interestsRepository.idsToSave, ids, "IDs should match the saved IDs")
            case .failure:
                XCTFail("Expected success but received failure")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    //Test to save interets with failure request
    func testSaveCategoriesSelection_FailedAPIRequest() {
        let expectation = self.expectation(description: "API call should fail")
        
        let ids = ["1", "2", "3"]
        // Simulate failure in API call
        mockHTTPManager.shouldFail = true
        
        interestsRepository.saveCategoriesSelection(ids: ids) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but received success")
            case .failure(let error):
                XCTAssertNotNil(error, "Expected an error on failure")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
