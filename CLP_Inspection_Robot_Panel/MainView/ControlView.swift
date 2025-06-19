import SwiftUI
import Charts
import os

struct ControlView: View {
    @State var viewModel = ViewModel()
    @EnvironmentObject var settings : SettingsHandler
    @EnvironmentObject var robotStatus : RobotStatusObject
    @EnvironmentObject var launchPlatformStatus : LaunchPlatformStatusObject
    @EnvironmentObject var autoStatus : AutomationStatusObject
//    @EnvironmentObject var elCidStatus : ElCidStatusObject
//    @EnvironmentObject var digitalValveStatus : DigitalValveStatusObject
    let notBlack = Color(red: 24/335, green: 24/335, blue: 24/335)
    var compact : Bool = false
    var body: some View {
        let R_Adj =
        VStack{
            let value = Int(self.viewModel.r * 100)
            Text(String(value))
                .contentTransition(.numericText(countsDown: true))
            VerticalSlider(value: self.$viewModel.r, referenceValue: nil, onEnd: {
                self.viewModel.rightPower = value
            } ,icon: { _ in
                return Image(systemName: "r.circle.fill")
            })
            .padding(.all,compact ? 0 : nil)
            
        }
        .frame(maxHeight: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 33.0).fill(.ultraThinMaterial))
        let L_Adj = VStack{
            let value = Int(self.viewModel.l * 100)
            Text(String(value))
                .contentTransition(.numericText(countsDown: true))
            VerticalSlider(value: self.$viewModel.l, referenceValue: nil, onEnd: {
                self.viewModel.leftPower = value
            } ,icon: { _ in
                return Image(systemName: "l.circle.fill")
            })
            .padding(.all,compact ? 0 : nil)
        }.frame(maxHeight: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 33.0).fill(.ultraThinMaterial))
        
        let SetpointMeter =
        HStack{
            Text(String(format:"%05.1f",launchPlatformStatus.status.setpoint))
                .padding()
//                .background(Capsule().fill(.ultraThickMaterial))
        }
        let connectIcon =
        Button(action:{
            withAnimation{
                viewModel.popup.toggle()
            }
        }){
            Text(String(format:"%05.1f",launchPlatformStatus.status.angle))
                .padding()
                .foregroundStyle( launchPlatformStatus.status.connected ? .green : .red)
                .background(Capsule().fill(.ultraThinMaterial))
        }.popover(isPresented: $viewModel.popup, content: {
            VStack{
                HStack{
                    Text(String(format: "robot: %03d",robotStatus.status.roll_angle))
                        .padding()
                }
                HStack{
                    Text("setpoint:")
                    SetpointMeter
                }
                HStack{
                    Button(action:{
                        viewModel.angleTarget -= 0.1
                    }){
                        Image(systemName: "minus.circle.fill")
                            .padding()
                        
                    }
                    Button(action:{
                        sendCommand()
                    }){
                        Text(String(format:"%05.1f",viewModel.angleTarget))
                            .padding()
                            .foregroundStyle(.green)
                            .onAppear{
                                viewModel.angleTarget = launchPlatformStatus.status.angle
                            }
                    }
                    Button(action:{
                        viewModel.angleTarget += 0.1
                    }){
                        Image(systemName: "plus.circle.fill")
                            .padding()
                    }
                    
                }.buttonStyle(.plain).presentationCompactAdaptation(.popover)
            }
        })
        let SensorRelay =
        ForEach(7...8, id:\.self){ idx in
            Button(action:{
                RobotStatusObject.setRelay(ip: settings.ip, port: settings.port, relay: idx-1)
            }){
                let s = robotStatus.status.relay
                let index = s.index(s.startIndex, offsetBy: idx-1)
                let state : String = String(robotStatus.status.relay[index])
                
                Image(systemName: "\(idx).circle.fill")
                    .padding()
                    .tint(.primary)
                    .background( Circle()
                        .fill(state == "1" ? .orange : notBlack))
                
            }.keyboardShortcut(KeyEquivalent(Character("\(idx)")),modifiers: [])
        }
        let Relay_1_3 =
        ForEach(1...3, id:\.self){ idx in
            Button(action:{
                RobotStatusObject.setRelay(ip: settings.ip, port: settings.port, relay: idx-1)
            }){
                let s = robotStatus.status.relay
                let index = s.index(s.startIndex, offsetBy: idx-1)
                let state : String = String(robotStatus.status.relay[index])
                //                                        let state = "1"
                
                Image(systemName: "\(idx).circle.fill")
                    .padding()
                    .tint(.primary)
                    .background(Circle()
                        .fill(state == "1" ? .green : notBlack))
            }.keyboardShortcut(KeyEquivalent(Character("\(idx)")),modifiers: [])
        }
        let Relay_4_6 =
        ForEach(4...6, id:\.self){ idx in
            Button(action:{
                RobotStatusObject.setRelay(ip: settings.ip, port: settings.port, relay: idx-1)
            }){
                let s = robotStatus.status.relay
                let index = s.index(s.startIndex, offsetBy: idx-1)
                let state : String = String(robotStatus.status.relay[index])
                //                                        let state = "1"
                
                Image(systemName: "\(idx).circle.fill")
                    .padding()
                    .tint(.primary)
                    .background(Circle()
                        .fill(state == "1" ? .green : notBlack))
            }.keyboardShortcut(KeyEquivalent(Character("\(idx)")),modifiers: [])
        }
        

        VStack {
            if viewModel.show{
                Button(action:{
                    withAnimation{
                        viewModel.webShow.toggle()
                    }
                }){
                    Label("Control", systemImage: "macstudio.fill")
                        .padding()
                        .padding(.vertical)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 33.0).fill(robotStatus.status.connected ? .green : .red))
                }.buttonStyle(.plain)
                HStack{
                    //Button Here
                    VStack{
                        if !compact{
                            Spacer()
                                .frame(maxHeight : .infinity)
                        }
                        if compact{
                            VStack{
                                VStack{
                                    HStack{
                                        ForEach(1...4, id:\.self){ idx in
                                            Button(action:{
                                                RobotStatusObject.setRelay(ip: settings.ip, port: settings.port, relay: idx-1)
                                            }){
                                                let s = robotStatus.status.relay
                                                let index = s.index(s.startIndex, offsetBy: idx-1)
                                                let state : String = String(robotStatus.status.relay[index])
                                                //                                        let state = "1"
                                                
                                                Image(systemName: "\(idx).circle.fill")
                                                    .padding()
                                                    .tint(.primary)
                                                    .background(Circle()
                                                        .fill(state == "1" ? .green : notBlack))
                                            }.keyboardShortcut(KeyEquivalent(Character("\(idx)")),modifiers: [])
                                        }
                                    }
                                    HStack{
                                        ForEach(5...8, id:\.self){ idx in
                                            Button(action:{
                                                RobotStatusObject.setRelay(ip: settings.ip, port: settings.port, relay: idx-1)
                                            }){
                                                let s = robotStatus.status.relay
                                                let index = s.index(s.startIndex, offsetBy: idx-1)
                                                let state : String = String(robotStatus.status.relay[index])
                                                //                                        let state = "1"
                                                
                                                Image(systemName: "\(idx).circle.fill")
                                                    .padding()
                                                    .tint(.primary)
                                                    .background(Circle()
                                                        .fill(state == "1" ? .green : notBlack))
                                            }.keyboardShortcut(KeyEquivalent(Character("\(idx)")),modifiers: [])
                                        }
                                    }
                                        
                                }
                                .padding()
                                .frame(maxWidth: .infinity,maxHeight: .infinity)
                                .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial))
                                
                                
                                
                                HStack{
    //                                SetpointMeter
                                    connectIcon
                                    EL_CID_TriggerButton()
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 33 ).fill(.ultraThinMaterial))
                                .frame(maxWidth: .infinity)
                                HStack{
                                    L_Adj
                                    Spacer()
                                    AutoControlView(leftPower: $viewModel.leftPower, rightPower: $viewModel.rightPower,tight:false)
                                    Spacer()
                                    R_Adj
                                }
                                
                                .frame(maxWidth: .infinity,maxHeight: .infinity)
                                
                            }//.padding()
                        }else{
                            VStack{
                                SensorRelay
                                Relay_1_3
                                Relay_4_6
                            }.padding()
                                .background(Capsule()
                                    .fill(.ultraThinMaterial))
                        }
                    }
                    
                    if !compact{
                        Divider()
                            .padding()
                        
                        VStack{
                            
                            HStack{
                                TabView{
                                    VStack{
                                        Group{
                                            HStack{
                                                VStack{
                                                    AutoMenu(content: {
                                                        Label(String(format : "%05d",robotStatus.status.lazer), systemImage: "ruler.fill")
                                                            .padding()
                                                            .frame(maxWidth: .infinity)
                                                            .contentTransition(.numericText(countsDown: true))
                                                            .foregroundStyle(Constants.notBlack)
                                                            .background(RoundedRectangle(cornerRadius: 25.0).fill(Constants.offWhite))
                                                        //                                                .padding()
                                                    }).buttonStyle(.plain)
                                                    PressureView(enabled : true)
                                                        .padding()
                                                        .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial))
                                                   
                                                }.padding([.horizontal,.top])
                                                VStack{
                                                    HStack{
                                                        L_Adj
                                                        Spacer()
                                                        R_Adj
                                                        
                                                    }.padding([.horizontal,.top])
                                                    
                                                }
                                            }
                                        }
                                        Group{
                                            HStack{
                                                Button(action:{
                                                    withAnimation{
                                                        viewModel.showHints.toggle()
                                                    }
                                                }){
                                                    Image(systemName:"lightbulb.fill")
                                                        .padding()
                                                        .background(Circle().fill(viewModel.showHints ? .yellow : Constants.notBlack))
                                                }.buttonStyle(.plain)
                                                AutoMenu(content: {
                                                    Text(autoStatus.autoMode.rawValue)
                                                        .lineLimit(1)
                                                        .padding()
                                                        .background(RoundedRectangle(cornerRadius: 33.0).fill(.ultraThickMaterial))
                                                        .padding()
                                                }).buttonStyle(.plain)
                                                
                                                HStack{
                                                    SetpointMeter
                                                    connectIcon
                                                    EL_CID_TriggerButton()
                                                }
                                                .padding()
                                                .background(Capsule().fill(.ultraThinMaterial))
                                            }
                                        }
                                    }
                                    
    //                                        AudioCurveView(title:false)
    //                                            .padding()
                                    
                                }.tabViewStyle(.page)
                            }
                            HStack{
    //                            AutoView()
    //                                .padding()
                                if viewModel.showHints{
                                    VStack{
                                        VStack{
                                            Image("Robot_top")
                                                .resizable()
                                                .scaledToFit()

                                        }
                                        
                                    }.frame(maxHeight: .infinity).padding()
                                }

                                FBGView()
                                    
                            }
    //                        .padding()
                            .background(RoundedRectangle(cornerRadius: 33).stroke(.white))
                            .padding()
                            
                            
                        }.frame(maxHeight: .infinity)
                        Divider()
                            .padding()
                        
                        
                        VStack{
                            let data = robotStatus.status.tof
                            
                            ScrollView(showsIndicators: false){
                                VStack(spacing : 20){
                                    Label(String(format: "%03d",robotStatus.status.roll_angle), systemImage: "arrow.trianglehead.clockwise")
                                        .padding()
                                        .font(.title)
                                        .contentTransition(.numericText(countsDown: true))
                                        .background(RoundedRectangle(cornerRadius: 33.0).fill(.ultraThickMaterial))
                                    ForEach(Array(data[0...13].enumerated()), id: \.0) { idx, value in
                                        Label(String(format : "%03d",value), systemImage: "\(idx+1).circle.fill")
                                            .foregroundColor(value == 153 ? .red : Constants.offWhite)
                                            .padding()
                                            .font(.title)
                                            .contentTransition(.numericText(countsDown: true))
                                            .background(RoundedRectangle(cornerRadius: 33.0).fill(.ultraThickMaterial))
                                    }
                                    
                                    
                                }.frame(maxHeight : .infinity)
                            }
                            Spacer()
                            
                            AutoControlView(leftPower: self.$viewModel.leftPower, rightPower: self.$viewModel.rightPower)
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            viewModel.show = true
            Logger().info("Control View appeared")
//            robotStatus.timer = Timer.publish(every: Constants.SLOW_RATE, on: .main, in: .common).autoconnect()
        })
        .onDisappear(perform: {
            viewModel.show = false
            Logger().info("Control View disappeared")
//            robotStatus.timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
        })
        
        
        
    }
}

extension ControlView {
    @Observable
    class ViewModel{
        var l = 0.1
        var r = 0.1
        var leftPower = 100
        var rightPower = 100
        var popup = false
        var angleTarget : Float = 0.0
        var webShow = false
        var showHints = false
        var show = false
    }
    
    func sendCommand(){
//        launchPlatformStatus.RotatePlatform(ip: settings.ip, port: settings.port, value: .degrees(Double(viewModel.angleTarget).truncatingRemainder(dividingBy: 360)))
    }
}

