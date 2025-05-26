//
//  CLP_Inspection_Robot_PanelApp.swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 14/7/2024.
//

import SwiftUI

@main
struct CLP_Inspection_Robot_PanelApp: App {
    @StateObject var station = Station()
    var body: some Scene {
        WindowGroup {
            Spacer()
//            ContentView()
                .environmentObject(station)
                .background(Image("Watermark"))
//                .font(.system(size: bigEnough ? screen.size.width / 50 : screen.size.width/15, weight: .bold, design: .rounded))
                .font(.title2)
        }
    }
}
