import SwiftUI
import Charts
import os

struct ToFChartView: View {
    @EnvironmentObject var robotStatus: RobotStatusObject
    @State private var show = false
    
    var body: some View {
        GroupBox("ToF Sensors") {
            Chart {
                if show{
                    ForEach(Array(robotStatus.status.tof.prefix(14).enumerated()), id: \.offset) { index, value in
                        BarMark(
                            x: .value("Sensor", index + 1),
                            y: .value("Distance", value)
                        )
                        .foregroundStyle(value == 153 ? .red : .blue)
                        
                        PointMark(
                            x: .value("Sensor", index + 1),
                            y: .value("Distance", value)
                        )
                        .foregroundStyle(.blue)
                        .annotation(position: .top) {
                            Text("\(value)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
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
            AxisMarks(values: .automatic) { value in
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
//        .padding()
//        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
    }
}

struct EL_CID_TriggerButton: View {
    @EnvironmentObject var elcidStatus : ElCidStatusObject
    @EnvironmentObject var settings: SettingsHandler
    var body: some View {
        Button(action:{
            ElCidStatusObject.setRelay(ip: settings.ip, port: settings.port, state: true)
        }){
            Text("EL-CID")
                .foregroundStyle(elcidStatus.status.connected ? (elcidStatus.status.relay_state == 0 ? .green : .orange ): .red)
                .padding().background(Capsule().fill(Constants.notBlack))
                .onLongPressGesture(minimumDuration: 1,perform: {
                    ElCidStatusObject.setRelay(ip: settings.ip, port: settings.port, state: false)
                    
                    Logger().info("Reset EL-CID")
                })
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable var settings = SettingsHandler()
    @Previewable var elcidStatus = ElCidStatusObject()
    @Previewable var robotStatus = RobotStatusObject()
    
    VStack {
        ToFChartView()
            .environmentObject(robotStatus)
        EL_CID_TriggerButton()
            .environmentObject(settings)
            .environmentObject(elcidStatus)
    }
}
