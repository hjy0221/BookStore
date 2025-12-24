// 책 목록 응답 (홈 화면)
struct BookListResponse: Codable {
    let error: String
    let total: String
    let books: [Book]
}

// 상세 정보 응답 (상세 화면)
struct BookDetailResponse: Codable {
    let error: String
    let title: String
    let subtitle: String
    let authors: String
    let publisher: String
    let isbn10: String
    let isbn13: String
    let pages: String
    let year: String
    let rating: String
    let desc: String
    let price: String
    let image: String
    let url: String
    let pdf: [String: String]? // PDF 정보 포함
}

// 공통 책 모델
struct Book: Codable {
    let title: String
    let subtitle: String
    let isbn13: String
    let price: String
    let image: String
    let url: String
}
