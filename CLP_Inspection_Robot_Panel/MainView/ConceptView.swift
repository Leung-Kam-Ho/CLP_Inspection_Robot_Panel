import SwiftUI

struct ConceptView : View{
    @Binding var selection : ContentView.Tabs
    @EnvironmentObject var station : Station
    var body: some View{
        
        ZStack(alignment : .center){
            GeometryReader{ screen in
                let width = screen.size.width
                //                let height = screen.size.height
                VStack{
                    SensorBarView()
                        .opacity(self.station.status.robot_status.connected ? 1 : 0.5)
                    HStack{
                        AutoView()
                            .frame(width : width * 0.3)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 33.0)
                                .fill(.ultraThinMaterial)
                                .stroke(.white)
                            )
                        VStack{
                            Button(action:{
                                self.selection = .Pressure
                            }){
                                ZStack{
                                    VStack{
                                        Label("CTRL", systemImage: "chart.bar.yaxis")
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(Constants.notBlack)
                                            .background(RoundedRectangle(cornerRadius: 25.0).fill(Constants.offWhite))
                                        PressureView(enabled : false)
                                        
                                        
                                    }
                                    
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 33.0)
                                        .fill(.ultraThinMaterial))
                                    RoundedRectangle(cornerRadius: 33.0)
                                        .fill(.black.opacity(0.1))
                                }
                                .opacity(self.station.status.digital_valve_status.connected ? 1 : 0.5)
                            }.buttonStyle(.plain)
                            HStack{
                                Button(action:{
                                    
                                    self.selection = .Robot
                                    
                                }){
                                    VStack{
                                        GridRelayView()
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 33.0)
                                                .fill(.ultraThinMaterial))
                                    }
                                }
                                .buttonStyle(.plain)
                                .opacity(self.station.status.robot_status.connected ? 1 : 0.5)
                                Button(action:{
                                    self.selection = .LaunchPlatform
                                    
                                }){
                                    VStack{
                                        LaunchPlatformView(enabled : false)
                                            
                                    }.padding()
                                        .background(RoundedRectangle(cornerRadius: 33.0)
                                            .fill(.ultraThinMaterial))
                                    
                                    
                                }.buttonStyle(.plain).opacity(self.station.status.launch_platform_status.connected ? 1 : 0.5)
                                
                            }
                        }
                    }.frame(maxHeight: .infinity)
                }.padding()
            }
        }
    }
    
}

extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}
