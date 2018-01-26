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
    var selectedShipToAdding: ShipType = ShipType.none0; //variable from ships buttons to placing
    var selectedShipOrientation: ShipDirection = ShipDirection.Horizontal; //variable from ships buttons to placing
    
    var playerConsole: NSText = NSText(frame: CGRect(x: 850, y: 5, width: 400, height: 100))

    override func viewDidLoad() {
        Game.state = .Initializing
        super.viewDidLoad()
        self.view.layer?.backgroundColor = CGColor.clear;
        
        prepareController();
    }
    
    func prepareController() -> Void {
        var width: Int = 20;
        var height: Int = 20;
        
        for _ in 0...Game.FieldSize {
            width = width + 20
        }
        
        for _ in 0...Game.FieldSize {
            height = height + 20
        }
        
        width = (width*2) + 40;
        height = height + 100;
        
        self.view.frame.size.width = CGFloat(width);
        self.view.frame.size.height = CGFloat(height);
        
        //battlefield of player
        GenerateBattleField(_x: 20, _y: Int(self.view.frame.height) - 40, ButtonCount: Game.FieldSize, WhichPlayerField: .Player);
        
        //battlefield of computer
        GenerateBattleField(_x: (Int(self.view.frame.size.width) / 2) + 20, _y: Int(self.view.frame.height) - 40, ButtonCount: Game.FieldSize, WhichPlayerField: .Computer);
        
        //generate buttons to select ship
        generateShipSelectors(_x: 40, _y: 40);
        
        //generate playerConsole
        playerConsole.backgroundColor = NSColor.black;
        playerConsole.isEditable = false;
        self.view.addSubview(playerConsole);
        
        Game.state = GameState.PlacingShips;
        
        //disable for now computer field (only for placing ships
        TechUnits.turnOnOffBattlefield(ArrayWithButton: computerField, isON: false)
        
        //further code
        //......
        //......
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
                (button.cell as! NSButtonCell).showsBorderOnlyWhileMouseInside = true;
                (button.cell as! NSButtonCell).backgroundColor = NSColor.clear;
                (button.cell as! NSButtonCell).backgroundColor = NSColor.init(white: 0.5, alpha: 0.3);
                //(button.cell as! NSButtonCell).backgroundColor?.withAlphaComponent(0.1)
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
    
    func generateShipSelectors(_x: Int, _y: Int) -> Void {
        var x: Int = _x;
        let y: Int = _y;
        let pstyle = NSMutableParagraphStyle();
        pstyle.alignment = .center;
        for item in 0...3{
            switch item {
            case 0:
                let button: NSButton = NSButton(frame: CGRect(x: x, y: y, width: 120, height: 20))
                button.attributedTitle = NSMutableAttributedString(string: "FIGHTER", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: pstyle])
                (button.cell as! NSButtonCell).isBordered = true;
                (button.cell as! NSButtonCell).showsBorderOnlyWhileMouseInside = true;
                (button.cell as! NSButtonCell).backgroundColor = NSColor.clear;
                (button.cell as! NSButtonCell).backgroundColor = NSColor.init(white: 0.5, alpha: 0.3);
                button.bezelColor = NSColor.red;
                button.tag = 0;
                button.action = #selector(selectShipToAdd)
                self.view.addSubview(button);
                break
            case 1:
                let button: NSButton = NSButton(frame: CGRect(x: x, y: y, width: 120, height: 20))
                button.attributedTitle = NSMutableAttributedString(string: "HUNTER", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: pstyle])
                (button.cell as! NSButtonCell).isBordered = true;
                (button.cell as! NSButtonCell).showsBorderOnlyWhileMouseInside = true;
                (button.cell as! NSButtonCell).backgroundColor = NSColor.clear;
                (button.cell as! NSButtonCell).backgroundColor = NSColor.init(white: 0.5, alpha: 0.3);
                button.bezelColor = NSColor.red;
                button.tag = 1;
                button.action = #selector(selectShipToAdd)
                self.view.addSubview(button);
                break
            case 2:
                let button: NSButton = NSButton(frame: CGRect(x: x, y: y, width: 120, height: 20))
                button.attributedTitle = NSMutableAttributedString(string: "CRUISER", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: pstyle])
                (button.cell as! NSButtonCell).isBordered = true;
                (button.cell as! NSButtonCell).showsBorderOnlyWhileMouseInside = true;
                (button.cell as! NSButtonCell).backgroundColor = NSColor.clear;
                (button.cell as! NSButtonCell).backgroundColor = NSColor.init(white: 0.5, alpha: 0.3);
                button.bezelColor = NSColor.red;
                button.tag = 2;
                button.action = #selector(selectShipToAdd)
                self.view.addSubview(button);
                break
            case 3:
                let button: NSButton = NSButton(frame: CGRect(x: x, y: y, width: 120, height: 20))
                button.attributedTitle = NSMutableAttributedString(string: "BATTLESHIP", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: pstyle])
                (button.cell as! NSButtonCell).isBordered = true;
                (button.cell as! NSButtonCell).showsBorderOnlyWhileMouseInside = true;
                (button.cell as! NSButtonCell).backgroundColor = NSColor.clear;
                (button.cell as! NSButtonCell).backgroundColor = NSColor.init(white: 0.5, alpha: 0.3);
                button.bezelColor = NSColor.red;
                button.tag = 3;
                button.action = #selector(selectShipToAdd)
                self.view.addSubview(button);
                break
            default:
                break
            }
            x = x + 120
        }
        x = x + 80;
        
        let dirButton: NSButton = NSButton(frame: CGRect(x: x, y: y, width: 200, height: 20))
        //dirButton.title = "--Horizontal--";
        dirButton.attributedTitle = NSMutableAttributedString(string: "-- Horizontal --", attributes: [NSAttributedStringKey.foregroundColor: NSColor(calibratedHue: 0.57, saturation: 1, brightness: 1, alpha: 1), NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: pstyle])
        (dirButton.cell as! NSButtonCell).isBordered = true;
        (dirButton.cell as! NSButtonCell).showsBorderOnlyWhileMouseInside = true;
        (dirButton.cell as! NSButtonCell).backgroundColor = NSColor.clear;
        (dirButton.cell as! NSButtonCell).backgroundColor = NSColor.init(white: 0.5, alpha: 0.3);
        dirButton.bezelColor = NSColor.red;
        dirButton.tag = 4;
        dirButton.action = #selector(selectPosition)
        self.view.addSubview(dirButton);
    }
    
    @objc func buttonPressed(button: NSButton) {
        let column: Int = button.tag % Game.FieldSize;
        let row: Int = button.tag / Game.FieldSize;
        
        print("[Row:\(row): Column:\(column)]")
        print("Button.Tag = \(button.tag)")
        
        
        /*
         ################# CHANGE OF GAME STATE: Placing Ships ####################
        */
        if (Game.state == GameState.PlacingShips) {
            let shipsToPlaceLeft = Game.numberOfFigthers1+Game.numberOfHunters2+Game.numberOfCruisers3+Game.numberOfBattleships4;
            if shipsToPlaceLeft > 0 {
                switch selectedShipToAdding {
                case ShipType.Fighter1:
                    
                    print("Fighter placed at R:\(row) C:\(column)\n");
                    break;
                case ShipType.Hunter2:
                    print("Hunter placed at R:\(row) C:\(column)\n");
                    break;
                case ShipType.Cruiser3:
                    print("Cruiser placed at R:\(row) C:\(column)\n");
                    break;
                case ShipType.Battleship4:
                    print("Battleship placed at R:\(row) C:\(column)\n");
                    break;
                default:
                    print("Error, no ship to place");
                    return;
                }
            }
            if shipsToPlaceLeft == 0 {
                Game.state = GameState.PlayerTurn;
            }
        }
        
    }
    
    @objc func selectShipToAdd(button: NSButton){
        switch button.tag {
        case 0:
            selectedShipToAdding = ShipType.Fighter1;
            print("0")
            break;
        case 1:
            selectedShipToAdding = ShipType.Hunter2;
            print("1")
            break
        case 2:
            selectedShipToAdding = ShipType.Cruiser3;
            print("2")
            break
        case 3:
            selectedShipToAdding = ShipType.Battleship4;
            print("3")
            break
        default:
            return
        }
    }
    
    @objc func selectPosition(button: NSButton){
        let pstyle = NSMutableParagraphStyle();
        pstyle.alignment = .center;
        if(selectedShipOrientation == ShipDirection.Horizontal){
            button.attributedTitle = NSMutableAttributedString(string: "|||   Vertical   |||", attributes: [NSAttributedStringKey.foregroundColor: NSColor(calibratedHue: 0.4, saturation: 1, brightness: 1, alpha: 1), NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: pstyle])
            selectedShipOrientation = ShipDirection.Vertical;
        } else if (selectedShipOrientation == ShipDirection.Vertical) {
            button.attributedTitle = NSMutableAttributedString(string: "-- Horizontal --", attributes: [NSAttributedStringKey.foregroundColor: NSColor(calibratedHue: 0.57, saturation: 1, brightness: 1, alpha: 1), NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: pstyle])
            selectedShipOrientation = ShipDirection.Horizontal;
        }
    }
    
}
