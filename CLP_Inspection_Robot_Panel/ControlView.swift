import SwiftUI

struct ControlView: View {
    @State var viewModel = ViewModel()
    @EnvironmentObject var station : Station
    let notBlack = Color(red: 24/255, green: 24/255, blue: 24/255)
    var compact : Bool = false
    var body: some View {
        let R_Adj =
        VStack{
            let value = Int(self.viewModel.r * 100)
            Text(String(value))
            VerticalSlider(value: self.$viewModel.r, referenceValue: nil, onEnd: {
                self.viewModel.rightPower = value
            } ,icon: { _ in
                return Image(systemName: "r.circle.fill")
            })
            .padding(.all,compact ? 0 : nil)
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThinMaterial))
        let L_Adj = VStack{
            let value = Int(self.viewModel.l * 100)
            Text(String(value))
            VerticalSlider(value: self.$viewModel.l, referenceValue: nil, onEnd: {
                self.viewModel.leftPower = value
            } ,icon: { _ in
                return Image(systemName: "l.circle.fill")
            })
            
            .padding(.all,compact ? 0 : nil)
        }
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
            }
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
            }
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
                
            }
        
        let connectIcon =
        Image(systemName: "link.circle.fill")
            .padding()
            .background(Circle().fill(self.station.status.robot_status.connected ? .green : .red))
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
                
            }
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
            }
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
            }
        }
        let minWidth = 364.0
            VStack {
                HStack{
                    //Button Here
                    VStack{
                        if !compact{
                            
                            connectIcon
                            
                            Spacer()
                                .frame(height : .infinity)
                        }
                        if compact{
                            Section{
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
                                Text("\(self.station.status.robot_status.roll_angle)")
                                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                                HStack{
                                    L_Adj
                                    VStack{
                                        controlButton_L
                                        controlButton_S
                                        controlButton_R
                                    }.padding()
                                        .background(Capsule()
                                            .fill(.ultraThinMaterial))
                                    R_Adj
                                }.frame(maxWidth: .infinity,maxHeight: .infinity)
                            }.padding()
                                .background(RoundedRectangle(cornerRadius: 25).fill(.ultraThinMaterial))
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
                        HStack{
                            VStack{
                                Robot_Image()
                                HStack{
                                    L_Adj
                                    Image("Robot_top")
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                    R_Adj
                                    
                                    
                                }.padding()
                            }
                        }
                        .padding()
                        Divider()
                            .padding()
                        
                        
                        VStack{
                            Spacer()
                                .frame(height : .infinity)
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
            }.frame(minWidth: minWidth)
        
        
    }
}

extension ControlView {
    @Observable
    class ViewModel{
        var l = 1.0
        var r = 1.0
        var leftPower = 100
        var rightPower = 100
    }
}
