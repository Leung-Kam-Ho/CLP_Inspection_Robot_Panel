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
    @State var show = false
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
                            Button(action:{
                                print("FB \(index)")
                            }){
                                Image(systemName: "\(index+1).circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(value == 255 ? .red : .blue)
                            }
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
        .padding()
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial))

    }
}
