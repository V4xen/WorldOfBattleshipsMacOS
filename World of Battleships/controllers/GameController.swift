//
//  GameController.swift
//  World of Battleships
//
//  Created by Vaxen van Qualn'ryne on 23.01.2018.
//  Copyright © 2018 Vaxen van Qualn'ryne. All rights reserved.
//

import Cocoa

class GameController: NSViewController {
    
    var Game = MainGame(_fieldsize: 30);
    var playerField: [NSButton] = [];
    var computerField: [NSButton] = [];

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareController();
        
        
        
    }
    
    func prepareController() -> Void {
        var wight: Int = 20;
        var height: Int = 20;
        
        for _ in 0...Game.FieldSize {
            wight = wight + 20
        }
        
        for _ in 0...Game.FieldSize {
            height = height + 20
        }
        
        wight = (wight*2) + 40;
        height = height + 100;
        
        self.view.frame.size.width = CGFloat(wight);
        self.view.frame.size.height = CGFloat(height);
        
        GenerateBattleField(_x: 20, _y: Int(self.view.frame.height) - 20, ButtonCount: Game.FieldSize, WhichPlayerField: .Player);
        GenerateBattleField(_x: (Int(self.view.frame.size.width) / 2) + 20, _y: Int(self.view.frame.height) - 20, ButtonCount: Game.FieldSize, WhichPlayerField: .Computer);
    }
    
    func GenerateBattleField(_x: Int, _y: Int, ButtonCount: Int, WhichPlayerField: WhichField) -> Void {
        var x: Int = _x;
        var y: Int = _y;
        var buttonID: Int = 0
        for _ in 0...ButtonCount-1{
            for _ in 0...ButtonCount-1{
                let button: NSButton = NSButton(frame: CGRect(x: x, y: y, width: 20, height: 20))
                button.title = "";
                (button.cell as! NSButtonCell).isBordered = true;
                (button.cell as! NSButtonCell).backgroundColor = NSColor.lightGray;
                button.tag = buttonID;
                button.action = #selector(buttonPressed)
                if(WhichPlayerField == WhichField.Player){
                    playerField.append(button);
                } else {
                    computerField.append(button);
                }
                self.view.addSubview(button);
                x = x + 20;
                buttonID = buttonID + 1;
            }
            x = _x;
            y = y - 20;
        }
    }
    
    @objc func buttonPressed(button: NSButton) {
        
    }
}
