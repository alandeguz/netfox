//
//  NFXCommon.swift
//  
//
//  Created by Alan DeGuzman on 3/23/22.
//

import Foundation

enum NFXCommonConstants: String {
    case headersTitle = "-- Headers --\n\n"
    case bodyTitle = "\n-- Body --\n\n"
    case tooLongToShowTitle = "Too long to show. If you want to see it, please tap the following button\n"
}

protocol NFXCommon {
    
    func getResponseStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString
    
    func formatNFXString(_ string: String) -> NSAttributedString
    
    func getResponseBodyStringFooter(_ object: NFXHTTPModel) -> String
    
    func getRequestBodyStringFooter(_ object: NFXHTTPModel) -> String
    
    func getRequestStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString
    
    func getInfoStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString
    
    func generateLog(full: Bool, model: NFXHTTPModel) -> String
    
}

extension NFXCommon {
    
    func getResponseStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString {
        if (object.noResponse) {
            return NSMutableAttributedString(string: "No response")
        }
        
        var tempString: String
        tempString = String()
        
        tempString += NFXCommonConstants.headersTitle.rawValue
        
        if let count = object.responseHeaders?.count, count > 0 {
            for (key, val) in object.responseHeaders! {
                tempString += "[\(key)] \n\(val)\n\n"
            }
        } else {
            tempString += "Response headers are empty\n\n"
        }
        
        
#if os(iOS)
        tempString += getResponseBodyStringFooter(object)
#endif
        return formatNFXString(tempString)
    }
    
    func getResponseBodyStringFooter(_ object: NFXHTTPModel) -> String {
        var tempString = NFXCommonConstants.bodyTitle.rawValue
        if (object.responseBodyLength == 0) {
            tempString += "Response body is empty\n"
        } else if let lenth = object.responseBodyLength, (lenth > 1024) {
            tempString += NFXCommonConstants.tooLongToShowTitle.rawValue
        } else {
            tempString += "\(object.getResponseBody())\n"
        }
        return tempString
    }
    
    func formatNFXString(_ string: String) -> NSAttributedString {
        var tempMutableString = NSMutableAttributedString()
        tempMutableString = NSMutableAttributedString(string: string)
        
        let stringCount = string.count
        
        let regexBodyHeaders = try! NSRegularExpression(pattern: "(\\-- Body \\--)|(\\-- Headers \\--)", options: NSRegularExpression.Options.caseInsensitive)
        let matchesBodyHeaders = regexBodyHeaders.matches(in: string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, stringCount)) as Array<NSTextCheckingResult>
        
        for match in matchesBodyHeaders {
            tempMutableString.addAttribute(.font, value: NFXFont.NFXFontBold(size: 14), range: match.range)
            tempMutableString.addAttribute(.foregroundColor, value: NFXColor.NFXOrangeColor(), range: match.range)
        }
        
        let regexKeys = try! NSRegularExpression(pattern: "\\[.+?\\]", options: NSRegularExpression.Options.caseInsensitive)
        let matchesKeys = regexKeys.matches(in: string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, stringCount)) as Array<NSTextCheckingResult>
        
        for match in matchesKeys {
            tempMutableString.addAttribute(.foregroundColor, value: NFXColor.NFXBlackColor(), range: match.range)
            tempMutableString.addAttribute(.link,
                                           value: (string as NSString).substring(with: match.range),
                                           range: match.range)
        }
        
        return tempMutableString
    }
    
    func getInfoStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString {
        var tempString: String
        tempString = String()
        
        tempString += "[URL] \n\(object.requestURL!)\n\n"
        tempString += "[Method] \n\(object.requestMethod!)\n\n"
        if !(object.noResponse) {
            tempString += "[Status] \n\(object.responseStatus!)\n\n"
        }
        tempString += "[Request date] \n\(object.requestDate!)\n\n"
        if !(object.noResponse) {
            tempString += "[Response date] \n\(object.responseDate!)\n\n"
            tempString += "[Time interval] \n\(object.timeInterval!)\n\n"
        }
        tempString += "[Timeout] \n\(object.requestTimeout!)\n\n"
        tempString += "[Cache policy] \n\(object.requestCachePolicy!)\n\n"
        
        return formatNFXString(tempString)
    }
    
    func getRequestBodyStringFooter(_ object: NFXHTTPModel) -> String {
        var tempString = NFXCommonConstants.bodyTitle.rawValue
        if (object.requestBodyLength == 0) {
            tempString += "Request body is empty\n"
        } else if let length = object.requestBodyLength, (length > 1024) {
            tempString += NFXCommonConstants.tooLongToShowTitle.rawValue
        } else {
            tempString += "\(object.getRequestBody())\n"
        }
        return tempString
    }
    
    func getRequestStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString {
        var tempString: String
        tempString = String()
        
        tempString += NFXCommonConstants.headersTitle.rawValue
        
        if let count = object.requestHeaders?.count, count > 0 {
            for (key, val) in (object.requestHeaders)! {
                tempString += "[\(key)] \n\(val)\n\n"
            }
        } else {
            tempString += "Request headers are empty\n\n"
        }
        
#if os(iOS)
        tempString += getRequestBodyStringFooter(object)
#endif
        return formatNFXString(tempString)
    }
    
    func generateLog(full: Bool, model selectedModel: NFXHTTPModel) -> String {
        var tempString = String()
        
        tempString += "** INFO **\n"
        tempString += "\(getInfoStringFromObject(selectedModel).string)\n\n"
        
        tempString += "** REQUEST **\n"
        tempString += "\(getRequestStringFromObject(selectedModel).string)\n\n"
        
        tempString += "** RESPONSE **\n"
        tempString += "\(getResponseStringFromObject(selectedModel).string)\n\n"
        
        tempString += "logged via netfox - [https://github.com/kasketis/netfox]\n"
        
        if full {
            let requestFileURL = selectedModel.getRequestBodyFileURL()
            if let requestFileData = try? String(contentsOf: requestFileURL, encoding: .utf8) {
                tempString += requestFileData
            }
            
            let responseFileURL = selectedModel.getResponseBodyFileURL()
            if let responseFileData = try? String(contentsOf: responseFileURL, encoding: .utf8) {
                tempString += responseFileData
            }
        }
        return tempString
    }
    
}
