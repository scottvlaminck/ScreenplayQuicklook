import Foundation

struct HTMLConverter {

    static func htmlFrom(data: Data) throws -> String {
      guard let stringData = String(data: data, encoding: .utf8) else {
        print("error in htmlFrom data")
          throw ConversionError.invalidEncoding
      }
      return try htmlFrom(stringData: stringData)
    }
    
      static func htmlFrom(stringData: String) throws -> String {

      
      return FDXConverter.renderFdxToHtml(stringData: stringData)
    }

    enum ConversionError: Error {
        case invalidEncoding
    }

    private static func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
  
  
}

struct FDXConverter {
  
    static func renderFdxToHtml(stringData: String) -> String {
          let bodyHTML = FDXConverter.convertFDXToHTMLBodyString(stringData)
          let css = FDXConverter.buildCSS()
          
          let fullHTML = """
          <html>
            <head>
              <meta charset="utf-8">
              <style>
              \(css)
              </style>
            </head>
            \(bodyHTML)
          </html>
          """
          
          return fullHTML
  }
  
    static func convertFDXToHTMLBodyString(_ fdx: String) -> String {
        var trimmed = trimStringAfterFirstOccurrence(in: fdx, separator: "</Content>")
        
        trimmed = replaceContentBetween(
            startMarker: "<?xml",
            endMarker: ">",
            with: "",
            in: trimmed
        )
        
        trimmed = replaceContentBetween(
            startMarker: "<FinalDraft",
            endMarker: ">",
            with: "",
            in: trimmed
        )

        let pairs: [(String, String)] = [
            ("<Content>", #" <body> "#),
            ("</Content>", #" </body> "#),
            (#"Paragraph Type="Scene Heading""#, #"div class="SceneHeading""#),
            (#"Paragraph Type="#, #"div class="#),
            ("</Paragraph>", #" </div> "#),
            ("SceneProperties", #"div class="SceneProperties""#),
            ("<Text>", ""),
            ("</Text>", "")
        ]
        
        var result = trimmed
        for (target, replacement) in pairs {
            result = result.replacingOccurrences(of: target, with: replacement)
        }
        
        return result
    }

    static func trimStringAfterFirstOccurrence(in source: String, separator: String) -> String {
        if let range = source.range(of: separator) {
            let endIndex = range.upperBound   
            return String(source[..<endIndex])
        } else {
            return source
        }
    }

    static func replaceContentBetween(
        startMarker: String,
        endMarker: String,
        with newContent: String,
        in original: String
    ) -> String {
        var mutable = original
        var searchRange: Range<String.Index>? = mutable.startIndex..<mutable.endIndex
        
        while let currentSearchRange = searchRange,
              let startRange = mutable.range(of: startMarker, range: currentSearchRange) {
            
            let remainingRange = startRange.upperBound..<mutable.endIndex
            
            guard let endRange = mutable.range(of: endMarker, range: remainingRange) else {
                break
            }
            
            let rangeToReplace = startRange.lowerBound..<endRange.upperBound
            mutable.replaceSubrange(rangeToReplace, with: newContent)
            
            let nextStart = mutable.index(startRange.lowerBound, offsetBy: newContent.count)
            if nextStart >= mutable.endIndex {
                searchRange = nil
            } else {
                searchRange = nextStart..<mutable.endIndex
            }
        }
        
        return mutable
    }
    
    static func buildCSS() -> String {

        let screenplayCSS = """
        body {
            font-family: "Courier New", Courier, monospace;
            font-size: 12pt;
            /* Standard 1 inch top/bottom, 1.5 inch left margin for binding */
            margin: 1in 1in 1in 1.5in;
            line-height: 1.2; /* A little tighter line spacing */
            max-width: 6in; /* Content width after margins */
            color: black;
        }
        
        .SceneHeading {
            text-transform: uppercase;
            margin-top: 12pt;
            margin-bottom: 12pt;
        }
        
        .Character {
            text-align: left;
            text-transform: uppercase;
            margin-top: 12pt;
            margin-bottom: 0pt;
            /* Standard measurement: 3.7 inches from the left edge of the page */
            margin-left: 2.2in;
        }
        
        .Dialogue {
            margin-top: 0pt;
            margin-bottom: 6pt;
            /* Standard measurement: 2.5 inches from the left edge of the page */
            margin-left: 1in;
            /* Dialogue blocks typically have a specific width */
            width: 3.5in;
        }
        
        .Parenthetical {
            font-style: italic;
            text-align: left;
            /* Standard measurement: 3.1 inches from the left edge of the page */
            margin-left: 1.6in;
            width: 2.3in; /* A narrow block */
        }
        
        .Action, .General {
            margin-top: 12pt;
            margin-bottom: 12pt;
            /* Action lines run closer to the full margin width */
            margin-left: 0in;
            margin-right: 0in;
        }
        
        .Transition {
            text-align: right;
            margin-top: 12pt;
            margin-bottom: 12pt;
            text-transform: uppercase;
            margin-right: 0.5in;
        }
        
        .Shot {
            text-transform: uppercase;
            margin-top: 12pt;
            margin-bottom: 12pt;
        }
        
        .SceneProperties {
            display: none;
        }
        """
        
        return screenplayCSS
    }
}
