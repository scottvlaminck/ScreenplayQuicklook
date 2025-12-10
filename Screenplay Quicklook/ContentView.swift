import SwiftUI
import WebKit
import UniformTypeIdentifiers

struct WebViewContainer: NSViewRepresentable {
    @Binding var htmlString: String

    func makeNSView(context: Context) -> WKWebView {
        WKWebView(frame: .zero)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        
        nsView.loadHTMLString(htmlString, baseURL: nil)
    }
}

struct ContentView: View {
    @State private var showingFilePicker = false
    @State private var htmlContent: String =
        "<body align='center' style='background:black;color:white;'><h1><br/><br/><br/>Select a file to preview</h1></body>"

    let supportedTypes: [UTType] = [.data]

    var body: some View {
        VStack {
            WebViewContainer(htmlString: $htmlContent)
                .frame(minWidth: 400, minHeight: 300)

            Button("Open File") {
                showingFilePicker = true
            }
        }
        .padding()
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: supportedTypes,
            allowsMultipleSelection: false
        ) { result in
            do {
                let fileURLs = try result.get()
              if let fileURL = fileURLs.first {
                
                if fileURL.startAccessingSecurityScopedResource() {
                  defer { fileURL.stopAccessingSecurityScopedResource() }
                  
                  let fileData = try Data(contentsOf: fileURL)
                  
                  
                  DispatchQueue.main.async {
                    
                    
                    do {
                      htmlContent = try HTMLConverter.htmlFrom(data: fileData)
                    } catch {
                      htmlContent = "<html><body>Error converting file to readable text.</body></html>"
                    }
                  }
                }
              }
            } catch {
                DispatchQueue.main.async {
                    htmlContent = "<html><body>Failed to load file: \(error.localizedDescription)</body></html>"
                }
            }
        }
    }
}
