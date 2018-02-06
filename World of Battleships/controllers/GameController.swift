//
//  GameController.swift
//  World of Battleships
//
//  Created by Vaxen van Qualn'ryne on 23.01.2018.
//  Copyright © 2018 Vaxen van Qualn'ryne. All rights reserved.
//

import Cocoa

class GameController: NSViewController {
    
    let pstyle = NSMutableParagraphStyle();
    
    var Game = MainGame(_fieldsize: 30);
    var playerButtonsField: [NSButton] = [];
    var computerButtonsField: [NSButton] = [];
    var functionButtons: [NSButton] = [];
    
    var shipDestroyed: ShipType = .none0;
    
    var selectedShipToAdding: ShipType = ShipType.none0; //variable from ships buttons to placing
    var selectedShipOrientation: ShipDirection = ShipDirection.Horizontal; //variable from ships buttons to placing
    var selectedAmmoType: AmmoType = .none;
    
    var playerConsole: NSText = NSText(frame: CGRect(x: 850, y: 5, width: 400, height: 100))

    override func viewDidLoad() {
        Game.state = .Initializing
        super.viewDidLoad()
        self.view.layer?.backgroundColor = CGColor.clear;
        pstyle.alignment = .center;
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
        playerConsole.textColor = NSColor.init(red: 0.35352, green: 1, blue: 0.01960, alpha: 1);
        playerConsoleWrite(text: "", to: playerConsole)
        playerConsole.isEditable = false;
        self.view.addSubview(playerConsole);
        
        Game.state = GameState.PlacingShips;
        playerConsoleWrite(text: "Select ship to place...", to: playerConsole)
        
        //disable for now computer field (only for placing ships)
        TechUnits.buttonsEnableDisable(Buttons: computerButtonsField, switchTo: false)
        
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
            placeShip(button: button);
            updatePlayerConsole();
        }
        
        /*
         ################# CHANGE OF GAME STATE: Placing Computer Ships (generating battlefield of bot) ####################
         */
        if (Game.state == GameState.PlaceComputerShips) {
            playerConsoleWrite(text: "\n\t:-)", to: playerConsole);
            TechUnits.buttonsEnableDisable(Buttons: functionButtons, switchTo: false)
            TechUnits.buttonsEnableDisable(Buttons: playerButtonsField, switchTo: false)
            placingComputerShipsGenerator(buttonsArray: computerButtonsField);
            
            //change game state end turn on computers field
            Game.state = GameState.PlayerTurn;
            
            //prepare next stage - next game state
            //generate ammo types buttons
            TechUnits.buttonsEnableDisable(Buttons: functionButtons, switchTo: true);
            changeFunctionButtons();
            
            TechUnits.buttonsEnableDisable(Buttons: computerButtonsField, switchTo: true)
            playerConsoleWrite(text: "\nPick ammo type to shot!", to: playerConsole);
            
        } else {
            /*
             ################# CHANGE OF GAME STATE: Shooting! ####################
             */
            if (Game.state == GameState.PlayerTurn) {
                if (shipDestroyed != .none0) {
                    switch shipDestroyed {
                    case .Fighter1:
                        playerConsoleWrite(text: "\n\n\t\tFIGHTER DESTROYED!", to: playerConsole);
                        break;
                    case .Hunter2:
                        playerConsoleWrite(text: "\n\n\t\tHUNTER DESTROYED!", to: playerConsole);
                        break;
                    case .Cruiser3:
                        playerConsoleWrite(text: "\n\n\t\tCRUISER DESTROYED!", to: playerConsole);
                        break;
                    case .Battleship4:
                        playerConsoleWrite(text: "\n\n\t\tBATTLESHIP DESTROYED!", to: playerConsole);
                        break;
                    case .none0:
                        updatePlayerConsole();
                        break;
                    }
                }
                // player shot function:
                shipDestroyed = .none0;
                playerShot(button: button);
                
                
                // disable bot field for a while
                //TechUnits.buttonsEnableDisable(Buttons: computerButtonsField, switchTo: false);
                Game.state = GameState.ComputerTurn;
            }
            
            if (Game.state == GameState.ComputerTurn && Game.computer.getNumberOfShips() == 0) {
                Game.state = .Win_NoShips;
            }
            
            if (Game.state == GameState.ComputerTurn && Game.player.getAmmoLeft() == 0) {
                Game.state = .GameOver_NoAmmo;
            }
            
            if (Game.state == .ComputerTurn) {
                // update console and simulate "thinking" of bot
                //playerConsoleWrite(text: "\nComputer is shooting, just wait", to: playerConsole);
                //sleep(2); //- bad idea!
                
                // computer shot function:
                while (!computerShot()) {};
                
                // enable bot field back
                //TechUnits.buttonsEnableDisable(Buttons: computerButtonsField, switchTo: true);
                Game.state = GameState.PlayerTurn;
                //updatePlayerConsole();
            }
            
            if (Game.state == GameState.PlayerTurn && Game.computer.getAmmoLeft() == 0) {
                Game.state = .Win_NoAmmo;
            }
            
            if (Game.state == GameState.PlayerTurn && Game.player.getNumberOfShips() == 0) {
                Game.state = .GameOver_NoShips;
            }
            
            // check if it's end of game:
            if (Game.state == GameState.PlayerTurn && Game.state == GameState.EndOfGame) {
                // checking dependencities to win the game, else it's lost
                
                
            }
            
            if (Game.state == .Win_NoAmmo) {
                TechUnits.buttonsEnableDisable(Buttons: computerButtonsField, switchTo: false);
                playerConsoleWrite(text: "", to: playerConsole);
                let modalWindowResult = TechUnits.dialogOKCancel(question: "You won!", text: "Enemy as been out of ammo and flee away! You won this battle!", buttons: TechUnits.Buttons.OK);
                if (modalWindowResult == true) {
                    self.view.window?.close()
                }
            }
            
            if (Game.state == .Win_NoShips) {
                TechUnits.buttonsEnableDisable(Buttons: computerButtonsField, switchTo: false);
                playerConsoleWrite(text: "", to: playerConsole);
                let modalWindowResult = TechUnits.dialogOKCancel(question: "You won!", text: "Congratulations! You have destroyed all enemy ships! Enemy fleet is disturbed!", buttons: TechUnits.Buttons.OK);
                if (modalWindowResult == true) {
                    self.view.window?.close()
                }
            }
            
            if (Game.state == .GameOver_NoAmmo) {
                TechUnits.buttonsEnableDisable(Buttons: computerButtonsField, switchTo: false);
                playerConsoleWrite(text: "", to: playerConsole);
                let modalWindowResult = TechUnits.dialogOKCancel(question: "Game over!", text: "You lost this battle! You're out of ammunition!", buttons: .OK);
                if (modalWindowResult == true) {
                    self.view.window?.close()
                }
            }
            if (Game.state == .GameOver_NoShips) {
                TechUnits.buttonsEnableDisable(Buttons: computerButtonsField, switchTo: false);
                playerConsoleWrite(text: "", to: playerConsole);
                let modalWindowResult = TechUnits.dialogOKCancel(question: "Game over!", text: "You lost this battle! Your fleet has been destroyed!", buttons: .OK);
                if (modalWindowResult == true) {
                    self.view.window?.close()
                }
            }
        }
    }
    
    func playerConsoleWrite(text: String, to: NSText) {
        if (Game.state == GameState.Initializing) {
            to.string = "\tGame is initialized... \n\n\tJust Wait..."
        }
        if (Game.state == GameState.PlacingShips) {
            to.string = "Select type of ship and place it:\n" + "All ships left: \(Game.numberOfPlayerShipsLeftToPlace())\n" + "\tFighters left to place: \(Game.numberOfPlayerFigthers1)\n" + "\tHunters left to place: \(Game.numberOfPlayerHunters2)\n" + "\tCruisers left to place: \(Game.numberOfPlayerCruisers3)\n" + "\tBattleships left to place: \(Game.numberOfPlayerBattleships4)\n" + text;
        }
        if (Game.state == GameState.PlaceComputerShips) {
            to.string = "\nWait for computer to place his ships\n" + text;
        }
        if (Game.state == GameState.PlayerTurn) {
            // write how many ammo left
            to.string = "Select type of ammunition:\t\tEnemy's ships left: \(Game.computer.getNumberOfShips())\n" + "\tBattery amunition left: \(Game.player.ammo_Battery)\n" + "\tRockets left: \(Game.player.ammo_Rockets)\n" + "\tLaser energy left: \(Game.player.ammo_Laser)\n" + "\tNuclear balistics left: \(Game.player.ammo_Nuclear)\n" + text;
        }
        if (Game.state == GameState.ComputerTurn) {
            to.string = "Enemy turn - wait 'till shot...\t\tEnemy's ships left: \(Game.computer.getNumberOfShips())\n" + "\tBattery amunition left: \(Game.player.ammo_Battery)\n" + "\tRockets left: \(Game.player.ammo_Rockets)\n" + "\tLaser energy left: \(Game.player.ammo_Laser)\n" + "\tNuclear balistics left: \(Game.player.ammo_Nuclear)\n" + text;
        }
        
        if (Game.state == .Win_NoAmmo || Game.state == .Win_NoShips || Game.state == GameState.GameOver_NoAmmo || Game.state == .GameOver_NoShips) {
            to.string = "\n\n\tIt's over, no more ammo or ships to shot!\n" + text /*debug:*/ + "\nNumber of ships enemy left: \(Game.computer.getNumberOfShips())";
        }
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
                    playerButtonsField.append(button);
                } else {
                    computerButtonsField.append(button);
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
                functionButtons.insert(button, at: button.tag);
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
                functionButtons.insert(button, at: button.tag);
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
                functionButtons.insert(button, at: button.tag);
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
                functionButtons.insert(button, at: button.tag);
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
        functionButtons.insert(dirButton, at: dirButton.tag);
        self.view.addSubview(dirButton);
    }
    
    func changeFunctionButtons() {
        if (Game.state == .PlayerTurn) {
            functionButtons[0].attributedTitle = NSMutableAttributedString(string: "Battery", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: pstyle])
            functionButtons[0].action = #selector(selectAmmoType)
            
            functionButtons[1].attributedTitle = NSMutableAttributedString(string: "Rocket", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: pstyle])
            functionButtons[1].isEnabled = false;
            functionButtons[1].action = #selector(selectAmmoType)
            
            functionButtons[2].attributedTitle = NSMutableAttributedString(string: "Laser", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: pstyle])
            functionButtons[2].isEnabled = false;
            functionButtons[2].action = #selector(selectAmmoType)
            
            functionButtons[3].attributedTitle = NSMutableAttributedString(string: "Nuclear", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: pstyle])
            functionButtons[3].isEnabled = false;
            functionButtons[3].action = #selector(selectAmmoType)
            
            functionButtons[4].isEnabled = false;
        }
    }
    
    func placingComputerShipsGenerator(buttonsArray: [NSButton]) {
        //place all of battleships...
        var varRepeat: Bool;
        while (Game.numberOfComputerBattleships4 > 0){
            repeat {
                let randomTag = TechUnits.random(a: Game.FieldSize * Game.FieldSize);
                varRepeat = placeComputerShip(button: computerButtonsField[randomTag], _shiptype: .Battleship4);
            } while (!varRepeat)
        }
        
        //place all of cruisers...
        while (Game.numberOfComputerCruisers3 > 0) {
            repeat {
                let randomTag = TechUnits.random(a: Game.FieldSize * Game.FieldSize);
                varRepeat = placeComputerShip(button: computerButtonsField[randomTag], _shiptype: .Cruiser3);
            } while (!varRepeat)
        }
        
        //place all of hunters...
        while (Game.numberOfComputerHunters2 > 0) {
            repeat {
                let randomTag = TechUnits.random(a: Game.FieldSize * Game.FieldSize);
                varRepeat = placeComputerShip(button: computerButtonsField[randomTag], _shiptype: .Hunter2);
            } while (!varRepeat)
        }
        
        //place all of fighters...
        while (Game.numberOfComputerFigthers1 > 0) {
            repeat {
                let randomTag = TechUnits.random(a: Game.FieldSize * Game.FieldSize);
                varRepeat = placeComputerShip(button: computerButtonsField[randomTag], _shiptype: .Fighter1);
            } while (!varRepeat)
        }
    }
    
    func updatePlayerConsole() {
        if (Game.state == .PlacingShips) {
            switch selectedShipToAdding {
            case ShipType.Fighter1:
                playerConsoleWrite(text: "Selected ship type:\t♙ FIGHTER ♙", to: playerConsole);
                break;
            case ShipType.Hunter2:
                playerConsoleWrite(text: "Selected ship type:\t♖ HUNTER ♖", to: playerConsole);
                break;
            case ShipType.Cruiser3:
                playerConsoleWrite(text: "Selected ship type:\t♘ CRUISER ♘", to: playerConsole);
                break;
            case ShipType.Battleship4:
                playerConsoleWrite(text: "Selected ship type:\t♕ BATTLESHIP ♕", to: playerConsole);
                break
            default:
                return
            }
        }
        if (Game.state == .PlayerTurn) {
            switch selectedAmmoType {
            case .Battery:
                playerConsoleWrite(text: "\nSelected ammo type:\t💥BATTERY💥", to: playerConsole);
                break;
            case .Rocket:
                playerConsoleWrite(text: "\nSelected ammo type:\t🚀ROCKET🚀", to: playerConsole);
                break;
            case .Laser:
                playerConsoleWrite(text: "\nSelected ammo type:\t🔺LASER🔺", to: playerConsole);
                break;
            case .Nuclear:
                playerConsoleWrite(text: "\nSelected ammo type:\t⚛️ NUCLEAR ⚛️", to: playerConsole);
                break
            case .none:
                playerConsoleWrite(text: "\nPick ammo type to shot!", to: playerConsole);
                break;
            }
        }
    }
    
    @objc func selectShipToAdd(button: NSButton){
        switch button.tag {
        case 0:
            selectedShipToAdding = ShipType.Fighter1;
            print("0")
            playerConsoleWrite(text: "Selected ship type:\t♙ FIGHTER ♙", to: playerConsole);
            break;
        case 1:
            selectedShipToAdding = ShipType.Hunter2;
            print("1")
            playerConsoleWrite(text: "Selected ship type:\t♖ HUNTER ♖", to: playerConsole);
            break
        case 2:
            selectedShipToAdding = ShipType.Cruiser3;
            print("2")
            playerConsoleWrite(text: "Selected ship type:\t♘ CRUISER ♘", to: playerConsole);
            break
        case 3:
            selectedShipToAdding = ShipType.Battleship4;
            print("3")
            playerConsoleWrite(text: "Selected ship type:\t♕ BATTLESHIP ♕", to: playerConsole);
            break
        default:
            return
        }
    }
    
    @objc func selectAmmoType(button: NSButton){
        switch button.tag {
        case 0:
            selectedAmmoType = AmmoType.Battery;
            print("0")
            updatePlayerConsole();
            break;
        case 1:
            selectedAmmoType = AmmoType.Rocket;
            print("1")
            updatePlayerConsole();
            break
        case 2:
            selectedAmmoType = AmmoType.Laser;
            print("2")
            updatePlayerConsole();
            break
        case 3:
            selectedAmmoType = AmmoType.Nuclear;
            print("3")
            updatePlayerConsole();
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
    
    func placeComputerShip(button: NSButton, _shiptype: ShipType) -> Bool {
        let column: Int = button.tag % Game.FieldSize;
        let row: Int = button.tag / Game.FieldSize;
        let randomOrientation = (TechUnits.random(a: 126)%3)%2==0 ? ShipDirection.Horizontal : ShipDirection.Vertical;
        
        print("[Row:\(row): Column:\(column)]")
        print("Button.Tag = \(button.tag)")
        
        if Game.numberOfComputerShipsLeftToPlace() > 0 {
            switch _shiptype {
                
            case .Fighter1:
                
                if (Game.numberOfComputerFigthers1 > 0 && Game.computerField[button.tag] == .Space) {
                    //1. change button title:
                    //TechUnits.setButtonProporties(button: button, _title: "F", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.1, _bgC_green: 0.4, _bgC_blue: 0.4, _bgC_alpha: 0.7, _fontSize: 18)
                    
                    //2. add ship to ships array of player
                    Game.computer.fighters.append(Ship(_type: .Fighter1, _Xpos: column, _Ypos: row, _direction: randomOrientation, _pointType: .Fighter));
                    
                    //3. add ship at correct position in array of hitboxes
                    Game.computerField[button.tag] = Hitbox.Fighter;
                    
                    //4. count ships placed
                    Game.numberOfComputerFigthers1 -= 1;
                    
                    print("Fighter placed at R:\(row) C:\(column)\n");
                    
                } else {
                    
                    print("Number of Fighters reached maximum or there is another ship on this field!\n");
                    return false;
                    
                }
                
                break;
                
            case ShipType.Hunter2:
                
                var canBePlaced = true;
                var item: Int;
                for i in 0...1 {
                    if (randomOrientation == .Vertical) {
                        item = (row + i) * Game.FieldSize + column;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.computerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                    if (randomOrientation == .Horizontal) {
                        item = (row) * Game.FieldSize + column + i;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.computerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                            if ((i > 0) && (item % Game.FieldSize == 0)) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                }
                
                if (Game.numberOfComputerHunters2 > 0 && canBePlaced == true) {
                    
                    //1. change button title:
                    //TechUnits.setButtonProporties(button: button, _title: "H", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.2, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                    Game.computerField[button.tag] = Hitbox.HunterPart;
                    
                    if randomOrientation == .Vertical {
                        
                        let tag = (row + 1) * Game.FieldSize + column;
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "H", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.2, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.HunterPart;
                    }
                    if randomOrientation == .Horizontal {
                        
                        let tag = row * Game.FieldSize + column + 1;
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "H", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.2, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.HunterPart;
                    }
                    
                    //2. add ship to ships array of player
                    Game.computer.hunters.append(Ship(_type: .Hunter2, _Xpos: column, _Ypos: row, _direction: randomOrientation, _pointType: .HunterPart));
                    
                    //3. add ship at correct position in array of hitboxes
                    // it's above in point 1. inside each other "if" statement
                    
                    //4. count ships placed
                    Game.numberOfComputerHunters2 -= 1;
                    
                    print("Hunter placed at R:\(row) C:\(column)\n");
                    
                } else {
                    
                    print("Number of Hunters reached maximum!\n");
                    return false;
                }
                
                break;
                
            case ShipType.Cruiser3:
                
                var canBePlaced = true;
                var item: Int;
                for i in 0...2 {
                    if (randomOrientation == .Vertical) {
                        item = (row + i) * Game.FieldSize + column;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.computerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                    if (randomOrientation == .Horizontal) {
                        item = (row) * Game.FieldSize + column + i;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.computerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                            if ((i > 0) && (item % Game.FieldSize == 0)) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                }
                
                if (Game.numberOfComputerCruisers3 > 0 && canBePlaced == true) {
                    
                    //1. change button title:
                    //TechUnits.setButtonProporties(button: button, _title: "C", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.5, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                    Game.computerField[button.tag] = Hitbox.CruiserPart;
                    
                    if randomOrientation == .Vertical {
                        var tag = (row + 1) * Game.FieldSize + column;
                        
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "C", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.5, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.CruiserPart;
                        
                        tag = (row + 2) * Game.FieldSize + column;
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "C", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.5, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.CruiserPart;
                    }
                    if randomOrientation == .Horizontal {
                        var tag = row * Game.FieldSize + column + 1;
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "C", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.5, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.CruiserPart;
                        
                        tag = row * Game.FieldSize + column + 2;
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "C", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.5, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.CruiserPart;
                    }
                    
                    //2. add ship to ships array of player
                    Game.computer.cruisers.append(Ship(_type: .Cruiser3, _Xpos: column, _Ypos: row, _direction: randomOrientation, _pointType: .CruiserPart));
                    
                    //3. add ship at correct position in array of hitboxes
                    // it's above in point 1. inside each other "if" statement
                    
                    //4. count ships placed
                    Game.numberOfComputerCruisers3 -= 1;
                    
                    print("Cruiser placed at R:\(row) C:\(column)\n");
                    
                } else {
                    
                    print("Number of Cruisers reached maximum!\n");
                    return false;
                }
                
                break;
                
            case ShipType.Battleship4:
                
                var canBePlaced = true;
                var item: Int;
                for i in 0...3 {
                    if (randomOrientation == .Vertical) {
                        item = (row + i) * Game.FieldSize + column;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.computerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                    if (randomOrientation == .Horizontal) {
                        item = (row) * Game.FieldSize + column + i;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.computerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                            if ((i > 0) && (item % Game.FieldSize == 0)) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                }
                
                if (Game.numberOfComputerBattleships4 > 0 && canBePlaced == true) {
                    
                    //1. change button title:
                    //TechUnits.setButtonProporties(button: button, _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                    Game.computerField[row*Game.FieldSize+column] = Hitbox.BattleshipPart;
                    
                    if randomOrientation == .Vertical {
                        
                        var tag = (row + 1) * Game.FieldSize + column;
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.BattleshipPart;
                        
                        tag = (row + 2) * Game.FieldSize + column;
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.BattleshipPart;
                        
                        tag = (row + 3) * Game.FieldSize + column;
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.BattleshipPart;
                    }
                    if randomOrientation == .Horizontal {
                        var tag = row * Game.FieldSize + column + 1;
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.BattleshipPart;
                        
                        tag = row * Game.FieldSize + column + 2;
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.BattleshipPart;
                        
                        tag = row * Game.FieldSize + column + 3;
                        
                        //TechUnits.setButtonProporties(button: computerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.computerField[tag] = Hitbox.BattleshipPart;
                    }
                    
                    //2. add ship to ships array of player
                    Game.computer.battleships.append(Ship(_type: .Battleship4, _Xpos: column, _Ypos: row, _direction: randomOrientation, _pointType: .BattleshipPart));
                    
                    //3. add ship at correct position in array of hitboxes
                    // it's above in point 1. inside each other "if" statement
                    
                    //4. count ships placed
                    Game.numberOfComputerBattleships4 -= 1;
                    
                    print("Battleship placed at R:\(row) C:\(column)\n");
                    
                } else {
                    
                    print("Number of Battleships reached maximum!\n");
                    return false;
                }
                
                break;
                
            default:
                print("Error, no ship to place");
                return false;
            }
        }
        if (Game.numberOfPlayerShipsLeftToPlace() == 0) {
            Game.state = GameState.PlaceComputerShips;
        }
        return true;
    }
    
    func placeShip(button: NSButton) {
        let column: Int = button.tag % Game.FieldSize;
        let row: Int = button.tag / Game.FieldSize;
        
        print("[Row:\(row): Column:\(column)]")
        print("Button.Tag = \(button.tag)")
        
        if Game.numberOfPlayerShipsLeftToPlace() > 0 {
            switch selectedShipToAdding {
                
            case ShipType.Fighter1:
                
                if (Game.numberOfPlayerFigthers1 > 0 && Game.playerField[button.tag] == .Space) {
                    //1. change button title:
                    TechUnits.setButtonProporties(button: button, _title: "F", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.1, _bgC_green: 0.4, _bgC_blue: 0.4, _bgC_alpha: 0.7, _fontSize: 18)
                    
                    //2. add ship to ships array of player
                    Game.player.fighters.append(Ship(_type: .Fighter1, _Xpos: column, _Ypos: row, _direction: selectedShipOrientation, _pointType: .Fighter));
                    
                    //3. add ship at correct position in array of hitboxes
                    let tag = (row) * Game.FieldSize + column;
                    Game.playerField[tag] = Hitbox.Fighter;
                    
                    //4. count ships placed
                    Game.numberOfPlayerFigthers1 -= 1;
                    
                    print("Fighter placed at R:\(row) C:\(column)\n");
                    
                } else {
                    
                    print("Number of Fighters reached maximum or there is another ship on this field!\n");
                    
                }
                
                break;
                
            case ShipType.Hunter2:
                
                var canBePlaced = true;
                var item: Int;
                for i in 0...1 {
                    if (selectedShipOrientation == .Vertical) {
                        item = (row + i) * Game.FieldSize + column;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.playerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                    if (selectedShipOrientation == .Horizontal) {
                        item = (row) * Game.FieldSize + column + i;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.playerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                            if ((i > 0) && (item % Game.FieldSize == 0)) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                }
                
                if (Game.numberOfPlayerHunters2 > 0 && canBePlaced == true) {
                    
                    //1. change button title:
                    TechUnits.setButtonProporties(button: button, _title: "H", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.2, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                    Game.playerField[row*Game.FieldSize+column] = Hitbox.HunterPart;
                    
                    if selectedShipOrientation == .Vertical {
                        
                        let tag = (row + 1) * Game.FieldSize + column;
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "H", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.2, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.HunterPart;
                    }
                    if selectedShipOrientation == .Horizontal {
                        
                        let tag = row * Game.FieldSize + column + 1;
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "H", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.2, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.HunterPart;
                    }
                    
                    //2. add ship to ships array of player
                    Game.player.hunters.append(Ship(_type: .Hunter2, _Xpos: column, _Ypos: row, _direction: selectedShipOrientation, _pointType: .HunterPart));
                    
                    //3. add ship at correct position in array of hitboxes
                    // it's above in point 1. inside each other "if" statement
                    
                    //4. count ships placed
                    Game.numberOfPlayerHunters2 -= 1;
                    
                    print("Hunter placed at R:\(row) C:\(column)\n");
                    
                } else {
                    
                    print("Number of Hunters reached maximum!\n");
                }
                
                break;
                
            case ShipType.Cruiser3:
                
                var canBePlaced = true;
                var item: Int;
                for i in 0...2 {
                    if (selectedShipOrientation == .Vertical) {
                        item = (row + i) * Game.FieldSize + column;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.playerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                    if (selectedShipOrientation == .Horizontal) {
                        item = (row) * Game.FieldSize + column + i;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.playerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                            if ((i > 0) && (item % Game.FieldSize == 0)) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                }
                
                if (Game.numberOfPlayerCruisers3 > 0 && canBePlaced == true) {
                    
                    //1. change button title:
                    TechUnits.setButtonProporties(button: button, _title: "C", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.5, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                    Game.playerField[row*Game.FieldSize+column] = Hitbox.CruiserPart;
                    
                    if selectedShipOrientation == .Vertical {
                        var tag = (row + 1) * Game.FieldSize + column;
                        
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "C", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.5, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.CruiserPart;
                        
                        tag = (row + 2) * Game.FieldSize + column;
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "C", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.5, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.CruiserPart;
                    }
                    if selectedShipOrientation == .Horizontal {
                        var tag = row * Game.FieldSize + column + 1;
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "C", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.5, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.HunterPart;
                        
                        tag = row * Game.FieldSize + column + 2;
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "C", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.5, _bgC_green: 0.3, _bgC_blue: 0.6, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.CruiserPart;
                    }
                    
                    //2. add ship to ships array of player
                    Game.player.cruisers.append(Ship(_type: .Cruiser3, _Xpos: column, _Ypos: row, _direction: selectedShipOrientation, _pointType: .CruiserPart));
                    
                    //3. add ship at correct position in array of hitboxes
                    // it's above in point 1. inside each other "if" statement
                    
                    //4. count ships placed
                    Game.numberOfPlayerCruisers3 -= 1;
                    
                    print("Cruiser placed at R:\(row) C:\(column)\n");
                    
                } else {
                    
                    print("Number of Cruisers reached maximum!\n");
                }
                
                break;
                
            case ShipType.Battleship4:
                
                var canBePlaced = true;
                var item: Int;
                for i in 0...3 {
                    if (selectedShipOrientation == .Vertical) {
                        item = (row + i) * Game.FieldSize + column;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.playerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                    if (selectedShipOrientation == .Horizontal) {
                        item = (row) * Game.FieldSize + column + i;
                        if (item > Game.FieldSize*Game.FieldSize-1) {
                            canBePlaced = false;
                            break;
                        } else {
                            if (Game.playerField[item] != .Space) {
                                canBePlaced = false;
                                break;
                            }
                            if ((i > 0) && (item % Game.FieldSize == 0)) {
                                canBePlaced = false;
                                break;
                            }
                        }
                    }
                }
                
                if (Game.numberOfPlayerBattleships4 > 0 && canBePlaced == true) {
                    
                    //1. change button title:
                    TechUnits.setButtonProporties(button: button, _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                    Game.playerField[row*Game.FieldSize+column] = Hitbox.BattleshipPart;
                    
                    if selectedShipOrientation == .Vertical {
                        
                        var tag = (row + 1) * Game.FieldSize + column;
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.BattleshipPart;
                        
                        tag = (row + 2) * Game.FieldSize + column;
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.BattleshipPart;
                        
                        tag = (row + 3) * Game.FieldSize + column;
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.BattleshipPart;
                    }
                    if selectedShipOrientation == .Horizontal {
                        var tag = row * Game.FieldSize + column + 1;
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.BattleshipPart;
                        
                        tag = row * Game.FieldSize + column + 2;
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.BattleshipPart;
                        
                        tag = row * Game.FieldSize + column + 3;
                        
                        TechUnits.setButtonProporties(button: playerButtonsField[tag], _title: "B", _butHue: 0.57, _butSaturation: 1, _butBrightness: 1, _butAlpha: 1, _bgC_red: 0.6, _bgC_green: 0.3, _bgC_blue: 0.1, _bgC_alpha: 0.7, _fontSize: 18)
                        
                        // add ship at correct position in array of hitboxes
                        Game.playerField[tag] = Hitbox.BattleshipPart;
                    }
                    
                    //2. add ship to ships array of player
                    Game.player.battleships.append(Ship(_type: .Battleship4, _Xpos: column, _Ypos: row, _direction: selectedShipOrientation, _pointType: .BattleshipPart));
                    
                    //3. add ship at correct position in array of hitboxes
                    // it's above in point 1. inside each other "if" statement
                    
                    //4. count ships placed
                    Game.numberOfPlayerBattleships4 -= 1;
                    
                    print("Battleship placed at R:\(row) C:\(column)\n");
                    
                } else {
                    
                    print("Number of Battleships reached maximum!\n");
                }
                
                break;
                
            default:
                print("Error, no ship to place");
                return;
            }
        }
        if (Game.numberOfPlayerShipsLeftToPlace() == 0) {
            Game.state = GameState.PlaceComputerShips;
        }
    }
    
    func computerShot() -> Bool {
        //select ammo type
        var shooted = false;
        var ammoSelected: AmmoType;
        if (Game.computer.ammo_Nuclear > 0) {
            ammoSelected = .Nuclear
        } else if (Game.computer.ammo_Laser > 0) {
            ammoSelected = .Laser
        } else if (Game.computer.ammo_Rockets > 0) {
            ammoSelected = .Rocket
        } else {
            ammoSelected = .Battery
        }
        
        // random button selecting:
        let randomTag = TechUnits.random(a: Game.FieldSize * Game.FieldSize)
        
        switch ammoSelected {
        case .Battery:
            if (Game.computer.ammo_Battery > 0) {
                //shooting!
                switch Game.playerField[randomTag] {
                case .Space:
                    playerButtonsField[randomTag].attributedTitle = NSMutableAttributedString(string: "💥", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 10), NSAttributedStringKey.paragraphStyle: pstyle])
                    Game.playerField[randomTag] = .SpaceExplosion;
                    shooted = true;
                    break;
                case .Fighter:
                    TechUnits.setButtonProporties(button: playerButtonsField[randomTag], _title: "xF", _butHue: 0, _butSaturation: 1, _butBrightness: 0.5, _butAlpha: 0.66, _bgC_red: 1, _bgC_green: 0.2, _bgC_blue: 0, _bgC_alpha: 0.66, _fontSize: 10)
                    let last = Game.player.fighters.count-1;
                    Game.playerField[randomTag] = .Fighter_Hit;
                    Game.player.fighters[last].healthPoints! -= 1;
                    if (Game.player.fighters[last].healthPoints == 0) {
                        _ = Game.player.fighters.popLast();
                    }
                    shooted = true;
                    break;
                case .HunterPart:
                    TechUnits.setButtonProporties(button: playerButtonsField[randomTag], _title: "xH", _butHue: 0, _butSaturation: 1, _butBrightness: 0.5, _butAlpha: 0.66, _bgC_red: 1, _bgC_green: 0.2, _bgC_blue: 0, _bgC_alpha: 0.66, _fontSize: 10)
                    let last = Game.player.hunters.count-1;
                    Game.playerField[randomTag] = .HunterPart_Hit;
                    Game.player.hunters[last].healthPoints! -= 1;
                    if (Game.player.hunters[last].healthPoints == 0) {
                        _ = Game.player.hunters.popLast();
                    }
                    shooted = true;
                    break;
                case .CruiserPart:
                    TechUnits.setButtonProporties(button: playerButtonsField[randomTag], _title: "xC", _butHue: 0, _butSaturation: 1, _butBrightness: 0.5, _butAlpha: 0.66, _bgC_red: 1, _bgC_green: 0.2, _bgC_blue: 0, _bgC_alpha: 0.66, _fontSize: 10)
                    let last = Game.player.cruisers.count-1;
                    Game.playerField[randomTag] = .CruiserPart_Hit;
                    Game.player.cruisers[last].healthPoints! -= 1;
                    if (Game.player.cruisers[last].healthPoints == 0) {
                        _ = Game.player.cruisers.popLast();
                    }
                    shooted = true;
                    break;
                case .BattleshipPart:
                    TechUnits.setButtonProporties(button: playerButtonsField[randomTag], _title: "xB", _butHue: 0, _butSaturation: 1, _butBrightness: 0.5, _butAlpha: 0.66, _bgC_red: 1, _bgC_green: 0.2, _bgC_blue: 0, _bgC_alpha: 0.66, _fontSize: 10)
                    let last = Game.player.battleships.count-1;
                    Game.playerField[randomTag] = .BattleshipPart_Hit;
                    Game.player.battleships[last].healthPoints! -= 1;
                    if (Game.player.battleships[last].healthPoints == 0) {
                        _ = Game.player.battleships.popLast();
                    }
                    shooted = true;
                    break;
                default:
                    return false;
                }
                shooted = true;
            } else {
                shooted = false;
            }
            if (shooted) {
                Game.computer.ammo_Battery -= 1;
                return true;
            }
            break;
        case .Rocket:
            
            if (shooted) {
                Game.computer.ammo_Rockets -= 1;
                return true;
            }
            break
        case .Laser:
            
            if (shooted) {
                Game.computer.ammo_Laser -= 1;
                return true;
            }
            break
        case .Nuclear:
            
            if (shooted) {
                Game.computer.ammo_Nuclear -= 1;
                return true;
            }
            break
        default:
            return false;
        }
        
        return false;
    }
    
    func playerShot(button: NSButton) {
        var shooted = false
        switch selectedAmmoType {
        case .Battery:
            if (Game.player.ammo_Battery > 0) {
                switch Game.computerField[button.tag] {
                case Hitbox.Space:
                    button.attributedTitle = NSMutableAttributedString(string: "💥", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 10), NSAttributedStringKey.paragraphStyle: pstyle])
                    button.isEnabled = false;
                    Game.computerField[button.tag] = .SpaceExplosion;
                    updatePlayerConsole();
                    shooted = true;
                    break;
                case Hitbox.Fighter:
                    TechUnits.setButtonProporties(button: button, _title: "🔸", _butHue: 0, _butSaturation: 1, _butBrightness: 0.5, _butAlpha: 0.66, _bgC_red: 1, _bgC_green: 0.2, _bgC_blue: 0, _bgC_alpha: 0.66, _fontSize: 10)
                    button.isEnabled = false;
                    let last = Game.computer.fighters.count-1;
                    Game.computerField[button.tag] = .Fighter_Hit;
                    Game.computer.fighters[last].healthPoints! -= 1;
                    if (Game.computer.fighters[last].healthPoints == 0) {
                        _ = Game.computer.fighters.popLast();
                        playerConsoleWrite(text: "\t\tFIGHTER DESTROYED!", to: playerConsole)
                        shipDestroyed = .Fighter1;
                    } else {updatePlayerConsole();}
                    shooted = true;
                    break;
                case .HunterPart:
                    TechUnits.setButtonProporties(button: button, _title: "🔸", _butHue: 0, _butSaturation: 1, _butBrightness: 0.5, _butAlpha: 0.66, _bgC_red: 1, _bgC_green: 0.2, _bgC_blue: 0, _bgC_alpha: 0.66, _fontSize: 10)
                    button.isEnabled = false;
                    let last = Game.computer.hunters.count-1;
                    Game.computerField[button.tag] = .HunterPart_Hit;
                    Game.computer.hunters[last].healthPoints! -= 1;
                    if (Game.computer.hunters[last].healthPoints == 0) {
                        _ = Game.computer.hunters.popLast();
                        playerConsoleWrite(text: "\t\tHUNTER DESTROYED!", to: playerConsole)
                        shipDestroyed = .Hunter2;
                    } else {updatePlayerConsole();}
                    shooted = true;
                    break;
                case .CruiserPart:
                    TechUnits.setButtonProporties(button: button, _title: "🔸", _butHue: 0, _butSaturation: 1, _butBrightness: 0.5, _butAlpha: 0.66, _bgC_red: 1, _bgC_green: 0.2, _bgC_blue: 0, _bgC_alpha: 0.66, _fontSize: 10)
                    button.isEnabled = false;
                    let last = Game.computer.cruisers.count-1;
                    Game.computerField[button.tag] = .CruiserPart_Hit;
                    Game.computer.cruisers[last].healthPoints! -= 1;
                    if (Game.computer.cruisers[last].healthPoints == 0) {
                        _ = Game.computer.cruisers.popLast();
                        playerConsoleWrite(text: "\t\tCRUISER DESTROYED!", to: playerConsole)
                        shipDestroyed = .Cruiser3;
                    } else {updatePlayerConsole();}
                    shooted = true;
                    break;
                case .BattleshipPart:
                    TechUnits.setButtonProporties(button: button, _title: "🔸", _butHue: 0, _butSaturation: 1, _butBrightness: 0.5, _butAlpha: 0.66, _bgC_red: 1, _bgC_green: 0.2, _bgC_blue: 0, _bgC_alpha: 0.66, _fontSize: 10)
                    button.isEnabled = false;
                    let last = Game.computer.battleships.count-1;
                    Game.computerField[button.tag] = .BattleshipPart_Hit;
                    Game.computer.battleships[last].healthPoints! -= 1;
                    if (Game.computer.battleships[last].healthPoints == 0) {
                        _ = Game.computer.battleships.popLast();
                        playerConsoleWrite(text: "\t\tBATTLESHIP DESTROYED!", to: playerConsole)
                        shipDestroyed = .Battleship4;
                    } else {updatePlayerConsole();}
                    shooted = true;
                    break;
                default:
                    return;
                }
            }
            if (shooted) {Game.player.ammo_Battery -= 1}
            break;
        case .Rocket:
            if (Game.player.ammo_Rockets > 0) {
                //rocket shot
            }
            if (shooted) {Game.player.ammo_Rockets -= 1}
            break;
        case .Laser:
            if (Game.player.ammo_Laser > 0) {
                //laser shot
            }
            if (shooted) {Game.player.ammo_Laser -= 1}
            break;
        case .Nuclear:
            if (Game.player.ammo_Nuclear > 0) {
                //nuclear shot
            }
            if (shooted) {Game.player.ammo_Nuclear -= 1}
            break;
        case .none:
            break;
        }
        if (Game.computer.getNumberOfShips() == 0) {
            Game.state = GameState.Win_NoShips
        }
    }
    
}
