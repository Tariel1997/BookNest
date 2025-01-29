import Foundation

final class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    private let progressHandler: (Float) -> Void
    private let completionHandler: (URL?) -> Void
    private let errorHandler: (Error) -> Void
    
    init(progressHandler: @escaping (Float) -> Void,
         completionHandler: @escaping (URL?) -> Void,
         errorHandler: @escaping (Error) -> Void) {
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        self.errorHandler = errorHandler
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        defer {
            try? FileManager.default.removeItem(at: location)
        }
        
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsPath.appendingPathComponent(location.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.moveItem(at: location, to: destinationURL)
            completionHandler(destinationURL)
        } catch {
            errorHandler(error)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            errorHandler(error)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        progressHandler(progress)
    }
}
