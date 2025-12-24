import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    // 메모리 캐시: NSCache 사용
    private let memoryCache = NSCache<NSString, UIImage>()
    // 디스크 캐시: FileManager 사용
    private let fileManager = FileManager.default
    
    private init() {}
    
    func getImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = url.lastPathComponent as NSString
        
        // 메모리 캐시 확인
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        
        // 디스크 캐시 확인
        let diskPath = getDiskPath(forKey: cacheKey as String)
        if fileManager.fileExists(atPath: diskPath.path),
           let diskData = try? Data(contentsOf: diskPath),
           let image = UIImage(data: diskData) {
            memoryCache.setObject(image, forKey: cacheKey) // 메모리로 올림
            completion(image)
            return
        }
        
        // 네트워크 다운로드
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 캐시 저장
            self?.memoryCache.setObject(image, forKey: cacheKey)
            try? data.write(to: self?.getDiskPath(forKey: cacheKey as String) ?? url)
            
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }
    
    private func getDiskPath(forKey key: String) -> URL {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cacheDirectory.appendingPathComponent(key)
    }
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

final class NetworkManager {
    static let shared = NetworkManager()
    private let fileManager = FileManager.default
    
    // JSON 데이터 캐싱을 위한 경로
    private var cacheDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func fetch<T: Codable>(url: String, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let validURL = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // 파일 이름 생성 (URL을 인코딩하여 파일명으로 사용)
        let fileName = validURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "temp"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        // 네트워크 요청
        URLSession.shared.dataTask(with: validURL) { data, response, error in
            // 네트워크 성공 시
            if let data = data, error == nil {
                // 데이터를 디스크에 저장 (오프라인용)
                try? data.write(to: fileURL)
                
                if let decoded = try? JSONDecoder().decode(T.self, from: data) {
                    DispatchQueue.main.async { completion(.success(decoded)) }
                    return
                }
            }
            
            // 네트워크 실패 혹은 디코딩 실패 시 -> 로컬 캐시 확인 (오프라인 모드)
            if let savedData = try? Data(contentsOf: fileURL),
               let decoded = try? JSONDecoder().decode(T.self, from: savedData) {
                print("Loaded from Local Cache (Offline Mode)")
                DispatchQueue.main.async { completion(.success(decoded)) }
                return
            }
            
            DispatchQueue.main.async { completion(.failure(error ?? NetworkError.requestFailed)) }
        }.resume()
    }
}
