//
//  Directories.swift
//  AvidcodeToolbox
//
//  Created by Andrew Christiansen on 4/25/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

/** Assists discovering the URLs to special system directories. */
public struct Directories {
    private let _domain : NSSearchPathDomainMask;
    
    private init(domain: NSSearchPathDomainMask) {
        _domain = domain;
    }
    
    /** Get the document's directory URL. */
    public var documents : NSURL {
        get {
            return try! findPath(NSSearchPathDirectory.DocumentDirectory)!;
        }
    }
    /** Get the caches directory URL. */
    public var cache : NSURL {
        get {
            return try! findPath(NSSearchPathDirectory.CachesDirectory)!;
        }
    }

    private func findPath(directory: NSSearchPathDirectory) throws -> NSURL? {
        guard let path = NSSearchPathForDirectoriesInDomains(directory, _domain, true).first else {
            return nil;
        }
        
        if (!NSFileManager.defaultManager().fileExistsAtPath(path)) {
            try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil);
        }
    
        return NSURL(fileURLWithPath: path);
    }
    
    /** Gets an instance which looks in the current user's account. */
    public static let User = Directories(domain: NSSearchPathDomainMask.UserDomainMask);
}