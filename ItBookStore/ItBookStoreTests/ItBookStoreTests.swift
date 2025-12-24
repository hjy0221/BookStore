import XCTest
@testable import ItBookStore

@MainActor
final class ItBookStoreTests: XCTestCase {

    var homeViewModel: HomeViewModel!
    var detailViewModel: DetailViewModel!

    override func setUpWithError() throws {
        // 테스트 시작 전 초기화
        homeViewModel = HomeViewModel()
        detailViewModel = DetailViewModel(isbn13: "9781617294136")
    }

    // 홈 화면 데이터 로딩 테스트
    func testHomeViewModelFetchNewBooks() {
        let expectation = XCTestExpectation(description: "홈 화면 책 목록 가져오기")
        
        // 데이터가 업데이트되면 호출됨
        homeViewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            
            XCTAssertFalse(self.homeViewModel.books.isEmpty, "책 목록이 비어있으면 안 됩니다.")
            
            if let firstBook = self.homeViewModel.books.first {
                XCTAssertNotNil(firstBook.title)
                XCTAssertNotNil(firstBook.isbn13)
            }
            
            expectation.fulfill()
        }
        
        homeViewModel.fetchNewBooks()
        
        // 네트워크 대기 시간 10초
        wait(for: [expectation], timeout: 10.0)
    }

    // 상세 화면 데이터 로딩 테스트
    func testDetailViewModelFetchDetail() {
        let expectation = XCTestExpectation(description: "상세 정보 가져오기")
        
        detailViewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            
            guard let detail = self.detailViewModel.bookDetail else {
                XCTFail("상세 정보가 없습니다.")
                return
            }
            
            XCTAssertEqual(detail.isbn13, "9781617294136")
            XCTAssertFalse(detail.title.isEmpty)
            XCTAssertNotNil(detail.pdf, "PDF 정보가 포함되어야 합니다.")
            
            expectation.fulfill()
        }
        
        detailViewModel.fetchDetail()
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // 모델 파싱 테스트
    func testBookModelDecoding() {
        let jsonString = """
        {
            "title": "Test Book",
            "subtitle": "Test Subtitle",
            "isbn13": "1234567890123",
            "price": "$10.00",
            "image": "https://example.com/image.png",
            "url": "https://example.com/book"
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        
        do {
            let book = try JSONDecoder().decode(Book.self, from: jsonData)
            XCTAssertEqual(book.title, "Test Book")
            XCTAssertEqual(book.isbn13, "1234567890123")
        } catch {
            XCTFail("디코딩 실패: \(error)")
        }
    }
}
