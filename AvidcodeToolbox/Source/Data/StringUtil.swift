//
//  StringUtil.swift
//  SimplyTappToolbox
//
//  Created by Andrew Christiansen on 5/19/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

private let Regex = try! NSRegularExpression(
    pattern: "(?#Word the starts off lowercase)((?:$[a-z])?[a-z]+)|(?#Captures a ALL CAPS word)([A-Z]{2,}[A-Z]+(?=[A-Z][a-z]))|(?#Captures starting with 1 upper and rest lower)([A-Z](?:[a-z]+))|([A-Z]+$)|([A-Z]+(?=[^a-z]))|(?#Groups non letters)([^a-zA-Z]+)",
    options: NSRegularExpressionOptions.AllowCommentsAndWhitespace);

public extension String {
    /**
     Separates the individual words from a camel-cased string.
     
     ### Examples
     
        **`GettingStartedToday`**: `["Getting", "Started", "Today"]`.
        
        **`WebURLRequest`**: `["Web", "URL", "Request"]`
     
        **`UseSHA256Encryption`**: `["Use", "SHA", "256", "Encryption"]`
     
        **`Use2FactorAuth`**: `["Use", "2", "Factor", "Auth"]`
     
    */
    public var camelCaseWords : [String] {
        let matches = Regex.matchesInString(self, options: [], range: NSRange(location: 0, length: self.characters.count));
        var words : [String] = [];
        for m in matches {
            let word = self.substringWithRange(Range(self.characters.startIndex.advancedBy( m.range.location)..<self.characters.startIndex.advancedBy(m.range.location + m.range.length)));
            words.append(word);
        }
        return words;
      
    }
    
    
}
