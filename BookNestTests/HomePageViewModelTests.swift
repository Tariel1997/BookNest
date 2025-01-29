import XCTest
@testable import BookNest

final class HomePageViewModelTests: XCTestCase {
    var mockDB: MockFirestore!
    var viewModel: HomePageViewModelForTest!
    
    override func setUp() {
        super.setUp()
        mockDB = MockFirestore()
        viewModel = HomePageViewModelForTest(mockDB: mockDB)
    }
    
    override func tearDown() {
        mockDB = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testFetchBooks_withMockData_shouldFetchBooks() {
        let mockBook1 = MockDocumentSnapshot(data: ["title": "Mock Book 1", "author": "Mock Author 1"])
        let mockBook2 = MockDocumentSnapshot(data: ["title": "Mock Book 2", "author": "Mock Author 2"])
        let mockCollection = mockDB.collection("books")
        mockCollection.documents = [mockBook1, mockBook2]
        
        let expectation = XCTestExpectation(description: "Books fetched")
        
        viewModel.onBooksFetched = {
            XCTAssertEqual(self.viewModel.books.count, 2)
            XCTAssertEqual(self.viewModel.books[0].title, "Mock Book 1")
            XCTAssertEqual(self.viewModel.books[0].author, "Mock Author 1")
            XCTAssertEqual(self.viewModel.books[1].title, "Mock Book 2")
            XCTAssertEqual(self.viewModel.books[1].author, "Mock Author 2")
            expectation.fulfill()
        }
        
        viewModel.fetchBooks()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchBooks_withNoData_shouldReturnEmptyBooks() {
        let mockCollection = mockDB.collection("books")
        mockCollection.documents = []
        
        let expectation = XCTestExpectation(description: "No books fetched")
        
        viewModel.onBooksFetched = {
            XCTAssertEqual(self.viewModel.books.count, 0)
            expectation.fulfill()
        }
        
        viewModel.fetchBooks()
        
        wait(for: [expectation], timeout: 1.0)
    }
}
