//
//  unit-functs.swift
//  World of Battleships
//
//  Created by Vaxen van Qualn'ryne on 26.01.2018.
//  Copyright © 2018 Vaxen van Qualn'ryne. All rights reserved.
//

import Foundation
import Cocoa

class TechUnits {
    
    //enable or disable selected battlefield
    static func turnOnOffBattlefield(ArrayWithButton: [NSButton], isON: Bool) -> Void {
        if(isON == false){
            for item in 0...ArrayWithButton.count - 1 {
                ArrayWithButton[item].isEnabled = false;
            }
        } else {
            for item in 0...ArrayWithButton.count - 1 {
                ArrayWithButton[item].isEnabled = true;
            }
        }
    }
    
    
    //types for generate buttons id dialogs
    enum Buttons{
        case OK
        case YesNo
    }
    
    // generate dialog box
    static func dialogOKCancel(question: String, text: String, buttons: Buttons) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        
        switch buttons {
        case .OK:
            alert.addButton(withTitle: "OK")
        case .YesNo:
            alert.addButton(withTitle: "Yes")
            alert.addButton(withTitle: "No")
        }
        
        
        return alert.runModal() == .alertFirstButtonReturn
    }
    
}
