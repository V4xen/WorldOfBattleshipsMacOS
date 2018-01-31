//
//  player.swift
//  World of Battleships
//
//  Created by Vaxen van Qualn'ryne on 18.01.2018.
//  Copyright © 2018 Vaxen van Qualn'ryne. All rights reserved.
//

import Foundation

class Player {
    
    var id: Int;
    var name: String;
    
    var fighters = Array<Ship>();
    var hunters = Array<Ship>();
    var cruisers = Array<Ship>();
    var battleships = Array<Ship>();
    
    init(_id: Int, _name: String) {
        id = _id;
        name = _name;
    }
    
    init(_id: Int) {
        id = _id;
        name = "";
    }
    
    func getNumberOfShips() -> Int {
        return fighters.count + hunters.count + cruisers.count + battleships.count;
    }
}
