//
//  game-main-class.swift
//  World of Battleships
//
//  Created by Vaxen van Qualn'ryne on 18.01.2018.
//  Copyright © 2018 Vaxen van Qualn'ryne. All rights reserved.
//

import Foundation


class MainGame {
    
    var state = GameState.Initializing;
    var FieldSize: Int;
    
    var playerField: [Hitbox];
    var computerField: [Hitbox];
    
    var player: Player;
    var computer: Player;
    
    //ships counter - how many ships should have one player
    var numberOfFigthers1: Int
    var numberOfHunters2: Int
    var numberOfCruisers3: Int
    var numberOfBattleships4: Int
    
    init(_fieldsize: Int) {
        self.state = GameState.Initializing;
        self.FieldSize = _fieldsize;
        self.playerField = [];
        self.computerField = [];
        let tmp = self.FieldSize * self.FieldSize;
        for _ in 0...tmp {
            self.playerField.append(Hitbox.Space)
            self.computerField.append(Hitbox.Space)
        }
        
        self.numberOfFigthers1 = 5
        self.numberOfHunters2 = 4
        self.numberOfCruisers3 = 3
        self.numberOfBattleships4 = 2
        
        self.player = Player(_id: 1, _name: "Captian");
        self.computer = Player(_id: 2, _name: "Enemy");
        
    }
    
    func numberOfShipsLeftToPlace() -> Int {
        return numberOfCruisers3+numberOfHunters2+numberOfFigthers1+numberOfBattleships4;
    }
    
}
