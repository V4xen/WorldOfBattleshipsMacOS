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
    
    var ammo_Nuclear: Int;
    var ammo_Rockets: Int;
    var ammo_Laser: Int;
    var ammo_Battery: Int;
    
    init(_id: Int, _name: String) {
        id = _id;
        name = _name;
        self.ammo_Nuclear = 1;
        self.ammo_Rockets = 4;
        self.ammo_Laser = 0;
        self.ammo_Battery = 500;
    }
    
    init(_id: Int) {
        id = _id;
        name = "";
        self.ammo_Nuclear = 1;
        self.ammo_Rockets = 4;
        self.ammo_Laser = 0;
        self.ammo_Battery = 500;
    }
    
    func getNumberOfShips() -> Int {
        return fighters.count + hunters.count + cruisers.count + battleships.count;
    }
    
    func getAmmoLeft() -> Int {
        return ammo_Battery+ammo_Nuclear+ammo_Rockets //+ammo_Laser
    }
}
