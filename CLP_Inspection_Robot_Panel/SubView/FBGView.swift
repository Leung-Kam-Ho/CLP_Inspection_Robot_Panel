//
//  ToFView.swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 14/7/1524.
//

import SwiftUI
import Charts

struct FBGView: View {
    @EnvironmentObject var fbgStatus : FBGStatusObject
    @EnvironmentObject var settings : SettingsHandler
    @State var show = false
    @State var hovered = false
    let columns = [
        GridItem(.adaptive(minimum: 150,maximum: 150))
    ]
    var body: some View {
        let data = fbgStatus.status.feet
        let data_b = fbgStatus.status.tank
        GroupBox("FBG Sensors") {
            Chart {
                if show{
                    ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                        
                        BarMark(
                            x: .value("Sensor", index + 1),
                            y: .value("Distance", value == 255 ? 0 : abs(value)),
                            width: 15
                        )
                        .annotation {
                            Image(systemName: "\(index+1).circle.fill")
                                .font(.caption)
                                .foregroundStyle(value == 255 ? .red : .blue)
                            
                        }
                        .foregroundStyle(value == 255 ? .red : .blue)
                        
                        
                    }
                    ForEach(Array(data_b.enumerated()), id: \.offset) { index, value in
                        BarMark(
                            x: .value("Sensor", index + 4 + 1),
                            y: .value("Distance", value == 255 ? 0 : abs(value)),
                            width: 15
                        )
                        .annotation {
                            Image(systemName: "\(index+1).circle.fill")
                                .font(.caption)
                                .foregroundStyle(value == 255 ? .red : .orange)
                        }
                        .foregroundStyle(value == 255 ? .red : .orange)
                    }
                }
            }
            .chartYScale(domain: 0...0.2)
            .chartBackground { chartProxy in
                Color.clear // Make the background transparent
            }
            .overlay(content: {
                if hovered{
                    HStack(){
                        ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                            
                            VStack{
                                Button(action:{
                                    FBGStatusObject.resetTarget(ip: settings.ip, port: settings.port, channel: "feet", value: index + 1)
                                }){
                                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
                                    .foregroundStyle(value == 255 ? .red : .blue)
                                }
                                Button(action:{
                                    FBGStatusObject.setTarget(ip: settings.ip, port: settings.port, channel: "feet", value: index + 1)
                                }){
                                    Image(systemName: "\(index+1).circle.fill")
                                    .foregroundStyle(value == 255 ? .red : .blue)
                                }
                            }
                            Spacer()
                            
                            
                        }
                        ForEach(Array(data_b.enumerated()), id: \.offset) { index, value in
                            VStack{
                                Button(action:{
                                    FBGStatusObject.resetTarget(ip: settings.ip, port: settings.port, channel: "tank", value: index + 1)
                                }){
                                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
                                    .foregroundStyle(value == 255 ? .red : .orange)
                                }
                                
                                Button(action:{
                                    FBGStatusObject.setTarget(ip: settings.ip, port: settings.port, channel: "tank", value: index + 1)
                                }){
                                    Image(systemName: "\(index+1).circle.fill")
                                }
                                .foregroundStyle(value == 255 ? .red : .orange)
                            }
                            if index + 1 != data_b.count{
                                Spacer()
                            }
                            
                        }
                    }
                    .padding()
                    .background(Capsule().stroke(Color.white).fill(Material.thin))
                    .padding()
                }
            })
        }
        .clipShape(RoundedRectangle(cornerRadius: 17))
        
        .onAppear(perform: {
            show = true
        })
        .onDisappear(perform: {
            show = false
        })
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 1)) { value in
                if let index = value.as(Int.self) {
                    AxisValueLabel {
                        Text("\(index)")
                            .font(.caption)
                    }
                }
            }
        }
        .onHover(perform: {state in
            hovered = state
        })
        
        .padding()
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial))

    }
}
