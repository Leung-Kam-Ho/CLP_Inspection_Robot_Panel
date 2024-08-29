import SwiftUI
import Charts

struct ControlView: View {
    @State var viewModel = ViewModel()
    @EnvironmentObject var station : Station
    let notBlack = Color(red: 24/255, green: 24/255, blue: 24/255)
    var compact : Bool = false
    var body: some View {
        let roll_Section =
        HStack{
            (Image(systemName: "dial.low.fill"))
            Text("\(self.station.status.robot_status.roll_angle)")
        }
        .padding()
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity)
        .background(Capsule().fill(Constants.offWhite))
        
        let roll_Section_Round =
        HStack{
            Image(systemName: "dial.low.fill")
            Text(String(format : "%03d",self.station.status.robot_status.roll_angle))
        }
        .foregroundStyle(.primary)
        .padding()
        .background(RoundedRectangle(cornerRadius: 25).fill(.ultraThinMaterial))
        .monospacedDigit()
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
        .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThinMaterial))
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
            .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThinMaterial))
        let controlButton_L =
        Button(action:{
            let left = 1500 - (400 * self.viewModel.leftPower / 100)
            let right = 1500 - (400 * self.viewModel.rightPower / 100)
            self.station.post_request("/servo", value: [left,right,
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
            self.station.post_request("/servo", value: [1500,1500,1500,1500])
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
            let left = 1500 + (400 * self.viewModel.leftPower / 100)
            let right = 1500 + (400 * self.viewModel.rightPower / 100)
            self.station.post_request("/servo", value: [left,right,
                                                        left,right])
        }){
            Image(systemName: "arrowtriangle.down.fill")
                .padding()
                .tint(.primary)
                .background(Capsule()
                    .fill(notBlack))
            
        }.keyboardShortcut(.downArrow, modifiers: [])
        
        let connectIcon =
        Button(action:{
            withAnimation{
                viewModel.popup.toggle()
            }
        }){
            Text(String(station.status.launch_platform_status.angle))
                .padding()
                .foregroundStyle(.green)
                .background(Circle().fill(.ultraThinMaterial))
        }.popover(isPresented: $viewModel.popup, content: {
            HStack{
                Button(action:{
                    viewModel.angleTarget -= 1
                }){
                    Image(systemName: "minus.circle.fill")
                        .padding()

                }
                Text(String(viewModel.angleTarget))
                    .padding()
                    .foregroundStyle(.green)
                    .onAppear{
                        viewModel.angleTarget = station.status.launch_platform_status.angle
                    }
                    .onDisappear{
                        // send command on disapper
                        sendCommand()
                    }
                Button(action:{
                    viewModel.angleTarget += 1
                }){
                    Image(systemName: "plus.circle.fill")
                        .padding()
                }
                
            }.buttonStyle(.plain).presentationCompactAdaptation(.popover)
        })
        let SensorRelay =
        ForEach(7...8, id:\.self){ idx in
            Button(action:{
                self.station.post_request("/relay", value: [idx-1])
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
                self.station.post_request("/relay", value: [idx-1])
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
                self.station.post_request("/relay", value: [idx-1])
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
            Label("Robot Control", systemImage: "macstudio.fill")
                .padding()
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 25.0).fill(self.station.status.robot_status.connected ? .green : .red))
            HStack{
                //Button Here
                VStack{
                    if !compact{
                        VStack{
                            Text("CurPos")
                            connectIcon
                            RecordingButton()
                            
                        }.padding()
                        
                        Spacer()
                            .frame(maxHeight : .infinity)
                    }
                    if compact{
                        
                        VStack{
                            HStack{
                                VStack{
                                    connectIcon
                                    SensorRelay
                                }.padding()
                                    .background(Capsule()
                                        .fill(.ultraThinMaterial))
                                Spacer()
                                VStack{
                                    Relay_1_3
                                    
                                }.padding()
                                    .background(Capsule()
                                        .fill(.ultraThinMaterial))
                                Spacer()
                                VStack{
                                    Relay_4_6
                                }.padding()
                                    .background(Capsule()
                                        .fill(.ultraThinMaterial))
                            }.frame(maxWidth: .infinity,maxHeight: .infinity)
                            
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
                            }.frame(maxWidth: .infinity,maxHeight: .infinity)
                            HStack{
                                roll_Section
                            
                                RecordingButton()
                            }.padding().background(Capsule().fill(.ultraThinMaterial))
                           
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
                                VStack{
                                    Label(String(format : "%04d",self.station.status.robot_status.lazer), systemImage: "ruler.fill")
                                        .padding()
                                        .contentTransition(.numericText(countsDown: true))
                                        .background(RoundedRectangle(cornerRadius: 25.0).fill(.red))
                                        .padding()
//                                        .frame(maxHeight: .infinity,alignment : .top)
                                    VStack{
                                        Image("Robot_top")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxHeight: .infinity)
                                        roll_Section_Round
                                    }
                                        
                                }.frame(maxHeight: .infinity)
                                
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 25.0).stroke(.white))
                                .padding()
                                VStack{
                                        VStack{
                                            Label("Pressure CTRL", systemImage: "chart.bar.yaxis")
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .foregroundStyle(Constants.notBlack)
                                                .background(RoundedRectangle(cornerRadius: 25.0).fill(Constants.offWhite))
                                                
                                            PressureView(enabled : true)
                                        }.padding()
                                    HStack{
                                        L_Adj
                                        Spacer()
                                        R_Adj
                                            
                                        
                                    }.padding()
                                }
                            }
                        }.frame(maxHeight: .infinity)
                    
//                    .padding()
                    Divider()
                        .padding()
                    
                    
                    VStack{
                        let data = self.station.status.robot_status.tof
                        
                        ScrollView(showsIndicators: false){
                            VStack(spacing : 20){
                                ForEach(Array(data[0...10].enumerated()), id: \.0) { idx, value in
                                    Label(String(format : "%03d",value), systemImage: "\(idx+1).circle.fill")
                                        .padding()
                                        .font(.title)
                                        .contentTransition(.numericText(countsDown: true))
                                        .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThickMaterial))
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
        .padding()
        .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial).stroke(.white))
        
        
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
        var angleTarget = 0
        
    }
    
    func sendCommand(){
        station.RotatePlatform(Angle: .degrees(Double(viewModel.angleTarget).truncatingRemainder(dividingBy: 360)))
    }
}
