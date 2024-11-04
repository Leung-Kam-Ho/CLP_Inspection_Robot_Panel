import SwiftUI
import os

struct ContentView: View {
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    var body: some View {
        GeometryReader{ screen in
            let bigEnough = UIScreen.main.traitCollection.userInterfaceIdiom == .pad
            let contentMinSize = CGSize(width: 1100, height: 1000)
            //Views
            let camera =
            Camera_WebView()

            let controlView =
            ControlView(compact: !bigEnough)
                .padding()
                .background(RoundedRectangle(cornerRadius: 49).fill(.ultraThinMaterial).stroke(.white))
                .padding()
            
            let conceptView =
            ConceptView(selection : self.$viewModel.selectedTab)
            let autoView =
            AutoView()
                .padding()
                .background(RoundedRectangle(cornerRadius: 49.0)
                    .fill(.ultraThinMaterial)
                    .stroke(.white)
                )
                .padding()

            let progressView =
            InspectionProgressView()
                .padding()
            let launchPlatformView =
            LaunchPlatformView(compact: !bigEnough)
            .padding()
            .background(RoundedRectangle(cornerRadius: 49.0)
                .fill(.ultraThinMaterial)
                .stroke(.white)
            )
            .padding()
            let audioView =
            AudioSystemView(current_tab:$viewModel.selectedTab)
                .padding()
                .background(RoundedRectangle(cornerRadius: 49.0)
                    .fill(.ultraThinMaterial)
                    .stroke(.white)
                )
                .padding()
            let pressureView =
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
            let tofView =
            ToFView()
                .padding()

            //Main
            HStack{
                
                TabView(selection: self.$viewModel.selectedTab){
                    if bigEnough{
                        Tab("Camera", systemImage: "camera.fill",value: .Camera_full){
                            camera
                        }
                        
                        Tab("All", systemImage: "widget.small", value: .All){
                            conceptView
                                
                        }
                    }
                    Tab("Auto",systemImage:"point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath",value: .Auto){
                        autoView
                        
                    }
                    
                    Tab("Progress", systemImage:"switch.programmable", value: .Progress){
                        progressView
                            
                    }
                    Tab("Robot", systemImage:"macstudio.fill",value: .Robot){
                        controlView
                            
                    }
                    Tab("Launch Platform", systemImage:"circle.bottomrighthalf.pattern.checkered", value: .LaunchPlatform){
                        launchPlatformView
                            
                    }
                    Tab("Audio", systemImage:"waveform", value: .Audio){
                        audioView
                    }
                    
                    Tab("Pressure", systemImage:"gauge.with.dots.needle.100percent", value: .Pressure){
                        pressureView
                    }
                    
                    
                    Tab("Sensor", systemImage:"ruler.fill", value: .ToF){
                        tofView
                            
                    }
                    
                    
                }
                if viewModel.cameraMode == .half{
                    
                    if screen.size.width > contentMinSize.width * 2{
                        camera
                    }
                    
                    
                }
                
            }
            .tabViewStyle(.sidebarAdaptable)
            
            .tabViewSidebarHeader(content: {
                if screen.size.width > contentMinSize.width * 2{
                    VStack{
                        Picker("Mode", selection: $viewModel.cameraMode, content: {
                            ForEach(CameraMode.allCases, id: \.self) { mode in
                                
                                Image(systemName: mode.rawValue)
                                    .id(mode)
                            }

                        }).pickerStyle(.segmented)
                    }
                    .padding()
                }
              
            })
            .indexViewStyle(.page(backgroundDisplayMode: .always))
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
        case Camera_full
        case Progress
        case Audio
    }
    enum CameraMode : String , CaseIterable{
        case half = "inset.filled.lefthalf.righthalf.rectangle"
        case none = "inset.filled.topleft.topright.bottomleft.bottomright.rectangle"
    }
    @Observable
    class ViewModel{
        var selectedTab: Tabs = .All
        var camera_tab_toggle = false
        var cameraMode : CameraMode = .none
    }
}

#Preview {
    @Previewable var station = Station()
    ContentView()
        .environmentObject(station)
}
