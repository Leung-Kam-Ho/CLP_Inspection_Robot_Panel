import SwiftUI

struct ControlView: View {
    @State var viewModel = ViewModel()
    @EnvironmentObject var station : Station
    let notBlack = Color(red: 24/255, green: 24/255, blue: 24/255)
    var compact : Bool = false
    var body: some View {
        VStack {
                HStack{
                    //Button Here
                    VStack{
                            Image(systemName: "link.circle.fill")
                                .padding()
                                .background(Circle().fill(self.station.status.robot_status.connected ? .green : .red))
                        
                        Spacer()
                            .frame(height : .infinity)
                        VStack{
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
                            ForEach(1...6, id:\.self){ idx in 
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
                        }.padding()
                            .background(Capsule()
                                .fill(.ultraThinMaterial))
                    }
                    
                    if !compact{
                        Divider()
                            .padding()
                        HStack{
                            VStack{
                                Robot_Image()
                                HStack{
                                    VStack{
                                        let value = Int(self.viewModel.l * 100)
                                        Text(String(value))
                                        VerticalSlider(value: self.$viewModel.l, referenceValue: nil, onEnd: {
                                            self.viewModel.leftPower = value
                                        } ,icon: { _ in
                                            return Image(systemName: "l.circle.fill")
                                        })
                                        
                                        .padding()
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThinMaterial))
                                    Image("Robot_top")
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                    VStack{
                                        let value = Int(self.viewModel.r * 100)
                                        Text(String(value))
                                        VerticalSlider(value: self.$viewModel.r, referenceValue: nil, onEnd: {
                                            self.viewModel.rightPower = value
                                        } ,icon: { _ in
                                            return Image(systemName: "r.circle.fill")
                                        })
                                        .padding()
                                        
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThinMaterial))
                                    
                                }.padding()
                            } 
                        }
                        .padding()
                        Divider()
                            .padding()
                    }
                   
                    VStack{
                        Spacer()
                            .frame(height : .infinity)
                        VStack{
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
                        }.padding()
                            .background(Capsule()
                                .fill(.ultraThinMaterial))
                    }
                }
        }
        
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
