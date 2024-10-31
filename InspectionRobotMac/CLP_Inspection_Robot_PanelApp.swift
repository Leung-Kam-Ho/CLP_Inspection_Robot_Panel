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
    let contentMinSize = CGSize(width: 950, height: 1000)
    var body: some Scene {
        WindowGroup {
            
            GeometryReader{ geo in
                let width = geo.size.width
                
                HStack{
                    if width > contentMinSize.width * 2{
                        Camera_WebView()
                            .frame(width: width - contentMinSize.width)
                    }
                    ContentView()
                        .frame(minWidth: contentMinSize.width, minHeight: contentMinSize.height)
//                        .overlay(content: {
//                            Text("\(geo.size)")
//                        })
                }
                .background(Image("Watermark"))
                .font(.title2)
                
                .environmentObject(station)
            }
        }
        .defaultSize(contentMinSize)
    }
}
