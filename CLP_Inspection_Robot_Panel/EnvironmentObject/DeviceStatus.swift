//
//  DeviceStatus.swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 26/5/2025.
//

import Foundation


class RobotStatus: Codable, ObservableObject {
    var servo: [Int] = [1500, 1500, 1500, 1500]
    var relay: String = "00000000"
    var tof: [Int] = Array(repeating: 0, count: 18)
    var roll_angle: Int = 0
    var lazer: Int = 0
    var connected: Bool = false
}

class DigitalValve_Status: Codable, ObservableObject {
    var pressure: [Double] = [0, 0, 0, 0]
    var connected: Bool = false
}

class LaunchPlatformStatus: Codable, ObservableObject {
    var angle: Float = 1.0
    var relay: String = "00000000"
    var connected: Bool = false
    var setpoint: Float = 0
    var lazer: Int = 0
}

class AutomationStatus: Codable, ObservableObject {
    enum AutoMode_segment: String, CaseIterable {
        case Manual, Standing, Lauch, Baffle, Testing
    }
    var sequence_name: String = ""
    var mode: String = "Manual"
    var action_update: String = ""
    var action_name: String = ""
    var tree_ascii: String = ""
    var connected: Bool = false
}

class ElCidstatus: Codable, ObservableObject {
    var distance_per_click = 100
    var relay_state = 0
    var connected = false
}

