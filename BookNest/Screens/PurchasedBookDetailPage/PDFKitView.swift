import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let fileURL: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        
        print("Trying to load PDF from: \(fileURL.path)")
        
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        print("File exists at \(fileURL.path): \(fileExists)")
        guard fileExists else {
            print("Error: File does not exist at path: \(fileURL.path)")
            return pdfView
        }
        
        if let document = PDFDocument(url: fileURL) {
            print("PDFKit successfully loaded the document. Page count: \(document.pageCount)")
            pdfView.document = document
        } else {
            print("PDFKit: Failed to load PDF document from URL: \(fileURL)")
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
