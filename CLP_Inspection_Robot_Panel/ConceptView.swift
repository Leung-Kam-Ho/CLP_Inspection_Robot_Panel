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
                                    PressureView(enabled : false)
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
                                    LaunchPlatformView(enabled : false)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 25.0)
                                            .fill(.ultraThinMaterial))
                                }
                                
                            }
                        }
                        
                    }
                    
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
