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
                    HStack{
                        AutoView()
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 33.0)
                                .fill(.ultraThinMaterial)
                                .stroke(.white)
                            )
                            .padding()
                        if bigEnough{
                            InspectionProgressView()
                                .padding()
                        }
                    }.background(Image("Watermark"))
                }
                Tab("Robot", systemImage:"macstudio.fill",value: .Robot){
                    ControlView(compact: !bigEnough)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial).stroke(.white))
                        .padding()
                        .background(Image("Watermark"))
                }
                Tab("Launch Platform", systemImage:"circle.bottomrighthalf.pattern.checkered", value: .LaunchPlatform){
                        
                        LaunchPlatformView(compact: !bigEnough)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 33.0)
                            .fill(.ultraThinMaterial)
                            .stroke(.white)
                        )
                        .padding()
                        .background(Image("Watermark"))
                }
                Tab("Pressure", systemImage:"gauge.with.dots.needle.33percent", value: .Pressure){
                    VStack{
                        Label("Pressure CTRL", systemImage: "chart.bar.yaxis")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 25.0).fill(station.status.digital_valve_status.connected ? .green : .red))
                            
                        PressureView(enabled : true)
                            .padding()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 33.0)
                        .fill(.ultraThinMaterial)
                        .stroke(.white)
                    )
                    .padding()
                    .background(Image("Watermark"))
                }
                Tab("Progress", systemImage:"switch.programmable", value: .Progress){
                    InspectionProgressView()
                        .padding()
                        .background(Image("Watermark"))
                }
                
                Tab("Sensor", systemImage:"ruler.fill", value: .ToF){
                    ToFView()
                        .padding()
                        .background(Image("Watermark"))
                }
                Tab("Audio", systemImage:"waveform", value: .Audio){
                    AudioSystemView(current_tab:$viewModel.selectedTab)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 33.0)
                            .fill(.ultraThinMaterial)
                            .stroke(.white)
                        )
                        .padding()
                        .background(Image("Watermark"))
                }
                
            }
            .tabViewStyle(.sidebarAdaptable)
            .font(.system(size: bigEnough ? screen.size.width / 50 : screen.size.width/15, weight: .bold, design: .rounded))
        }
        // Change the data update rate, since all chart and ui are update in the main the main thread, and the cpu usage of chart is higher
        .onChange(of: viewModel.selectedTab, { old, new in
            if new == .Audio{
                station.timer = Timer.publish(every: Constants.CHART_RATE, on: .main, in: .common).autoconnect()
            }else if new == .Robot || new == .ToF{
                station.timer = Timer.publish(every: Constants.INTENSE_UI_RATE, on: .main, in: .common).autoconnect()
            }else{
                station.timer = Timer.publish(every: Constants.UI_RATE, on: .main, in: .common).autoconnect()
            }
        })
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
        case Progress
        case Audio
    }
    @Observable
    class ViewModel{
        var selectedTab: Tabs = .All
    }
}
