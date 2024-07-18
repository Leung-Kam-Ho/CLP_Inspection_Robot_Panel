import SwiftUI

struct LaunchPlatformView : View{
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    var enabled = true
    var compact = false
    var body: some View{
        let controlButton_F =
        Button(action:{
            MovePlatform()
        }){
            Image(systemName: "arrowtriangle.up.fill")
                .padding()
                .tint(.primary)
                .background(Capsule()
                    .fill(Constants.notBlack))
        }
        let controlButton_B =
        Button(action:{
            MovePlatform()
        }){
            Image(systemName: "arrowtriangle.down.fill")
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
                        if self.viewModel.show_slot{
                            let preview_slot =  Int(self.viewModel.previewLP_angle / 12) + 1
                            let slot = Int(self.station.status.launch_platform_status.angle / 12 + 1)
                            Text("Slot")
                                .foregroundStyle(Constants.offWhite)
                                .font(enabled && !compact ? .title : .caption)
                            Text("\(preview_slot)")
                                .tint(.primary)
                                .contentTransition(.numericText(countsDown: true))
                                .font(.system(size: enabled && !compact ? 200 : 70))
                            if enabled{
                                if slot == preview_slot{
                                    Text(" ")
                                        .font(compact ? .caption : .title)
                                    
                                }else{
                                    Button(action: {
                                        //go to function
                                        RotatePlatform(Angle: .degrees(0))
                                        
                                    }) {
                                        Label("Go to", systemImage: "arrow.right.circle.fill")
                                            .font(compact ? .caption : .title)
                                    }
                                }
                            }
                        }else{
                            Text("\(Int(self.viewModel.previewLP_angle))°")
                                .tint(.primary)
                                .contentTransition(.numericText(countsDown: true))
                                .font(.system(size: enabled && !compact ? 200 : 70))
                        }
                        
                    }
                    
                }
                
            })
        let LaunchPlatform_Drag_overlay =
        GeometryReader{ geometry in
            let length = min(geometry.size.height,geometry.size.width)
            LP_image
                .frame(maxWidth: .infinity,alignment: .center)
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
                            .offset(y: self.compact ? -150 : -410)
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
                                if self.viewModel.show_slot{
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
        }
        
        HStack{
            if !self.enabled{
                
                    Spacer()
                    LP_image
                    Spacer()
                
            }else if self.compact{
                VStack{
                    Spacer()
                    LaunchPlatform_Drag_overlay
//                    Spacer()
                    HStack{
                        VStack{
                            controlButton_F
                            controlButton_B
                        }.padding()
                            .background(Capsule()
                                .fill(.ultraThinMaterial))
                        
                    }
                }
            }else{
                LaunchPlatform_Drag_overlay
                    .overlay(alignment: .bottomLeading, content: {
                    VStack{
                        controlButton_F
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
        .padding()
        
        
    }
}

extension LaunchPlatformView{
    @Observable
    class ViewModel{
        var previewLP_angle_lastAngle = 0.0
        var previewLP_angle = 0.0
        let offset = 6.0
        var show_slot = true
        
        func closestMultipleOf12(for number: Int) -> Int {
            let remainder = number % 12
            return number - remainder + (remainder > 6 ? 12 : 0)
        }
        
    }
    
    func MovePlatform(value : Int = 0){
        
    }
    func RotatePlatform(Angle : Angle = .degrees(0)){
        
    }
    
    
    
}


#Preview {
    @Previewable @StateObject var station = Station()
    LaunchPlatformView()
        .environmentObject(station)
}
