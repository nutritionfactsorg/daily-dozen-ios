//
//  Strings.swift
//  DailyDozen
//
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import Foundation
import UIKit

func parseLinkedString(_ s: String) -> NSAttributedString {
    // parses for single markdown hyperlink within the string 
    let regex = "([^\\[]*)\\[([^\\[]*)\\]\\(([^\\)]*)\\)(.*)"
    let parts = s.regexSearch(pattern: regex)
    
    let textAttributes: [NSAttributedString.Key: Any] = [
        //.foregroundColor: ColorManager.style.textBlack, 
        //.backgroundColor: UIColor.tbd,
        .font: UIFont.fontSystem17,
    ]
    
    guard parts.count == 5 else { 
        return NSAttributedString(string: s, attributes: textAttributes)
    }
    let pre = parts[1]
    let linkname = parts[2]
    let linkurl = parts[3]
    let post = parts[4]
    
    let linkAttributes: [NSAttributedString.Key: Any] = [
        //.foregroundColor: ColorManager.style.textBlack, 
        //.backgroundColor: UIColor.tbd,
        .font: UIFont.fontSystem17,
        .link: linkurl,
        //.underlineColor: UIColor.white
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    let atStr = NSMutableAttributedString(string: pre, attributes: textAttributes)
    let atLink = NSMutableAttributedString(string: linkname, attributes: linkAttributes)
    atStr.append(atLink)
    let atPost = NSMutableAttributedString(string: post, attributes: textAttributes)
    atStr.append(atPost)
    
    return atStr
}

public extension String {
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16Index = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16Index = utf16.index(from16Index, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let fromIndex = String.Index(from16Index, within: self),
            let toIndex = String.Index(to16Index, within: self)
            else { return nil }
        return fromIndex ..< toIndex
    }
    
    /// contains match within string
    func regexMatch(pattern: String) -> Bool {
        let anyMatch = self.regexSearch(pattern: pattern)
        if anyMatch.count > 0 {
            return true
        }  
        return false
    }
    
    func regexRemoving(pattern: String) -> String {
        return self.regexReplacing(pattern: pattern, template: "")
    }
    
    func regexReplacing(pattern: String, template: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            
            let nsRange = NSRange(location: 0, length: self.utf16.count)
            var outString: String?
            //autoreleasepool{
            outString = regex.stringByReplacingMatches(
                in: self,
                options: [], 
                range: nsRange, 
                withTemplate: template
            )
            //}
            return outString!
        } catch {
            return ""
        }
    }
    
    func regexSearch(pattern: String) -> [String] {
        var stringGroupMatches = [String]()
        
        do {
            
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsRangeAll = NSRange(location: 0, length: self.utf16.count)
            
            // autoreleasepool {
            let matches = regex.matches( in: self, options: [], range: nsRangeAll)
            
            for match: NSTextCheckingResult in matches {
                let rangeCount = match.numberOfRanges
                // remember: $0th match is whole pattern
                for group in 0 ..< rangeCount {
                    let nsRange: NSRange = match.range(at: group)
                    let r: Range = self.range(from: nsRange)!
                    
                    // :SWIFT4: 'substring(with:)' is deprecated: Please use String slicing subscript.
                    // stringGroupMatches.append(self.substring(with: r))
                    stringGroupMatches.append( String(self[r.lowerBound ..< r.upperBound]) )
                }
            }
            // }
            return stringGroupMatches
        } catch {
            return []
        }
    }
    
}
