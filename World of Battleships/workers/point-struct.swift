//
//  point-struct.swift
//  World of Battleships
//
//  Created by Vaxen van Qualn'ryne on 18.01.2018.
//  Copyright © 2018 Vaxen van Qualn'ryne. All rights reserved.
//

import Foundation

struct point {
    var X: Int? {
        set(new) {
            X = new;
        }
        get {
            return X;
        }
    }
    var Y: Int? {
        set(new) {
            Y = new;
        }
        get {
            return Y;
        }
    }
    
    init() {
        X=nil;
        Y=nil;
    }
    
    init(x: Int, y: Int) {
        X = x;
        Y = y;
    }
    
}
