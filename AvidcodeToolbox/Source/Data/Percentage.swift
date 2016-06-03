//
//  Percentage.swift
//  SimplyTappToolbox
//
//  Created by Andrew Christiansen on 5/23/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

postfix operator % {}
public postfix func %(v: Double) -> Double {
    return v / 100.0;
}