//
//  game-main-class.swift
//  World of Battleships
//
//  Created by Vaxen van Qualn'ryne on 18.01.2018.
//  Copyright © 2018 Vaxen van Qualn'ryne. All rights reserved.
//

import Foundation

class MainGame {
    
    var state = GameState.Starting;
    var FieldSize: Int;
    
    
    init(_fieldsize: Int) {
        self.state = GameState.Starting;
        self.FieldSize = _fieldsize;
    }
    
}
