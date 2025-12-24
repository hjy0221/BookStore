class HomeViewModel {
    private let networkManager = NetworkManager.shared
    var books: [Book] = []
    
    // 데이터 바인딩을 위한 클로저
    var onUpdate: (() -> Void)?
    
    func fetchNewBooks() {
        // Endpoint: https://api.itbook.store/1.0/new
        networkManager.fetch(url: "https://api.itbook.store/1.0/new", type: BookListResponse.self) { [weak self] result in
            switch result {
            case .success(let response):
                self?.books = response.books
                self?.onUpdate?()
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}

class DetailViewModel {
    private let networkManager = NetworkManager.shared
    var bookDetail: BookDetailResponse?
    var onUpdate: (() -> Void)?
    let isbn13: String
    
    init(isbn13: String) {
        self.isbn13 = isbn13
    }
    
    func fetchDetail() {
        // Endpoint: https://api.itbook.store/1.0/books/
        networkManager.fetch(url: "https://api.itbook.store/1.0/books/\(isbn13)", type: BookDetailResponse.self) { [weak self] result in
            switch result {
            case .success(let detail):
                self?.bookDetail = detail
                self?.onUpdate?()
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
