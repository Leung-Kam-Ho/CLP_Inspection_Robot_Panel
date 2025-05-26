import SwiftUI
import os


struct LaunchPlatformView : View{
    @EnvironmentObject var digitalValveStatus : DigitalValveStatusObject
    @EnvironmentObject var launchPlatformStatus : LaunchPlatformStatusObject
    @EnvironmentObject var elcidStatus : ElCidStatusObject
    @EnvironmentObject var settings : SettingsHandler
    @State var viewModel = ViewModel()
    var enabled = true
    var compact = false
    @State var show_slot = true
    var title = true
    var body: some View{
        let img_list = ["arrow.left.arrow.right.circle.fill","lock.circle.fill","popcorn.circle.fill","lifepreserver.fill"]
        let LP_image =
        Image("LaunchPlatform")
            .resizable()
            .padding()
            .tint(.primary)
            .aspectRatio(contentMode: .fit)
            .rotationEffect(.degrees(Double(launchPlatformStatus.status.angle)))
            .overlay(alignment: .center, content: {
                ZStack{
                    Image(systemName: "circle.fill")
                        .font(.system(size: enabled && !compact ? 400 : 150))
                        .foregroundStyle(.ultraThickMaterial)
                    Button(action:{
                        show_slot.toggle()
                    }){
                        VStack(alignment:.center){
                            let fractionalPart : Double = enabled ? Double(self.viewModel.previewLP_angle - Double(Int(self.viewModel.previewLP_angle))) : Double(launchPlatformStatus.status.angle - Float(Int(launchPlatformStatus.status.angle)))
                            let slot : Int = enabled ? Int(self.viewModel.previewLP_angle / Constants.SLOT_DISTANCE_DEGREE) + 1 : Int(launchPlatformStatus.status.angle / Float(Constants.SLOT_DISTANCE_DEGREE)) + 1
                            
                            

                            if show_slot{
                                Text("Slot")
                                    .foregroundStyle(Constants.offWhite)
                                    .font(enabled && !compact ? .title : .caption)
                                Text(String(format : "%02d",Int(slot)))
                                    .tint(.primary)
                                    .contentTransition(.numericText(countsDown: true))
                                    .font(.system(size: enabled && !compact ? 200 : 70))
                            }else{
                                Text("Angle")
                                    .foregroundStyle(Constants.offWhite)
                                    .font(enabled && !compact ? .title : .caption)
                                Text(enabled ? String(format : "%03d",Int(self.viewModel.previewLP_angle)) : String(format : "%03d",Int(launchPlatformStatus.status.angle)))
                                    .tint(.primary)
                                    .contentTransition(.numericText(countsDown: true))
                                    .font(.system(size: enabled && !compact ? 180 : 50))
                                
                                Text(String(format : "%02d",Int(fractionalPart*100)))
                                    .foregroundStyle(Constants.offWhite)
                                    .font(enabled && !compact ? .title : .caption)
                            }
                            
                            
                        }
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
                                .foregroundStyle(.blue)
                        }
                        .rotationEffect(.degrees(self.viewModel.previewLP_angle))
                        .padding()
                        .gesture(DragGesture()
                            .onChanged{ v in
                                var theta = (atan2(v.location.x - length / 2, length / 2 - v.location.y) - atan2(v.startLocation.x - length / 2, length / 2 - v.startLocation.y)) * 180 / .pi
                                if (theta < 0) { theta += 360 }
                                let result = Double((theta + self.viewModel.previewLP_angle_lastAngle)).truncatingRemainder(dividingBy: 360)
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
            }.scaleEffect(0.9)
        }
        .frame(maxHeight: 828.0, alignment : .center)
        
        
        HStack{
            if !self.enabled{
                VStack{
                    Spacer()
                    LP_image
                    Spacer()
                    HStack{
                        ForEach(1...4, id:\.self){ idx in
                            Button(action:{
//                                _ = self.station.post_request("/relay_launch_platform", value: [idx-1])
                            }){
                                let s = launchPlatformStatus.status.relay
                                let index = s.index(s.startIndex, offsetBy: idx-1)
                                let state : String = String(launchPlatformStatus.status.relay[index])
                                
                                Image(systemName: img_list[idx-1])
                                    .padding()
                                    .tint(.primary)
                                    .background( Circle()
                                        .fill(state == "1" ? .orange : Constants.notBlack))
                                
                            }.keyboardShortcut(KeyEquivalent(Character("\(idx)")),modifiers: [])
                            if idx != 4{
                                
                                Spacer()
                            }
                        }
                        
                    }
                }
                
                
            }else{
                VStack{
                    if title{
                        Label("Launch Platform", systemImage: "chart.bar.yaxis")
                            .padding()
                            .padding(.vertical)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 33.0).fill(launchPlatformStatus.status.connected ? .orange : .red))
                    }
                    LaunchPlatform_Drag_overlay
                        .frame(maxHeight: .infinity, alignment : .top)
                        .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial))
                        .overlay(alignment: .bottom, content: {
                            Text(String(format:"%05d",launchPlatformStatus.status.lazer))
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 33).fill(.red))
                                .padding()
                        })
                    HStack{
                        
                        VStack{
                            Text("Setpoint")
                            Button(action: {
                                //go to function
                                
                                launchPlatformStatus.RotatePlatform(ip:settings.ip, port : settings.port, value: .degrees(viewModel.previewLP_angle))
                                
                            }) {
                                Text(String(format:"%05.1f",Float(viewModel.previewLP_angle)))
                                    .padding()
                                    .background(Capsule().fill(Constants.notBlack))
                            }
                            Button(action:{
                                withAnimation{
                                    viewModel.locked.toggle()
                                }
                            }){
                                
                                Text(viewModel.locked ? "Slots" : "Deg")
                                    .padding()
                                    .background(Capsule().fill(Constants.notBlack))
                              
                            }
                        }.lineLimit(1)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial))
                        if !compact{
                            VStack{
                                Text("Info")
                                let ang = launchPlatformStatus.status.angle
                                let tar = launchPlatformStatus.status.setpoint
                                Text(String(format: "curPos : °%05.1f ", ang))
                                    .contentTransition(.numericText(countsDown: true))
                                    .padding()
                                    .lineLimit(1)
                                    .background(Capsule()
                                        .fill(.ultraThinMaterial))
                                Text("Tar :\(String(format: "%05.1f", tar))°")
                                    .padding()
                                    .background(Capsule().fill(Constants.notBlack))
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial))
                        }
                        VStack{
                            Text("Relay")
                            HStack{
                                ForEach(1...2, id:\.self){ idx in
                                    Button(action:{
//                                        _ = self.station.post_request("/relay_launch_platform", value: [idx-1])
                                    }){
                                        let s = launchPlatformStatus.status.relay
                                        let index = s.index(s.startIndex, offsetBy: idx-1)
                                        let state : String = String(launchPlatformStatus.status.relay[index])
                                        
                                        Image(systemName: img_list[idx-1])
                                            .padding()
                                            .tint(.primary)
                                            .background( Circle()
                                                .fill(state == "1" ? .orange : Constants.notBlack))
                                        
                                    }.keyboardShortcut(KeyEquivalent(Character("\(idx)")),modifiers: [])
                                }
                            }
                            HStack{
                                ForEach(3...4, id:\.self){ idx in
                                    Button(action:{
//                                        _ = self.station.post_request("/relay_launch_platform", value: [idx-1])
                                    }){
                                        let s = launchPlatformStatus.status.relay
                                        let index = s.index(s.startIndex, offsetBy: idx-1)
                                        let state : String = String(launchPlatformStatus.status.relay[index])
                                        
                                        Image(systemName: img_list[idx-1])
                                            .padding()
                                            .tint(.primary)
                                            .background( Circle()
                                                .fill(state == "1" ? .orange : Constants.notBlack))
                                        
                                    }.keyboardShortcut(KeyEquivalent(Character("\(idx)")),modifiers: [])
                                }
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial))
                       
                        
                    }
                    
                }
                
            }
            
        }
        .sensoryFeedback(.impact(weight:.heavy), trigger: viewModel.success, condition: { old, new in
            if new{
                Logger().info("sucess")
                viewModel.success = false
                return true
            }
            return false
            
        })
        .onAppear{
            self.viewModel.previewLP_angle = Double(launchPlatformStatus.status.angle)
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
        var locked = false
        var show_Relay = true
        var success = false
        
        func closestMultipleOf12(for number: Int) -> Int {
            let remainder = number % Int(Constants.SLOT_DISTANCE_DEGREE)
            return number - remainder + (remainder > 6 ? Int(Constants.SLOT_DISTANCE_DEGREE) : 0)
        }

        
    }
    
    func MovePlatform(value : Int = 0){
        // negative is backward, positive is forward, 0 is stop
//        viewModel.success = station.post_request("/launch_platform_movement",value: [value])
    }
    
}

#Preview {
    @Previewable var launchPlatformStatus = LaunchPlatformStatusObject()
    @Previewable var settings = SettingsHandler()
    LaunchPlatformView()
        .environmentObject(launchPlatformStatus)
        .environmentObject(settings)
        
}
