//
//  ship-class.swift
//  World of Battleships
//
//  Created by Vaxen van Qualn'ryne on 18.01.2018.
//  Copyright © 2018 Vaxen van Qualn'ryne. All rights reserved.
//

import Foundation

class Ship {
    var type: ShipType;
    var Xpos: Int
    var Ypos: Int
    var direction: ShipDirection;
    var XYpoints: Array<point>;
    var healthPoints: Int
    
    init() {
        type = ShipType.none0;
        Xpos = -1
        Ypos = -1
        healthPoints = -1
        direction = ShipDirection.Vertical
        XYpoints = Array<point>();
    }
    
    init(_type: ShipType, _Xpos: Int, _Ypos: Int, _direction: ShipDirection, _pointType: Hitbox) {
        type = _type;
        Xpos = _Xpos;
        Ypos = _Ypos;
        direction = _direction;
        XYpoints = Array<point>();
        
        switch _type {
        case ShipType.none0:
            healthPoints = 0;
        case ShipType.Fighter1:
            healthPoints = 1;
            XYpoints.append(point(x: _Xpos, y: _Ypos, type: _pointType));
        case ShipType.Hunter2:
            healthPoints = 2;
            XYpoints.append(point(x: _Xpos, y: _Ypos, type: _pointType))
            if (direction == ShipDirection.Horizontal) {
                XYpoints.append(point(x: _Xpos + 1, y: _Ypos, type: _pointType));
            } else if (direction == ShipDirection.Vertical) {
                XYpoints.append(point(x: _Xpos, y: _Ypos + 1, type: _pointType));
            }
            
        case ShipType.Cruiser3:
            healthPoints = 3;
            XYpoints.append(point(x: _Xpos, y: _Ypos, type: _pointType))
            if (direction == ShipDirection.Horizontal) {
                XYpoints.append(point(x: _Xpos + 1, y: _Ypos, type: _pointType));
                XYpoints.append(point(x: _Xpos + 2, y: _Ypos, type: _pointType));
            } else if (direction == ShipDirection.Vertical) {
                XYpoints.append(point(x: _Xpos, y: _Ypos + 1, type: _pointType));
                XYpoints.append(point(x: _Xpos, y: _Ypos + 2, type: _pointType));
            }
        case ShipType.Battleship4:
            healthPoints = 4;
            XYpoints.append(point(x: _Xpos, y: _Ypos, type: _pointType))
            if (direction == ShipDirection.Horizontal) {
                XYpoints.append(point(x: _Xpos + 1, y: _Ypos, type: _pointType));
                XYpoints.append(point(x: _Xpos + 2, y: _Ypos, type: _pointType));
                XYpoints.append(point(x: _Xpos + 3, y: _Ypos, type: _pointType));
            } else if (direction == ShipDirection.Vertical) {
                XYpoints.append(point(x: _Xpos, y: _Ypos + 1, type: _pointType));
                XYpoints.append(point(x: _Xpos, y: _Ypos + 2, type: _pointType));
                XYpoints.append(point(x: _Xpos, y: _Ypos + 3, type: _pointType));
            }
        }
        
        
        
    }
    
}
