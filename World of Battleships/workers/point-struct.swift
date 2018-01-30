//
//  point-struct.swift
//  World of Battleships
//
//  Created by Vaxen van Qualn'ryne on 18.01.2018.
//  Copyright © 2018 Vaxen van Qualn'ryne. All rights reserved.
//

import Foundation

struct point {
    
    var pointType: Hitbox
    
    var X: Int?
    var Y: Int?
    
    init() {
        self.X = nil;
        self.Y = nil;
        pointType = .Space;
        
    }
    
    init(x: Int, y: Int, type: Hitbox) {
        self.X = x;
        self.Y = y;
        pointType = type;
        
    }
    
}

