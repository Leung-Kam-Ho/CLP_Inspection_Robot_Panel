import SwiftUI
import Charts

struct ControlView: View {
    @State var viewModel = ViewModel()
    @EnvironmentObject var station : Station
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
        let controlButton_L =
        Button(action:{
            let left = self.viewModel.leftPower
            let right = self.viewModel.rightPower
            _ = self.station.post_request("/servo", value: [left,right,
                                                        left,right])
        }){
            Image(systemName: "arrowtriangle.up.fill")
                .padding()
                .tint(.primary)
                .background(Capsule()
                    .fill(notBlack))
        }.keyboardShortcut(.upArrow, modifiers: [])
        //                                        Spacer()
        let controlButton_S =
        Button(action:{
            _ = self.station.post_request("/servo", value: [0,0,0,0])
        }){
            Image(systemName: "stop.fill")
                .padding()
                .tint(.primary)
                .background(Capsule()
                    .fill(notBlack))
        }.keyboardShortcut(.space, modifiers: [])
        //                                        Spacer()
        let controlButton_R =
        Button(action:{
            let left = -self.viewModel.leftPower
            let right = -self.viewModel.rightPower
            _ = self.station.post_request("/servo", value: [left,right,
                                                        left,right])
        }){
            Image(systemName: "arrowtriangle.down.fill")
                .padding()
                .tint(.primary)
                .background(Capsule()
                    .fill(notBlack))
            
        }.keyboardShortcut(.downArrow, modifiers: [])
        let SetpointMeter =
        HStack{
            Text(String(format:"%05.1f",station.status.launch_platform_status.setpoint))
                .padding()
//                .background(Capsule().fill(.ultraThickMaterial))
        }
        let connectIcon =
        Button(action:{
            withAnimation{
                viewModel.popup.toggle()
            }
        }){
            Text(String(format:"%05.1f",station.status.launch_platform_status.angle))
                .padding()
                .foregroundStyle( station.status.launch_platform_status.connected ? .green : .red)
                .background(Capsule().fill(.ultraThinMaterial))
        }.popover(isPresented: $viewModel.popup, content: {
            VStack{
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
                                viewModel.angleTarget = station.status.launch_platform_status.angle
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
                _ = self.station.post_request("/relay", value: [idx-1])
            }){
                let s = self.station.status.robot_status.relay
                let index = s.index(s.startIndex, offsetBy: idx-1)
                let state : String = String(self.station.status.robot_status.relay[index])
                
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
                _ = self.station.post_request("/relay", value: [idx-1])
            }){
                let s = self.station.status.robot_status.relay
                let index = s.index(s.startIndex, offsetBy: idx-1)
                let state : String = String(self.station.status.robot_status.relay[index])
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
                _ = self.station.post_request("/relay", value: [idx-1])
            }){
                let s = self.station.status.robot_status.relay
                let index = s.index(s.startIndex, offsetBy: idx-1)
                let state : String = String(self.station.status.robot_status.relay[index])
                //                                        let state = "1"
                
                Image(systemName: "\(idx).circle.fill")
                    .padding()
                    .tint(.primary)
                    .background(Circle()
                        .fill(state == "1" ? .green : notBlack))
            }.keyboardShortcut(KeyEquivalent(Character("\(idx)")),modifiers: [])
        }
        

        VStack {
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
                    .background(RoundedRectangle(cornerRadius: 33.0).fill(self.station.status.robot_status.connected ? .green : .red))
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
                                            _ = self.station.post_request("/relay", value: [idx-1])
                                        }){
                                            let s = self.station.status.robot_status.relay
                                            let index = s.index(s.startIndex, offsetBy: idx-1)
                                            let state : String = String(self.station.status.robot_status.relay[index])
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
                                            _ = self.station.post_request("/relay", value: [idx-1])
                                        }){
                                            let s = self.station.status.robot_status.relay
                                            let index = s.index(s.startIndex, offsetBy: idx-1)
                                            let state : String = String(self.station.status.robot_status.relay[index])
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
                                RecordingButton()
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 33 ).fill(.ultraThinMaterial))
                            .frame(maxWidth: .infinity)
                            HStack{
                                L_Adj
                                Spacer()
                                VStack{
                                    controlButton_L
                                    Spacer()
                                    controlButton_S
                                    Spacer()
                                    controlButton_R
                                }.padding()
                                    .background(Capsule()
                                        .fill(.ultraThinMaterial))
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
                                                    Label(String(format : "%05d",self.station.status.robot_status.lazer), systemImage: "ruler.fill")
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
                                            HStack{
                                                SetpointMeter
                                                connectIcon
                                                EL_CID_TriggerButton()
                                                RecordingButton()
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
                            if viewModel.showHints{
                                VStack{
                                    VStack{
                                        Image("Robot_top")
                                            .resizable()
                                            .scaledToFit()

                                    }
                                    
                                }.frame(maxHeight: .infinity).padding()
                            }
//                                    LaunchPlatformView(compact:true,title:false)
//                                        .padding()
                            AudioCurveView(title:false)
                                .padding()
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 33).stroke(.white))
                        .padding()
                        
                        
                    }.frame(maxHeight: .infinity)
                    Divider()
                        .padding()
                    
                    
                    VStack{
                        let data = self.station.status.robot_status.tof
                        
                        ScrollView(showsIndicators: false){
                            VStack(spacing : 20){
                                
                                ForEach(Array(data[0...13].enumerated()), id: \.0) { idx, value in
                                    Label(String(format : "%03d",value), systemImage: "\(idx+1).circle.fill")
                                        .padding()
                                        .font(.title)
                                        .contentTransition(.numericText(countsDown: true))
                                        .background(RoundedRectangle(cornerRadius: 33.0).fill(.ultraThickMaterial))
                                }
                                
                                
                            }.frame(maxHeight : .infinity)
                        }
                        Spacer()
                        
                        VStack{
                            controlButton_L
                            controlButton_S
                            controlButton_R
                        }.padding()
                            .background(Capsule()
                                .fill(.ultraThinMaterial))
                    }
                }
            }
        }
//        .fullScreenCover(isPresented: $viewModel.webShow) {
//           
//        }
//        
        
        
    }
}

extension ControlView {
    @Observable
    class ViewModel{
        var l = 1.0
        var r = 1.0
        var leftPower = 100
        var rightPower = 100
        var popup = false
        var angleTarget : Float = 0.0
        var webShow = false
        var showHints = false
        
    }
    
    func sendCommand(){
        _ = station.RotatePlatform(Angle: .degrees(Double(viewModel.angleTarget).truncatingRemainder(dividingBy: 360)))
    }
}



#Preview {
    @Previewable var station = Station()
    ControlView(compact: true)
        .environmentObject(station)
}

