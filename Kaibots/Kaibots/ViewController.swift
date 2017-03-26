//
//  ViewController.swift
//  Kaibots
//
//  Created by Yasu Flores on 3/10/17.
//  Copyright © 2017 Yasu Flores. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var scanButton: UIButton!
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showListOfDevicesSegue" {
            return true
        }
        return false
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}

}

