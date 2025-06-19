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
    @State private var isFullScreen = false
    @StateObject var settings = SettingsHandler()
    @StateObject var robotStatus = RobotStatusObject()
    @StateObject var launchPlatformStatus = LaunchPlatformStatusObject()
    @StateObject var automationStatus = AutomationStatusObject()
    @StateObject var elCidStatus = ElCidStatusObject()
    @StateObject var digitalValveStatus = DigitalValveStatusObject()
    @StateObject var fbgStatus = FBGStatusObject()
    
    private let contentMinSize = CGSize(width: 1300, height: 1000)
    
    var body: some Scene {
        
        WindowGroup {
            HStack {
                
                ContentView()
//                Spacer()
//                AutoView()
//                if window.is
                    
                Camera_WebView()
                    .clipShape(RoundedRectangle(cornerRadius: 33))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 49).fill(.ultraThinMaterial).stroke(.white))
                    .padding()
                
            }
            .background(Image("Watermark"))
            .onReceive(elCidStatus.timer, perform: { _ in
                Logger().info("elCid Fetching Status")
                elCidStatus.fetchStatus(ip: settings.ip, port: settings.port)
                
            })
            .onReceive(launchPlatformStatus.timer, perform: { _ in
                Logger().info("launchplatform Fetching Status")
                    
                    launchPlatformStatus.fetchStatus(ip: settings.ip, port: settings.port)
                
                })
            .onReceive(automationStatus.timer, perform: {_ in
                Logger().info("Auto Fetching Status")
                
                    automationStatus.fetchStatus(ip: settings.ip, port: settings.port)
                
            })
            .onReceive(robotStatus.timer, perform: {_ in
                Logger().info("robot Fetching Status")
                    robotStatus.fetchStatus(ip: settings.ip, port: settings.port)
                
            })
            .onReceive(digitalValveStatus.timer, perform: {_ in
                Logger().info("digital valve Fetching Status")
                digitalValveStatus.fetchStatus(ip: settings.ip, port: settings.port)
                
            })
            .onReceive(fbgStatus.timer, perform: {_ in
                Logger().info("FBG Fetching Status")
                fbgStatus.fetchStatus(ip: settings.ip, port: settings.port)
                
            })

            .font(.title2)
//            .environmentObject(station)
            .environmentObject(settings)
            .environmentObject(robotStatus)
            .environmentObject(launchPlatformStatus)
            .environmentObject(automationStatus)
            .environmentObject(elCidStatus)
            .environmentObject(digitalValveStatus)
            .environmentObject(fbgStatus)
        }
        .defaultSize(contentMinSize)
    }

}
