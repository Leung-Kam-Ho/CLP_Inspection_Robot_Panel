//
//  SensorBarView.swift
//  Inspection Robot Control Panel
//
//  Created by Kam Ho Leung on 13/7/2024.
//

import Foundation
import SwiftUI

struct SensorBarView : View{
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    var body: some View {
        HStack{
            let tof = self.station.status.robot_status.tof
            let ToF_Show = (0..<self.station.status.robot_status.tof.count).map{$0}
            Label(String(format : "%04d",self.station.status.robot_status.lazer), systemImage: "ruler.fill")
                .padding()
                .font(.title)
                .contentTransition(.numericText(countsDown: true))
                .background(RoundedRectangle(cornerRadius: 25.0).fill(.red))
            TabView(content: {
                HStack{
                    ForEach(ToF_Show[0..<6], id:\.self){ idx in
                        Spacer()
                        Label(String(format : "%03d",tof[idx]), systemImage: "\(idx+1).circle.fill")
                            .padding()
                            .font(.title)
                            .contentTransition(.numericText(countsDown: true))
                            .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThickMaterial))
                        
                    }
                }
                HStack{
                    ForEach(ToF_Show[6..<12], id:\.self){ idx in
                        Spacer()
                        Label(String(format : "%03d",tof[idx]), systemImage: "\(idx+1).circle.fill")
                            .padding()
                            .font(.title)
                            .contentTransition(.numericText(countsDown: true))
                            .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThickMaterial))
                    }
                    
                }
                HStack{
                    ForEach(ToF_Show[12..<18], id:\.self){ idx in
                        Spacer()
                        Label(String(format : "%03d",tof[idx]), systemImage: "\(idx+1).circle.fill")
                            .padding()
                            .font(.title)
                            .contentTransition(.numericText(countsDown: true))
                            .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThickMaterial))
                    }
                    Picker("IP", selection: self.$station.ip, content: {
                        ForEach(Station.IP.allCases, id:\.self){ ip in
                            Text(ip.rawValue)
                                .padding()
                                .tag(ip.rawValue)
                        }.pickerStyle(.automatic)
                    }).font(.title)
                        .onChange(of: self.station.ip, { old, new in
                            let defaults = UserDefaults.standard
                            defaults.setValue(new, forKey: "IP")
                        })
                }
            }
            ).tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height : 70)
                
        }.padding()
            .lineLimit(1)
            .background(
                RoundedRectangle(cornerRadius: 25.0).fill(.ultraThinMaterial)
            )
        
    }
}


extension SensorBarView{
    enum Tof_Bar_Mode : CaseIterable{
        case ToF_1_6
        case ToF_7_12
        case ToF_13_18
        case IP
    }
    @Observable
    class ViewModel{
        var showToF = Tof_Bar_Mode.ToF_1_6
    }
}
