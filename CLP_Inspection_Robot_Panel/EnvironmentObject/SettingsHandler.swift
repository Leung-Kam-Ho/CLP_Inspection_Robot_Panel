//
//  StorageHandler.swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 24/5/2025.
//

import Foundation
import os
import SwiftUI


class SettingsHandler : ObservableObject {
    
//    @AppStorage("ip_selection") var ip : String = "192.168.10.5"
    @AppStorage("camera_ip_selection") var cam_ip : String = "localhost"  

    init() {

    }
}
