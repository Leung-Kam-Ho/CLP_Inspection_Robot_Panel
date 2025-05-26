//
//  CLP_Inspection_Robot_PanelApp.swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 14/7/2024.
//

import SwiftUI

@main
struct CLP_Inspection_Robot_PanelApp: App {
//    @StateObject var station = Station()
    @StateObject var settings = SettingsHandler()
    @StateObject var robotStatus = RobotStatusObject()
    @StateObject var launchPlatformStatus = LaunchPlatformStatusObject()
    @StateObject var automationStatus = AutomationStatusObject()
    @StateObject var elCidStatus = ElCidStatusObject()
    @StateObject var digitalValveStatus = DigitalValveStatusObject()
    
    private let contentMinSize = CGSize(width: 1300, height: 1000)
    
    var body: some Scene {
        WindowGroup {
            HStack {
//                ContentView()
                Spacer()
            }
            .background(Image("Watermark"))
            .font(.title2)
//            .environmentObject(station)
            .environmentObject(settings)
            .environmentObject(robotStatus)
            .environmentObject(launchPlatformStatus)
            .environmentObject(automationStatus)
            .environmentObject(elCidStatus)
            .environmentObject(digitalValveStatus)
        }
        .defaultSize(contentMinSize)
    }
}
