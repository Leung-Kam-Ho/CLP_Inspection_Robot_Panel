import SwiftUI
import os

struct ContentView: View {
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    var body: some View {
        GeometryReader{ screen in
            let bigEnough = UIScreen.main.traitCollection.userInterfaceIdiom == .pad
            TabView(selection: self.$viewModel.selectedTab){
                if bigEnough{
                    Tab("All", systemImage: "widget.small", value: .All){
                        ConceptView(selection : self.$viewModel.selectedTab)
                            
                    }
                }
                Tab("Auto",systemImage:"point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath",value: .Auto){
                        AutoView()
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 49.0)
                                .fill(.ultraThinMaterial)
                                .stroke(.white)
                            )
                            .padding()

                    
                }
                
                Tab("Progress", systemImage:"switch.programmable", value: .Progress){
                    InspectionProgressView()
                        .padding()
                        
                }
                Tab("Robot", systemImage:"macstudio.fill",value: .Robot){
                    ControlView(compact: !bigEnough)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 49).fill(.ultraThinMaterial).stroke(.white))
                        .padding()
                        
                }
                Tab("Launch Platform", systemImage:"circle.bottomrighthalf.pattern.checkered", value: .LaunchPlatform){
                        
                        LaunchPlatformView(compact: !bigEnough)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 49.0)
                            .fill(.ultraThinMaterial)
                            .stroke(.white)
                        )
                        .padding()
                        
                }
                Tab("Audio", systemImage:"waveform", value: .Audio){
                    AudioSystemView(current_tab:$viewModel.selectedTab)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 49.0)
                            .fill(.ultraThinMaterial)
                            .stroke(.white)
                        )
                        .padding()
                }
                Tab("Camera", systemImage: "camera.fill", value:.Camera){
                    ZStack{
                        if self.viewModel.camera_tab_toggle{
                            Camera_WebView(cleanUI: true)
                                .disabled(true)
                        }
                        Color.clear
                            .overlay(alignment: .bottomTrailing, content: {
                                Button(action:{
                                    viewModel.camera_tab_toggle.toggle()
                                        
                                }){
                                    Label("Toggle Camera", image: "camera.fill")
                                        .padding()
                                        .foregroundStyle(.yellow)
                                        .background(Capsule().fill(.ultraThinMaterial))
                                }
                                .buttonStyle(.plain)
                //                                .padding()
                                .padding()
                            })
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 49.0)
                        .fill(.ultraThinMaterial)
                        .stroke(.white)
                    )
                    .padding()
                    
                }
                Tab("Pressure", systemImage:"gauge.with.dots.needle.100percent", value: .Pressure){
                    VStack{
                        Label("Pressure CTRL", systemImage: "chart.bar.yaxis")
                            .padding()
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 33.0).fill(station.status.digital_valve_status.connected ? .green : .red))
                            
                        PressureView(enabled : true)
                            .padding()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 49.0)
                        .fill(.ultraThinMaterial)
                        .stroke(.white)
                    )
                    .padding()
                    
                }
                
                
                Tab("Sensor", systemImage:"ruler.fill", value: .ToF){
                    ToFView()
                        .padding()
                        
                }
                
                
            }
            .tabViewStyle(.page)
        }
        // Change the data update rate, since all chart and ui are update in the main the main thread, and the cpu usage of chart is higher
        .onChange(of: viewModel.selectedTab, { old, new in
            
            if new == .Audio || new == .Robot{
                station.dataUpdateRate(Constants.MEDIUM_RATE)
                Logger().info("Changed FPS to \(Constants.MEDIUM_RATE)")
            }else if new == .ToF || new == .LaunchPlatform{
                station.dataUpdateRate(Constants.INTENSE_RATE)
                Logger().info("Changed FPS to \(Constants.INTENSE_RATE)")
            }else{
                station.dataUpdateRate(Constants.SLOW_RATE)
                Logger().info("Changed FPS to \(Constants.SLOW_RATE)")
            }
        })
        .scrollContentBackground(.hidden)
        .bold()
//        .background(Constants.notBlack)
        .preferredColorScheme(.dark)
        .onReceive(station.timer, perform: station.updateData)
        .monospacedDigit()
        
    }
    
    func status_update_loop(){
        while true{
            _ = self.station.get_request("/data")
        }
    }
}

extension ContentView{
    enum Tabs{
        case All
        case Auto
        case Robot
        case Pressure
        case LaunchPlatform
        case ToF
        case Camera
        case Progress
        case Audio
    }
    @Observable
    class ViewModel{
        var selectedTab: Tabs = .All
        var camera_tab_toggle = false
    }
}

#Preview {
    @Previewable var station = Station()
    ContentView()
        .environmentObject(station)
}
