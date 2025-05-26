//swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 26/5/2025.
//

import Foundation
import SwiftUI

// Base class for status objects to avoid code duplication
class BaseStatusObject<T>: ObservableObject where T: Decodable {
    @Published var status: T
    private let initialStatus: T
    private let networkManager = NetworkManager.shared
    private let statusRoute: String
    
    init(initialStatus: T, statusRoute: String) {
        self.initialStatus = initialStatus
        self.status = initialStatus
        self.statusRoute = statusRoute
    }
    
    func fetchStatus(ip: String, port: Int) {
        networkManager.getRequest(ip: ip, port: port, route: statusRoute) { (result: Result<T, Error>) in
            switch result {
            case .success(let status):
                DispatchQueue.main.async {
                    self.status = status
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    // Handle error on the main thread
                    print("Failed to fetch status: \(error.localizedDescription)")
                
                    self.status = self.initialStatus // Reset to initial status on error
                }
                print(error)
            }
        }
    }
    
    func sendCommand<V: Encodable>(ip: String, port: Int, route: String, data: V) {
        networkManager.postRequest(ip: ip, port: port, route: route, value: data) { success in
            DispatchQueue.main.async {
                if success {
                    print("POST request succeeded")
                } else {
                    print("POST request failed")
                }
            }
        }
    }
}

// Robot status object
class RobotStatusObject: BaseStatusObject<RobotStatus> {
    init() {
        super.init(initialStatus: RobotStatus(), statusRoute: "/robot_status")
    }
}

// Launch platform status object
class LaunchPlatformStatusObject: BaseStatusObject<LaunchPlatformStatus> {
    init() {
        super.init(initialStatus: LaunchPlatformStatus(), statusRoute: "/launch_platform_status")
    }
}

// Automation status object
class AutomationStatusObject: BaseStatusObject<AutomationStatus> {
    struct setModeCommand : Encodable {
        var mode : String
    }
    var timer = Timer.publish(every: Constants.SLOW_RATE, on: .main, in: .common).autoconnect()
    var autoMode: AutomationStatus.AutoMode_segment = .Manual
    init() {
        super.init(initialStatus: AutomationStatus(), statusRoute: "/auto_status")
    }
    func setMode(ip: String, port: Int, mode: String) {
        let command = setModeCommand(mode: mode)
        sendCommand(ip: ip, port: port, route: "/auto", data: command)
    }
}

// ElCid status object
class ElCidStatusObject: BaseStatusObject<ElCidstatus> {
    init() {
        super.init(initialStatus: ElCidstatus(), statusRoute: "/elcid_status")
    }
}

// Digital valve status object
class DigitalValveStatusObject: BaseStatusObject<DigitalValve_Status> {
    init() {
        super.init(initialStatus: DigitalValve_Status(), statusRoute: "/digital_valve_status")
    }
}
