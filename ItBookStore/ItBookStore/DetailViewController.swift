import UIKit

class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    private let scrollView = UIScrollView()
    private let infoLabel = UILabel() 
    private let imageView = UIImageView()
    
    init(isbn13: String) {
        self.viewModel = DetailViewModel(isbn13: isbn13)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        viewModel.onUpdate = { [weak self] in
            self?.updateView()
        }
        viewModel.fetchDetail()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        
        scrollView.addSubview(imageView)
        scrollView.addSubview(infoLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.numberOfLines = 0
        
        // AutoLayout 설정 (생략)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            
            infoLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            infoLabel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateView() {
        guard let data = viewModel.bookDetail else { return }
        
        // 이미지 로드
        if let url = URL(string: data.image) {
            ImageCacheManager.shared.getImage(url: url) { [weak self] img in
                self?.imageView.image = img
            }
        }
        
        // 모든 정보 텍스트 바인딩
        var text = """
        Title: \(data.title)
        Subtitle: \(data.subtitle)
        Authors: \(data.authors)
        Publisher: \(data.publisher)
        Price: \(data.price)
        Description: \(data.desc)
        """
        
        if let pdfs = data.pdf {
            text += "\n\n[PDF Links]\n"
            for (key, value) in pdfs {
                text += "\(key): \(value)\n"
            }
        }
        
        infoLabel.text = text
    }
}
