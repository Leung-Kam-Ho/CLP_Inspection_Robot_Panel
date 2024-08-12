import SwiftUI

struct LaunchPlatformView : View{
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    var enabled = true
    var compact = false
    var body: some View{
        let connectIcon =
        Image(systemName: "link.circle.fill")
            .padding()
            .background(Circle().fill(self.station.status.launch_platform_status.connected ? .green : .red))
        let controlButton_F =
        Button(action:{
            MovePlatform(value: 1)
        }){
            Image(systemName: "arrowtriangle.up.fill")
                .padding()
                .tint(.primary)
                .background(Capsule()
                    .fill(Constants.notBlack))
        }
        let controlButton_B =
        Button(action:{
            MovePlatform(value : -1)
        }){
            Image(systemName: "arrowtriangle.down.fill")
                .padding()
                .tint(.primary)
                .background(Capsule()
                    .fill(Constants.notBlack))
            
        }
        let controlButton_S =
        Button(action:{
            MovePlatform(value: 0)
        }){
            Image(systemName: "stop.fill")
                .padding()
                .tint(.primary)
                .background(Capsule()
                    .fill(Constants.notBlack))
            
        }
        let LP_image =
        Image("LaunchPlatform")
            .resizable()
            .padding()
            .tint(.primary)
            .aspectRatio(contentMode: .fit)
            .rotationEffect(.degrees(Double(self.station.status.launch_platform_status.angle)))
            .overlay(alignment: .center, content: {
                ZStack{
                    Image(systemName: "circle.fill")
                        .font(.system(size: enabled && !compact ? 400 : 150))
                        .foregroundStyle(.ultraThickMaterial)
                    VStack{
                        let preview_slot =  Int(self.viewModel.previewLP_angle / 12) + 1
                        let slot = Int(self.station.status.launch_platform_status.angle / 12 + 1)
                        Text("Slot")
                            .foregroundStyle(Constants.offWhite)
                            .font(enabled && !compact ? .title : .caption)
                        Text(enabled ? String(format : "%02d",preview_slot) : String(format : "%02d",slot))
                            .tint(.primary)
                            .contentTransition(.numericText(countsDown: true))
                            .font(.system(size: enabled && !compact ? 200 : 70))
                    }
                    
                }
                
            })
        let LaunchPlatform_Drag_overlay =
        GeometryReader{ geometry in
            
            VStack{
                Spacer()
                let length = min(geometry.size.height,geometry.size.width)
                LP_image
                    .frame(maxWidth: .infinity ,alignment: .center)
                    .padding()
                    .overlay(content: {
                        ZStack{
                            Image("LaunchPlatform")
                                .resizable()
                                .padding()
                                .frame(maxWidth: .infinity,alignment: .center)
                                .opacity(0.5)
                                .aspectRatio(contentMode: .fit)
                            Image(systemName: "arrow.left.and.right.circle.fill")
                                .offset(y: length / -2)
                                .foregroundStyle(.orange)
                        }
                        .rotationEffect(.degrees(self.viewModel.previewLP_angle))
                        .padding()
                        .gesture(DragGesture()
                            .onChanged{ v in
                                var theta = (atan2(v.location.x - length / 2, length / 2 - v.location.y) - atan2(v.startLocation.x - length / 2, length / 2 - v.startLocation.y)) * 180 / .pi
                                if (theta < 0) { theta += 360 }
                                let result = Double(Int(theta + self.viewModel.previewLP_angle_lastAngle)).truncatingRemainder(dividingBy: 360)
                                withAnimation(.easeInOut(duration: 0.2)){
                                    if viewModel.locked{
                                        self.viewModel.previewLP_angle = Double(self.viewModel.closestMultipleOf12(for: Int(result))) + self.viewModel.offset
                                    }else{
                                        self.viewModel.previewLP_angle = result + self.viewModel.offset
                                    }
                                    
                                    self.viewModel.previewLP_angle = self.viewModel.previewLP_angle.truncatingRemainder(dividingBy: 360)
                                }
                            }
                            .onEnded { v in
                                self.viewModel.previewLP_angle_lastAngle = self.viewModel.previewLP_angle
                            }
                        )
                    })
                Spacer()
            }
        }
        .frame(maxHeight: 828.0, alignment : .center)
        
        
        HStack{
            if !self.enabled{
                Spacer()
                LP_image
                Spacer()
                
            }else{
                VStack{
                    LaunchPlatform_Drag_overlay
                        .frame(maxHeight: .infinity, alignment : .center)
                }.overlay(alignment: .topLeading, content: {
                    // show image whether the launchplatform is connected
                    connectIcon
                })
                .overlay(alignment: .topTrailing, content: {
                    let ang = self.station.status.launch_platform_status.angle
                    let tar = Int(viewModel.previewLP_angle)
                    VStack(alignment : .trailing){
                        Text("curPos : \(String(format: "%03d", ang))°")
                            .padding()
                            .background(Capsule()
                                .fill(.ultraThinMaterial))
                        Text("Target : \(String(format: "%03d", tar))°")
                            .padding()
                            .background(Capsule()
                                .fill(.ultraThinMaterial))
                    }.contentTransition(.numericText(countsDown: true))
                })
                .overlay(alignment: .bottomLeading, content: {
                    VStack(alignment : .leading){
                        Button(action: {
                            //go to function
                            RotatePlatform(Angle: .degrees(viewModel.previewLP_angle))
                            
                        }) {
                            Label("Go To", systemImage: "return.right")
                                .padding()
                                .background(Capsule()
                                    .fill(.ultraThinMaterial))
                        }
                        Button(action:{
                            withAnimation{
                                viewModel.locked.toggle()
                            }
                        }){
                            Label(viewModel.locked ? "30 Slots" : "360 Degrees", systemImage: viewModel.locked ? "lock.fill" : "lock.open.fill")
                                .padding()
                                .background(Capsule()
                                    .fill(.ultraThinMaterial))
                        }
                    }
                    
                })
                .overlay(alignment: .bottomTrailing, content: {
                    VStack{
                        controlButton_F
                        controlButton_S
                        controlButton_B
                    }.padding()
                        .background(Capsule()
                            .fill(.ultraThinMaterial))
                })
                
                
            }
            
        }
        .onAppear{
            self.viewModel.previewLP_angle = Double(self.station.status.launch_platform_status.angle)
            self.viewModel.previewLP_angle_lastAngle = self.viewModel.previewLP_angle
            
        }
        .frame(maxHeight: .infinity)
        
        
        
    }
}

extension LaunchPlatformView{
    @Observable
    class ViewModel{
        var previewLP_angle_lastAngle = 0.0
        var previewLP_angle = 0.0
        let offset = 6.0
        var show_slot = true
        var locked = true
        
        func closestMultipleOf12(for number: Int) -> Int {
            let remainder = number % 12
            return number - remainder + (remainder > 6 ? 12 : 0)
        }
        
    }
    
    func MovePlatform(value : Int = 0){
        // negative is backward, positive is forward, 0 is stop
        station.post_request("/launch_platform_movement",value: [value])
    }
    func RotatePlatform(Angle : Angle = .degrees(0)){
        print(Angle.degrees)
        station.post_request("/launch_platform",value: [Int(Angle.degrees)])
    }
    
    
    
}


#Preview {
    @Previewable @StateObject var station = Station()
    LaunchPlatformView()
        .environmentObject(station)
}
