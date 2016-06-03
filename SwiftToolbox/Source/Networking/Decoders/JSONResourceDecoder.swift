//
//  JSONResourceDecoder.swift
//  SimplyTappToolbox
//
//  Created by Andrew Christiansen on 5/13/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public final class JSONResourceDecoder : ResourceDecoder{
    public func canDecode(contentType: ContentType, intoType: AnyObject.Type) -> Bool {
        return contentType == ContentType("application", "json") && AnyObject.self  == intoType;
    }
    public func decode<DecodedType>(data: [UInt8], contentType: ContentType) -> Task<DecodedType> {
        return TaskFactory.Default.start { (cancelToken) in
            let result = try NSJSONSerialization.JSONObjectWithData(NSData(bytes: data, length: data.count), options: []);
            guard let converted = result as? DecodedType else {
                throw ResourceDecoderErrors.UnableToConvertToRequestType;
            }
            
            return converted;
        };
    }
}