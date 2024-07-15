import SwiftUI

struct ContentView: View {
    @StateObject var station = Station()
    @State var viewModel = ViewModel()
    let offWhite = Color(red: 255/255, green: 255/255, blue: 242/255)
    let notBlack = Color(red: 33/255, green: 33/255, blue: 36/255)
    var body: some View {
        GeometryReader{ screen in
            let minW = 1040
            let minH = 810
            let notTooSmall = (Int(screen.size.width) >= minW) && (Int(screen.size.height) >= minH)
            TabView(selection: self.$viewModel.selectedTab){
                if notTooSmall{
                    
                    Tab("All", systemImage: "widget.small", value: .All){
                        
                        ConceptView(selection : self.$viewModel.selectedTab)
                            .background(Image("Watermark"))
                    }
                }
                
                Tab("Auto",systemImage:"point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath",value: .Auto){
                    AutoView()
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThinMaterial))
                        .padding()
                        .background(Image("Watermark"))
                }
                Tab("Robot", systemImage:"robotic.vacuum",value: .Robot){
                    ControlView(compact: !notTooSmall)
                        .padding().background(Image("Watermark"))
                }
                Tab("Pressure", systemImage:"dial.low", value: .Pressure){
                    PressureView()
                        .padding()
                        .background(Image("Watermark"))
                }
                Tab("Launch Platform", systemImage:"rotate.3d.circle.fill", value: .LaunchPlatform){
                    LaunchPlatformView()
                        .padding()
                        .background(Image("Watermark"))
                }
                Tab("Sensor", systemImage:"ruler.fill", value: .ToF){
                    ToFView()
                        .padding()
                        .background(Image("Watermark"))
                }
                
            }.tabViewStyle(.sidebarAdaptable)
        }
        .scrollContentBackground(.hidden)
        //        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .bold()
        .font(.largeTitle)
        .environmentObject(station)
        .background(notBlack)
        .preferredColorScheme(.dark)
        .onReceive(station.timer, perform: station.updateData)
        
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
    }
    @Observable
    class ViewModel{
        var selectedTab: Tabs = .All
    }
}
