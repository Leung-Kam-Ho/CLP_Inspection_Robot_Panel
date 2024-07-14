import SwiftUI

struct LaunchPlatformView : View{
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    var enabled = true
    var body: some View{
        ZStack(alignment: .center){
            if self.viewModel.show_slot{
                let slot =  Int(self.station.status.launch_platform_status.angle / 12) + 1
                Image(systemName: "\(slot).circle.fill")
                    .tint(.primary)
            }else{
                
                let display_text = String(self.station.status.launch_platform_status.angle)  + "°"
                ZStack{
                    Circle()
                        .tint(.primary)
                    Text(display_text)
                }
            }
            Image("LaunchPlatform")
                .resizable()
                .padding()
                .tint(.primary)
                .aspectRatio(contentMode: .fit)
                .rotationEffect(.degrees(Double(self.station.status.launch_platform_status.angle)))
        }.frame(maxHeight: .infinity)
            
            
    }
}

extension LaunchPlatformView{
    @Observable
    class ViewModel{
        var show_slot = true
    }
}
