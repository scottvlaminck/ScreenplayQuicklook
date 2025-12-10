import Cocoa
import Quartz

class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
    
        let contentType = UTType.html // replace with your data type
        
        let reply = QLPreviewReply.init(dataOfContentType: contentType, contentSize: CGSize.init(width: 800, height: 800)) { (replyToUpdate : QLPreviewReply) in

          let htmlString = try HTMLConverter.htmlFrom(data: Data(contentsOf: request.fileURL))
          let data = Data(htmlString.utf8)

          replyToUpdate.stringEncoding = .utf8
            
          return data
        }
                
        return reply
    }
}
