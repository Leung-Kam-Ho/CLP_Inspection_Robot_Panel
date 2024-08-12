import SwiftUI

struct ContentView: View {
    @StateObject var station = Station()
    @State var viewModel = ViewModel()
    var body: some View {
        GeometryReader{ screen in
            let bigEnough = UIScreen.main.traitCollection.userInterfaceIdiom == .pad
            TabView(selection: self.$viewModel.selectedTab){
                if bigEnough{
                    Tab("All", systemImage: "widget.small", value: .All){
                        
                        ConceptView(selection : self.$viewModel.selectedTab)
                            .background(Image("Watermark"))
                    }
                }
                
                Tab("Auto",systemImage:"point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath",value: .Auto){
                    AutoView()
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25.0)
                            .fill(.ultraThinMaterial)
                            .stroke(.white)
                        )
                        .padding()
                        .background(Image("Watermark"))
                }
                Tab("Robot", systemImage:"robotic.vacuum",value: .Robot){
                    ControlView(compact: !bigEnough)
                        .padding()
                        .background(Image("Watermark"))
                }
                Tab("Pressure", systemImage:"dial.low", value: .Pressure){
                    PressureView()
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25.0)
                            .fill(.ultraThinMaterial)
                            .stroke(.white)
                        )
                        .padding()
                        .background(Image("Watermark"))
                }
                Tab("Launch Platform", systemImage:"rotate.3d.circle.fill", value: .LaunchPlatform){
                    LaunchPlatformView(compact: !bigEnough)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25.0)
                            .fill(.ultraThinMaterial)
                            .stroke(.white)
                        )
                        .padding()
                        .background(Image("Watermark"))
                }
                Tab("Sensor", systemImage:"ruler.fill", value: .ToF){
                    ToFView()
                        .padding()
                        .background(Image("Watermark"))
                }
                
            }.tabViewStyle(.sidebarAdaptable)
                .font(.system(size: bigEnough ? screen.size.width / 50 : screen.size.width/15, weight: .bold, design: .rounded))
        }
        .scrollContentBackground(.hidden)
        .bold()
        .environmentObject(station)
        .background(Constants.notBlack)
        .preferredColorScheme(.dark)
        .onReceive(station.timer, perform: station.updateData)
        .monospacedDigit()
        
    }
    
    func status_update_loop(){
        while true{
            self.station.get_request("/data")
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
    }
    @Observable
    class ViewModel{
        var selectedTab: Tabs = .All
    }
}
