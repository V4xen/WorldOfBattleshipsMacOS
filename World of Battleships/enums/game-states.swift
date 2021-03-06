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
    case PlacingShips,PlaceComputerShips
    case PlayerTurn, ComputerTurn
    case EndOfGame
    case GameOver_NoAmmo, GameOver_NoShips
    case Win_NoAmmo, Win_NoShips
}
