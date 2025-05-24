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
    @StateObject var settings = SettingsHandler()
    let contentMinSize = CGSize(width: 1300, height: 1000)
    var body: some Scene {
        WindowGroup {
            
                
                HStack{
                    ContentView()
                       
                }
                .background(Image("Watermark"))
                .font(.title2)
                
                .environmentObject(station)
                .environmentObject(settings)
            
        }
        .defaultSize(contentMinSize)
    }
}
