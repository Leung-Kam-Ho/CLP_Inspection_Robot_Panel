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
                    
                    HStack{
                        AutoView()
                            .frame(width : width * 0.3)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 25.0)
                                .fill(.ultraThinMaterial)
                                .stroke(.white)
                            )
                            
                        VStack{
                            Button(action:{
                                withAnimation{
                                    self.selection = .Pressure
                                }
                            }){
                                ZStack{
                                    VStack{
                                        Text("Pressure")
                                            .font(.title)
                                            .tint(.primary)
                                            .underline()
                                            .padding(.horizontal)
                                            .frame(maxWidth: .infinity,alignment: .leading)
                                        PressureView(enabled : false)
                                            
                                        
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 25.0)
                                        .fill(.ultraThinMaterial))
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .fill(.black.opacity(0.1))
                                }
                            }
                            HStack{
                                Button(action:{
                                    withAnimation{
                                        self.selection = .Robot
                                    }
                                }){
                                    GridRelayView()
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 25.0)
                                            .fill(.ultraThinMaterial))
                                }
                                Button(action:{
                                    withAnimation{
                                        self.selection = .LaunchPlatform
                                    }
                                }){
                                    VStack{
                                        Text("Slot")
                                            .font(.title)
                                            .padding(.horizontal)
                                            .tint(.primary)
                                            .underline()
                                            .frame(maxWidth: .infinity,alignment: .leading)
                                        LaunchPlatformView(enabled : false)
                                    }.padding()
                                        .background(RoundedRectangle(cornerRadius: 25.0)
                                            .fill(.ultraThinMaterial))
                                    
                                }
                                
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
