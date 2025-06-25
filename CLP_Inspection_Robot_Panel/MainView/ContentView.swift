import SwiftUI
import os

struct ContentView: View {
    @EnvironmentObject var robotStatus : RobotStatusObject
    @EnvironmentObject var digitalValveStatus : DigitalValveStatusObject
    @EnvironmentObject var launchPlatformStatus : LaunchPlatformStatusObject
    @EnvironmentObject var autoStatus : AutomationStatusObject
    @EnvironmentObject var elcidStatus : ElCidStatusObject
    @EnvironmentObject var settings : SettingsHandler
    @State var viewModel = ViewModel()
    @AppStorage("MyAppTabViewCustomization")
    private var customization: TabViewCustomization
    var body: some View {
        
        GeometryReader{ screen in
            let bigEnough = UIScreen.main.traitCollection.userInterfaceIdiom == .pad
            //Views
            let camera =
            Camera_WebView()
                .padding()
                .background(RoundedRectangle(cornerRadius: 49).fill(.ultraThinMaterial).stroke(.white))
                .padding()

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
            LaunchPlatformView(compact: !bigEnough, show_slot:false)
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
                    .background(RoundedRectangle(cornerRadius: 33.0).fill(digitalValveStatus.status.connected ? .green : .red))
                    
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
//                        if bigEnough{
//                            Tab("Concept")
//
//
//                        }
                        if bigEnough{
                            Tab("All", systemImage: "widget.small", value: Tabs.All){
                                conceptView
                                    
                            }
                        }
                        Tab("Auto",systemImage:"point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath",value: Tabs.Auto){
                            autoView
                        }
                        Tab("Camera", systemImage: "camera.fill", value: Tabs.Camera) {
                            camera
                        }
                        
                        Tab("Robot", systemImage:"macstudio.fill",value: Tabs.Robot){
                            controlView
                                
                        }
                        
                        Tab("Launch Platform", systemImage:"circle.bottomrighthalf.pattern.checkered", value: Tabs.LaunchPlatform){
                            launchPlatformView
                                
                        }
                        
                        Tab("Pressure", systemImage:"chart.bar.fill", value: Tabs.Pressure){
                            pressureView
                                
                        }
                        
                        
                        Tab("Progress", systemImage:"switch.programmable", value: Tabs.Progress){
                            progressView
                                
                        }
                        
                        

                        

                    }
                    .tabViewStyle(.sidebarAdaptable)
                    

                
                
            }
        }

        
    }

}

extension ContentView{
    enum Tabs : Hashable{
        case All
        case Auto
        case Robot
        case Pressure
        case LaunchPlatform
        case ToF
        case Camera
        case Camera_full
        case Progress
        case placeHolder
    }
    enum CameraMode : String , CaseIterable{
        case half = "inset.filled.lefthalf.righthalf.rectangle"
        case none = "inset.filled.topleft.topright.bottomleft.bottomright.rectangle"
    }
    @Observable
    class ViewModel{
        var selectedTab: Tabs = .All
//        var selectedTabRight: Tabs = .All
        var camera_tab_toggle = false
        var cameraMode : CameraMode = .none
    }
}
