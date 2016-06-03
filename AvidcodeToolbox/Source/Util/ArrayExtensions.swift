//
//  ArrayExtensions.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/11/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public extension Array where Element : Equatable {
    mutating public func removeObject(object: Element) {
        guard let index = self.indexOf(object) else {
            return;
        }
        
        self.removeAtIndex(index);
    }
    
    public mutating func removeContentsOf<S : SequenceType where S.Generator.Element == Element>(elements: S) {
        for e in elements {
            self.removeObject(e);
        }
    }
}

public extension Array {
    public mutating func firstIf(@noescape includeElement: (Generator.Element) -> Bool) -> Generator.Element?  {
        return self.filter(includeElement).first;
    }
    public mutating func removeIf(@noescape includeElement: (Generator.Element) -> Bool)  {
        while true {
            var found = false;
            for x in 0..<self.count {
                let e = self[x];
                if includeElement(e) {
                    self.removeAtIndex(x);
                    found = true;
                    break;
                }
            }
            
            if (!found) {
                break;
            }
        }
    }
}