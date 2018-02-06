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
    
    //ships counter - how many ships should have player
    var numberOfPlayerFigthers1: Int
    var numberOfPlayerHunters2: Int
    var numberOfPlayerCruisers3: Int
    var numberOfPlayerBattleships4: Int
    
    var numberOfComputerFigthers1: Int
    var numberOfComputerHunters2: Int
    var numberOfComputerCruisers3: Int
    var numberOfComputerBattleships4: Int
    
    init(_fieldsize: Int) {
        self.state = GameState.Initializing;
        self.FieldSize = _fieldsize;
        self.playerField = [];
        self.computerField = [];
        let tmp = self.FieldSize * self.FieldSize;
        for _ in 0...tmp-1 {
            self.playerField.append(Hitbox.Space)
            self.computerField.append(Hitbox.Space)
        }
        
        self.numberOfPlayerFigthers1 = 1
        self.numberOfPlayerHunters2 = 0
        self.numberOfPlayerCruisers3 = 0
        self.numberOfPlayerBattleships4 = 0
        
        self.numberOfComputerFigthers1 = 2
        self.numberOfComputerHunters2 = 2
        self.numberOfComputerCruisers3 = 2
        self.numberOfComputerBattleships4 = 2
        
        self.player = Player(_id: 1, _name: "Captian");
        self.computer = Player(_id: 2, _name: "Enemy");
        
    }
    
    func numberOfPlayerShipsLeftToPlace() -> Int {
        return numberOfPlayerCruisers3+numberOfPlayerHunters2+numberOfPlayerFigthers1+numberOfPlayerBattleships4;
    }
    
    func numberOfComputerShipsLeftToPlace() -> Int {
        return numberOfComputerCruisers3+numberOfComputerHunters2+numberOfComputerFigthers1+numberOfComputerBattleships4;
    }
    
}
