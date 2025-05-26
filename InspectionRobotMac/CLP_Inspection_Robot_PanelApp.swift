//
//  CLP_Inspection_Robot_PanelApp.swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 14/7/2024.
//

import SwiftUI
import os

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
                ContentView()
//                Spacer()
//                AutoView()
            }
            .background(Image("Watermark"))
            .onReceive(launchPlatformStatus.timer, perform: { _ in
                withAnimation {
                    
                    launchPlatformStatus.fetchStatus(ip: settings.ip, port: settings.port)
                }
                })
            .onReceive(automationStatus.timer, perform: {_ in
                Logger().info("Auto Fetching Status")
                withAnimation {
                    automationStatus.fetchStatus(ip: settings.ip, port: settings.port)
                }
                Logger().debug("Auto Status: \(automationStatus.status.connected)")
            })
            .onReceive(robotStatus.timer, perform: {_ in
                withAnimation {
                    robotStatus.fetchStatus(ip: settings.ip, port: settings.port)
                }
            })
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
