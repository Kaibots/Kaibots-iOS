//
//  ViewController.swift
//  Kaibots
//
//  Created by Yasu Flores on 3/10/17.
//  Copyright © 2017 Yasu Flores. All rights reserved.
//

import UIKit

class ListOfDevicesViewController: UIViewController {
    
    @IBAction func goBackHome(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
}

