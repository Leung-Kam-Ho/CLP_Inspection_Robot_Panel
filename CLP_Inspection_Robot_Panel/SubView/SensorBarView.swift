//
//  SensorBarView.swift
//  Inspection Robot Control Panel
//
//  Created by Kam Ho Leung on 13/7/2024.
//

import Foundation
import SwiftUI

struct SensorBarView : View{

    @EnvironmentObject var robotStatus : RobotStatusObject
    var body: some View {
        HStack{
            LazerView()
            SensorTabsView()
            
        }.padding()
            .lineLimit(1)
            .background(
                RoundedRectangle(cornerRadius: 33.0).fill(.ultraThinMaterial)
            )
        
    }
}

struct LazerView : View{
    @EnvironmentObject var robotStatus : RobotStatusObject
    var body: some View {
        Label(String(format : "%05d",robotStatus.status.lazer), systemImage: "ruler.fill")
            .padding()
            .contentTransition(.numericText(countsDown: true))
            .background(RoundedRectangle(cornerRadius: 25.0).fill(.red))
    }
}


struct SensorTabsView : View{
    @EnvironmentObject var robotStatus : RobotStatusObject
    @State var selectedTab = 0
    var horizontal = true
    var body: some View {
        let tof = robotStatus.status.tof
        let ToF_Show = (0..<robotStatus.status.tof.count).map{$0}
        
        
        TabView(content: {
            
            HStack{
                RangeToFView(ToF: tof, idx: ToF_Show[0..<6])
            }
            HStack{
                RangeToFView(ToF: tof, idx: ToF_Show[6..<12])
            }
            HStack{
                RangeToFView(ToF: tof, idx: ToF_Show[12..<ToF_Show.count])
                
            }

        })
        .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height : 70, alignment: .center)
        
        
        
        
    }
}

struct RangeToFView : View{
    let ToF : [Int]
    let idx : ArraySlice<Int>
    var body: some View {
        ForEach(idx, id:\.self){ idx in
            Spacer()
            Label(String(format : "%03d",ToF[idx]), systemImage: "\(idx+1).circle.fill")
                .foregroundStyle(ToF[idx] == 153 ? .red : Constants.offWhite)
                .padding()
//                .font(.title)
                .contentTransition(.numericText(countsDown: true))
                .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThickMaterial))
            
        }
    }
}
