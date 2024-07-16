import SwiftUI
import Charts

struct PressureView : View{
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    var enabled = true
    var body: some View{
        
        
        VStack{
            HStack{
                ForEach(1...4, id:\.self){ channel in
                    VStack{
                        let r = self.station.status.digital_valve_status.pressure[channel - 1] / self.viewModel.pressure_max
                        VerticalSlider(value: enabled ? self.$viewModel.pressure[channel - 1] : .constant(0), referenceValue: r, onEnd: {
                            if enabled{
                                let value = Float(self.viewModel.pressure[channel - 1] * self.viewModel.pressure_max)
                                self.station.post_request("/pressure", value: [Float(channel - 1), value])
                            }
                        } ,text: { _ in
                            //                            return Image(systemName: "\(channel).circle.fill")
                            let baseValue = (enabled ? self.viewModel.pressure[channel - 1] : r)
                            let value = baseValue * self.viewModel.pressure_max
                            return Text(String(format : "%.1f", value)).font(.largeTitle)
                        })
                    }
                }
            }
        }.frame(maxHeight: .infinity)
        
            .onAppear{
                for idx in 0...self.station.status.digital_valve_status.pressure.count - 1{
                    self.viewModel.pressure[idx] = self.station.status.digital_valve_status.pressure[idx] / self.viewModel.pressure_max
                }
            }
    }
}

extension PressureView{
    @Observable
    class ViewModel{
        var pressure : [Double] = [0.0,0.0,0.0,0.0]
        let pressure_max = 6.6
    }
}
