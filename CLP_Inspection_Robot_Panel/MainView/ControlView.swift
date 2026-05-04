import SwiftUI
import Charts
import os

struct ControlView: View {
    @State var viewModel = ViewModel()
    @EnvironmentObject var settings: SettingsHandler
    @EnvironmentObject var robotStatus: RobotStatusObject
    @EnvironmentObject var launchPlatformStatus: LaunchPlatformStatusObject
    @EnvironmentObject var autoStatus: AutomationStatusObject
    
    let notBlack = Color(red: 24/335, green: 24/335, blue: 24/335)
    var compact: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.show {
                controlHeader
                
                HStack {
                    VStack {
                        if !compact {
                            LEDControlView()
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 49.0)
                                        .fill(.ultraThinMaterial)
                                        .stroke(.white)
                                )
                                .padding()
                            Spacer()
                        }
                        
                        if compact {
                            compactView
                        } else {
                            expandedRelaysView
                        }
                    }
                    
                    if !compact {
                        expandedMainView
                    }
                }
            }
        }
        .onAppear {
            viewModel.show = true
            Logger().info("Control View appeared")
        }
        .onDisappear {
            viewModel.show = false
            Logger().info("Control View disappeared")
        }
    }
}

// MARK: - Subviews
extension ControlView {
    
    private var controlHeader: some View {
        Button(action: {
            withAnimation {
                viewModel.webShow.toggle()
            }
        }) {
            Label("Control", systemImage: "macstudio.fill")
                .padding()
                .padding(.vertical)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 33.0).fill(robotStatus.status.connected ? .green : .red))
        }
        .buttonStyle(.plain)
    }
    
    private var rightAdjustmentView: some View {
        VStack {
            let value = Int(self.viewModel.r * 100)
            Text(String(value))
                .contentTransition(.numericText(countsDown: true))
            VerticalSlider(value: self.$viewModel.r, referenceValue: nil, onEnd: {
                self.viewModel.rightPower = value
            }, icon: { _ in
                Image(systemName: "r.circle.fill")
            })
            .padding(.all, compact ? 0 : nil)
        }
        .frame(maxHeight: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 33.0).fill(.ultraThinMaterial))
    }
    
    private var leftAdjustmentView: some View {
        VStack {
            let value = Int(self.viewModel.l * 100)
            Text(String(value))
                .contentTransition(.numericText(countsDown: true))
            VerticalSlider(value: self.$viewModel.l, referenceValue: nil, onEnd: {
                self.viewModel.leftPower = value
            }, icon: { _ in
                Image(systemName: "l.circle.fill")
            })
            .padding(.all, compact ? 0 : nil)
        }
        .frame(maxHeight: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 33.0).fill(.ultraThinMaterial))
    }
    
    private var setpointMeterView: some View {
        HStack {
            Text(String(format: "%05.1f", launchPlatformStatus.status.setpoint))
                .padding()
        }
    }
    
    private var connectIconView: some View {
        Button(action: {
            withAnimation {
                viewModel.popup.toggle()
            }
        }) {
            Text(String(format: "%05.1f", launchPlatformStatus.status.angle))
                .padding()
                .foregroundStyle(launchPlatformStatus.status.connected ? .green : .red)
                .background(Capsule().fill(.ultraThinMaterial))
        }
        .popover(isPresented: $viewModel.popup) {
            popoverContentView
        }
    }
    
    private var popoverContentView: some View {
        VStack {
            HStack {
                Text(String(format: "robot: %03d", robotStatus.status.roll_angle))
                    .padding()
            }
            HStack {
                Text("setpoint:")
                setpointMeterView
            }
            HStack {
                Button(action: {
                    viewModel.angleTarget -= 0.1
                }) {
                    Image(systemName: "minus.circle.fill")
                        .padding()
                }
                Button(action: {
                    sendCommand()
                }) {
                    Text(String(format: "%05.1f", viewModel.angleTarget))
                        .padding()
                        .foregroundStyle(.green)
                        .onAppear {
                            viewModel.angleTarget = launchPlatformStatus.status.angle
                        }
                }
                Button(action: {
                    viewModel.angleTarget += 0.1
                }) {
                    Image(systemName: "plus.circle.fill")
                        .padding()
                }
            }
            .buttonStyle(.plain)
            .presentationCompactAdaptation(.popover)
        }
    }
    
    private func relayButton(for index: Int) -> some View {
        Button(action: {
            RobotStatusObject.setRelay(ip: settings.ip, port: settings.port, relay: index - 1)
        }) {
            let s = robotStatus.status.relay
            let strIndex = s.index(s.startIndex, offsetBy: index - 1)
            let state = String(robotStatus.status.relay[strIndex])
            
            Image(systemName: "\(index).circle.fill")
                .padding()
                .tint(.primary)
                .background(Circle().fill(state == "1" ? .green : notBlack)) // Note: index 7,8 originally used orange, simplified here for readability if intended or you can separate them
        }
        .keyboardShortcut(KeyEquivalent(Character("\(index)")), modifiers: [])
    }
    
    private func sensorRelayButton(for index: Int) -> some View {
        Button(action: {
            RobotStatusObject.setRelay(ip: settings.ip, port: settings.port, relay: index - 1)
        }) {
            let s = robotStatus.status.relay
            let strIndex = s.index(s.startIndex, offsetBy: index - 1)
            let state = String(robotStatus.status.relay[strIndex])
            
            Image(systemName: "\(index).circle.fill")
                .padding()
                .tint(.primary)
                .background(Circle().fill(state == "1" ? .orange : notBlack))
        }
        .keyboardShortcut(KeyEquivalent(Character("\(index)")), modifiers: [])
    }
    
    private var expandedRelaysView: some View {
        VStack {
            ForEach(7...8, id: \.self) { sensorRelayButton(for: $0) }
            ForEach(1...3, id: \.self) { relayButton(for: $0) }
            ForEach(4...6, id: \.self) { relayButton(for: $0) }
        }
        .padding()
        .background(Capsule().fill(.ultraThinMaterial))
    }
    
    private var compactView: some View {
        VStack {
            VStack {
                HStack {
                    ForEach(1...4, id: \.self) { relayButton(for: $0) }
                }
                HStack {
                    ForEach(5...8, id: \.self) { relayButton(for: $0) }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial))
            
            HStack {
                connectIconView
                EL_CID_TriggerButton()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial))
            .frame(maxWidth: .infinity)
            
            HStack {
                leftAdjustmentView
                Spacer()
                AutoControlView(leftPower: $viewModel.leftPower, rightPower: $viewModel.rightPower, tight: false)
                Spacer()
                rightAdjustmentView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var expandedMainView: some View {
        Group {
            Divider().padding()
            
            VStack {
                HStack {
                    TabView {
                        VStack {
                            Group {
                                HStack {
                                    VStack {
                                        AutoMenu(content: {
                                            Label(String(format: "%05d", robotStatus.status.lazer), systemImage: "ruler.fill")
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .contentTransition(.numericText(countsDown: true))
                                                .foregroundStyle(Constants.notBlack)
                                                .background(RoundedRectangle(cornerRadius: 25.0).fill(Constants.offWhite))
                                        }).buttonStyle(.plain)
                                        
                                        PressureView(enabled: true)
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial))
                                    }
                                    .padding([.horizontal, .top])
                                    
                                    VStack {
                                        HStack {
                                            leftAdjustmentView
                                            Spacer()
                                            rightAdjustmentView
                                        }
                                        .padding([.horizontal, .top])
                                    }
                                }
                            }
                            
                            Group {
                                HStack {
                                    Button(action: {
                                        withAnimation { viewModel.showHints.toggle() }
                                    }) {
                                        Image(systemName: "lightbulb.fill")
                                            .padding()
                                            .background(Circle().fill(viewModel.showHints ? .yellow : Constants.notBlack))
                                    }
                                    .buttonStyle(.plain)
                                    
                                    AutoMenu(content: {
                                        Text(autoStatus.autoMode.rawValue)
                                            .lineLimit(1)
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 33.0).fill(.ultraThickMaterial))
                                            .padding()
                                    }).buttonStyle(.plain)
                                    
                                    HStack {
                                        setpointMeterView
                                        connectIconView
                                        EL_CID_TriggerButton()
                                    }
                                    .padding()
                                    .background(Capsule().fill(.ultraThinMaterial))
                                }
                            }
                        }
                    }
                    .tabViewStyle(.page)
                }
                
                HStack {
                    if viewModel.showHints {
                        VStack {
                            Image("Robot_top")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(maxHeight: .infinity)
                        .padding()
                    }
                    
                    FBGView()
                }
                .background(RoundedRectangle(cornerRadius: 33).stroke(.white))
                .padding()
                
            }
            .frame(maxHeight: .infinity)
            
            Divider().padding()
            
            VStack {
                let data = robotStatus.status.tof
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Label(String(format: "%03d", robotStatus.status.roll_angle), systemImage: "arrow.trianglehead.clockwise")
                            .padding()
                            .font(.title)
                            .contentTransition(.numericText(countsDown: true))
                            .background(RoundedRectangle(cornerRadius: 33.0).fill(.ultraThickMaterial))
                        
                        ForEach(Array(data[0...17].enumerated()), id: \.0) { idx, value in
                            Label(String(format: "%03d", value), systemImage: "\(idx+1).circle.fill")
                                .foregroundColor(value == 153 ? .red : Constants.offWhite)
                                .padding()
                                .font(.title)
                                .contentTransition(.numericText(countsDown: true))
                                .background(RoundedRectangle(cornerRadius: 33.0).fill(.ultraThickMaterial))
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                
                Spacer()
                
                AutoControlView(leftPower: self.$viewModel.leftPower, rightPower: self.$viewModel.rightPower)
            }
        }
    }
}

// MARK: - ViewModel & Actions
extension ControlView {
    @Observable
    class ViewModel {
        var l = 0.1
        var r = 0.1
        var leftPower = 10
        var rightPower = 10
        var popup = false
        var angleTarget: Float = 0.0
        var webShow = false
        var showHints = true
        var show = false
    }
    
    func sendCommand() {
        LaunchPlatformStatusObject.RotatePlatform(
            ip: settings.ip,
            port: settings.port,
            value: .degrees(Double(viewModel.angleTarget).truncatingRemainder(dividingBy: 360))
        )
    }
}
