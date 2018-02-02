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
    var Xpos: Int?
    var Ypos: Int?
    var direction: ShipDirection?;
    var XYpoints: Array<point>;
    var healthPoints: Int?
    
    init() {
        self.type = ShipType.none0;
        self.Xpos = nil;
        self.Ypos = nil;
        self.healthPoints = nil;
        self.direction = nil;
        self.XYpoints = Array<point>();
    }
    
    init(_type: ShipType, _Xpos: Int, _Ypos: Int, _direction: ShipDirection, _pointType: Hitbox) {
        self.type = _type;
        self.Xpos = _Xpos;
        self.Ypos = _Ypos;
        self.direction = _direction;
        self.XYpoints = Array<point>();
        
        switch _type {
        case ShipType.none0:
            self.healthPoints = 0;
        case ShipType.Fighter1:
            self.healthPoints = 1;
            self.XYpoints.append(point(x: _Xpos, y: _Ypos, type: _pointType));
        case ShipType.Hunter2:
            self.healthPoints = 2;
            self.XYpoints.append(point(x: _Xpos, y: _Ypos, type: _pointType))
            if (self.direction == ShipDirection.Horizontal) {
                self.XYpoints.append(point(x: _Xpos + 1, y: _Ypos, type: _pointType));
            } else if (direction == ShipDirection.Vertical) {
                self.XYpoints.append(point(x: _Xpos, y: _Ypos + 1, type: _pointType));
            }
            
        case ShipType.Cruiser3:
            self.healthPoints = 3;
            self.XYpoints.append(point(x: _Xpos, y: _Ypos, type: _pointType))
            if (self.direction == ShipDirection.Horizontal) {
                self.XYpoints.append(point(x: _Xpos + 1, y: _Ypos, type: _pointType));
                self.XYpoints.append(point(x: _Xpos + 2, y: _Ypos, type: _pointType));
            } else if (self.direction == ShipDirection.Vertical) {
                self.XYpoints.append(point(x: _Xpos, y: _Ypos + 1, type: _pointType));
                self.XYpoints.append(point(x: _Xpos, y: _Ypos + 2, type: _pointType));
            }
        case ShipType.Battleship4:
            self.healthPoints = 4;
            self.XYpoints.append(point(x: _Xpos, y: _Ypos, type: _pointType))
            if (self.direction == ShipDirection.Horizontal) {
                self.XYpoints.append(point(x: _Xpos + 1, y: _Ypos, type: _pointType));
                self.XYpoints.append(point(x: _Xpos + 2, y: _Ypos, type: _pointType));
                self.XYpoints.append(point(x: _Xpos + 3, y: _Ypos, type: _pointType));
            } else if (direction == ShipDirection.Vertical) {
                self.XYpoints.append(point(x: _Xpos, y: _Ypos + 1, type: _pointType));
                self.XYpoints.append(point(x: _Xpos, y: _Ypos + 2, type: _pointType));
                self.XYpoints.append(point(x: _Xpos, y: _Ypos + 3, type: _pointType));
            }
        }
        
        
        
    }
    
}
