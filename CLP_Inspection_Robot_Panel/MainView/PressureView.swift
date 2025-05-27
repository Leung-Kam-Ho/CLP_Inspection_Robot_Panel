import SwiftUI
import Charts
import os

struct PressureView : View{
    @EnvironmentObject var digitalvalveStatus : DigitalValveStatusObject
    @EnvironmentObject var settings : SettingsHandler
    @State var viewModel = ViewModel()
    var enabled = true
    var body: some View{
        
        
        VStack{
            HStack{
                ForEach(1...4, id:\.self){ channel in
                    VStack{
                        let r = digitalvalveStatus.status.pressure[channel - 1] / self.viewModel.pressure_max
                        VerticalSlider(value: enabled ? self.$viewModel.pressure[channel - 1] : .constant(0), referenceValue: r, onEnd: {
                            if enabled{
                                let value = Float(self.viewModel.pressure[channel - 1] * self.viewModel.pressure_max)
                                DigitalValveStatusObject.setPressure(ip: settings.ip, port: settings.port, channel: channel - 1, pressure: Double(value))
                                Logger().info("\(viewModel.pressure)")
//                                _ = self.station.post_request("/pressure", value: [Float(channel - 1), value])
                            }
                        },icon: { _ in
                            return Image(systemName: "\(channel).circle.fill")
                        } ,text: { _ in
                            //                            return Image(systemName: "\(channel).circle.fill")
                            let baseValue = (enabled ? self.viewModel.pressure[channel - 1] : r)
                            let value = baseValue * self.viewModel.pressure_max
                            return Text((String(format : "%.1f", value)))
//                                .font(.tit)
                        }).multilineTextAlignment(.center)
                    }
                }
            }
        }.frame(maxHeight: .infinity)
            .contentTransition(.numericText(countsDown: true))
            .onAppear{
                for idx in 0...digitalvalveStatus.status.pressure.count - 1{
                    self.viewModel.pressure[idx] = digitalvalveStatus.status.pressure[idx] / self.viewModel.pressure_max
                }
            }
    }
}

extension PressureView{
    @Observable
    class ViewModel{
        var pressure : [Double] = [0.0,0.0,0.0,0.0]
        let pressure_max = 6.6
        let channel_name_map : [String] = ["Feet","Tank","EL-CID","Tapper"]
    }
}
