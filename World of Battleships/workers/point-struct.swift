//
//  point-struct.swift
//  World of Battleships
//
//  Created by Vaxen van Qualn'ryne on 18.01.2018.
//  Copyright © 2018 Vaxen van Qualn'ryne. All rights reserved.
//

import Foundation

struct point {
    
    var hitted: Bool? {
        set(new) {
            hitted = new;
        }
        get {
            return self.hitted;
        }
    }
    
    var X: Int? {
        set(new) {
            X = new;
        }
        get {
            return self.X;
        }
    }
    var Y: Int? {
        set(new) {
            Y = new;
        }
        get {
            return self.Y;
        }
    }
    
    
    
    init() {
        self.X = nil;
        self.Y = nil;
        hitted=false
        
    }
    
    init(x: Int, y: Int, _hit: Bool) {
        self.X = x;
        self.Y = y;
        hitted=false
        
    }
    
}
