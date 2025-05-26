import SwiftUI
import Charts

struct ConceptView : View{
    @Binding var selection : ContentView.Tabs
    @EnvironmentObject var robotStatus : RobotStatusObject
    @EnvironmentObject var digitalValveStatus : DigitalValveStatusObject
    @EnvironmentObject var launchPlatformStatus : LaunchPlatformStatusObject
    @EnvironmentObject var elcidStatus : ElCidStatusObject
    @EnvironmentObject var settings : SettingsHandler
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
        .opacity(robotStatus.status.connected ? 1 : 0.5)
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
            
            
        }.buttonStyle(.plain).opacity(launchPlatformStatus.status.connected ? 1 : 0.5)
        let auto_btn =
        AutoView()
            .padding()
            .background(RoundedRectangle(cornerRadius: 49.0)
                .fill(.ultraThinMaterial)
                .stroke(.white)
            )
        let audio_btn =
        Button(action:{
            self.selection = .placeHolder
        }){
//            AudioCurveView()
            AutoView()
                .padding()
                .background(RoundedRectangle(cornerRadius: 49.0)
                    .fill(.ultraThinMaterial)
                    .stroke(.white)
                )
            
//                .opacity(/*self.station.status.audio_*/status.connected ? 1 : 0.5)
        }.buttonStyle(.plain)
        let sensor_bar =
        SensorBarView()
            .opacity(robotStatus.status.connected ? 1 : 0.5)
        
        
        //View
        ZStack(alignment : .center){
            VStack{
                sensor_bar
                HStack{
                    audio_btn
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
