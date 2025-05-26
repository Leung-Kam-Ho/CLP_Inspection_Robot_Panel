import SwiftUI
import Charts

struct ConceptView : View{
    @Binding var selection : ContentView.Tabs
    @EnvironmentObject var station : Station
    var body: some View{
        let pressure_btn =
        Button(action:{
            self.selection = .Robot
        }){
            GroupBox("Control"){
                VStack{
                    GridRelayView()
                        
                }
            }
            .clipShape(.rect(cornerRadius: 33))
            .padding()
                .background(RoundedRectangle(cornerRadius: 49.0)
                    .fill(.ultraThinMaterial))
        }
        .buttonStyle(.plain)
        .opacity(self.station.status.robot_status.connected ? 1 : 0.5)
        let launch_platform_btn =
        Button(action:{
            self.selection = .LaunchPlatform
            
        }){
            GroupBox("LaunchPlatform"){
                VStack{
                    LaunchPlatformView(enabled : false)
                    
                }
            }
            .clipShape(.rect(cornerRadius: 33))
            .padding()
                .background(RoundedRectangle(cornerRadius: 49.0)
                    .fill(.ultraThinMaterial))
            
            
        }.buttonStyle(.plain).opacity(self.station.status.launch_platform_status.connected ? 1 : 0.5)
        let auto_btn =
        AutoView()
            .padding()
            .background(RoundedRectangle(cornerRadius: 49.0)
                .fill(.ultraThinMaterial)
                .stroke(.white)
            )
//        let audio_btn =
//        Button(action:{
//            self.selection = .Audio
//        }){
//            AudioCurveView()
//                .opacity(self.station.status.audio_status.connected ? 1 : 0.5)
//        }.buttonStyle(.plain)
        let sensor_bar =
        SensorBarView()
            .opacity(self.station.status.robot_status.connected ? 1 : 0.5)
        
        
        //View
        ZStack(alignment : .center){
            VStack{
                sensor_bar
                HStack{
//                    audio_btn
                    pressure_btn
                }.frame(maxHeight: .infinity)
                HStack{
                    auto_btn
                    launch_platform_btn
                }
            }.padding()
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

#Preview {
    @Previewable var station = Station()
    ConceptView(selection: .constant(.All))
        .environmentObject(station)
}
