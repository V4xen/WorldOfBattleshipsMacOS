//
//  game-states.swift
//  World of Battleships
//
//  Created by Vaxen van Qualn'ryne on 18.01.2018.
//  Copyright © 2018 Vaxen van Qualn'ryne. All rights reserved.
//

import Foundation

enum GameState {
    case Initializing
    case PlacingShips
    case PlayerTurn, ComputerTurn
    case GameOver, Win
}
