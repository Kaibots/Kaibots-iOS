
//
//  Bluetooth.swift
//  Kaibots
//
//  Created by Yasu Flores on 3/26/17.
//  Copyright © 2017 Yasu Flores. All rights reserved.
//

import Foundation
import CoreBluetooth

class Bluetooth {
    func initBluetooth() {
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
}
