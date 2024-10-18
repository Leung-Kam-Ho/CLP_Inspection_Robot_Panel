//
//  launchPlatformView.swift
//  Inspection_Watch Watch App
//
//  Created by Kam Ho Leung on 18/10/2024.
//

import SwiftUI
import CoreMotion

struct launchPlatformView: View {
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    var body: some View {
        TabView{
            VStack{
                Image("LaunchPlatform")
                    .resizable()
                    .focusable(true)
                    .rotationEffect(.degrees(viewModel.setpoint))
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .padding()
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                    .overlay(content: {
                        Button(action:{
                            setAngle()
                        }){
                            VStack{
                                let ang = self.station.status.launch_platform_status.angle
                                Text(String(format: "curPos:", ang))
                                Text(String(format: "%05.1f°", ang))
                                    .contentTransition(.numericText(countsDown: true))
                                    .bold()
                                    .font(.title2)
                                    .padding([.horizontal])
                                
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius:25).fill(.ultraThinMaterial))
                        }.buttonStyle(.plain)
                        
                        
                        
                    })
                    .overlay(alignment:.bottom, content: {
                        Text(String(format:"setpoint : %05.1f", viewModel.setpoint))
                            .padding()
                            .background(Capsule().fill(.ultraThickMaterial))
                        
                    })
                
            }
            .onAppear(perform: {
                viewModel.setpoint = Double(station.status.launch_platform_status.angle)
            })
            
            .digitalCrownRotation($viewModel.setpoint, from: 0, through: 359, by: 0.1, sensitivity: .low, isContinuous: true, isHapticFeedbackEnabled: true)
            .onChange(of: viewModel.setpoint, { oldValue, newValue in
                if viewModel.outputMode != .SetAndPress{
                    setAngle()
                }
            })
            .onChange(of: viewModel.outputMode, { oldValue, newValue in
                if newValue == .Motion{
                    viewModel.startDeviceMotion()
                }else{
                    viewModel.stopDeviceMotion()
                }
            })
            .ignoresSafeArea(.all,edges:[.bottom,.top])
            .toolbarRole(.navigationStack)
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            Picker("Output Mode", selection: $viewModel.outputMode, content: {
                ForEach(OutputMode.allCases, id:\.self){ mode in
                    Text(mode.rawValue)
                }
            })
        }
    }
    func setAngle(){
        station.RotatePlatform(Angle: .degrees(viewModel.setpoint))
        print("set")
    }
}

extension launchPlatformView{
    enum OutputMode : String, CaseIterable{
        case Continuous
        case SetAndPress
        case Motion
    }
    class IMU{
        var roll : Double = 0
        var pitch : Double = 0
        var yaw : Double = 0
    }
    @Observable
    class ViewModel{
        var setpoint : Double = 0.0
        var outputMode : OutputMode = .Continuous
        let motion = CoreMotion.CMMotionManager()
        let imu = IMU()
        var timer : Timer?
        var queue = OperationQueue()
        

        func startDeviceMotion() {
            if motion.isDeviceMotionAvailable {
                self.motion.deviceMotionUpdateInterval = 1.0 / 5.0
                self.motion.showsDeviceMovementDisplay = true
                self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
                
                // Configure a timer to fetch the motion data.
                self.timer = Timer(fire: Date(), interval: (1.0 / 5.0), repeats: true,
                                   block: { (timer) in
                                    if let data = self.motion.deviceMotion {
                                        // Get the attitude relative to the magnetic north reference frame.
                                        self.imu.pitch = data.attitude.pitch
                                        self.imu.roll = data.attitude.roll
                                        self.imu.yaw = data.attitude.yaw
                                        print(self.imu)
                                        self.setpoint = self.imu.pitch
                                    }
                })
                
                // Add the timer to the current run loop.
                RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
            }else{
                print("Motion Not Avaliable")
            }
        }
        
        func stopDeviceMotion(){
            motion.stopDeviceMotionUpdates()
        }
    }
}

#Preview {
    @Previewable var station = Station()
    launchPlatformView()
        .environmentObject(station)
}
