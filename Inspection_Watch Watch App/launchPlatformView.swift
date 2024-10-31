//
//  launchPlatformView.swift
//  Inspection_Watch Watch App
//
//  Created by Kam Ho Leung on 18/10/2024.
//

import SwiftUI
import os
import CoreMotion
import UIKit

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
                            if viewModel.outputMode == .Motion{
                                if !viewModel.motion.isDeviceMotionActive{
                                    viewModel.startDeviceMotion()
                                }else{
                                    viewModel.stopDeviceMotion()
                                }
                            }else{
                                setAngle()
                            }
                            
                        }){
                            switch viewModel.outputMode {
                            case .Continuous:
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
                                .background(
                                    RoundedRectangle(cornerRadius:25)
                                        .fill(.ultraThinMaterial)
                                )
                            case .SetAndPress:
                                VStack{
                                    let ang = self.station.status.launch_platform_status.angle
                                    Text(String(format: "curPos:", ang))
                                    Text(String(format: "%05.1f°", ang))
                                        .foregroundStyle(.blue)
                                        .contentTransition(.numericText(countsDown: true))
                                        .bold()
                                        .font(.title2)
                                        .padding([.horizontal])
                                    
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius:25)
                                        .fill(.ultraThinMaterial)
                                )
                            case .Motion:
                                Image(systemName: viewModel.motion.isDeviceMotionActive ? "stop.fill" : "play.fill")
                                    .padding()
                                    .background(Circle().fill(viewModel.motion.isDeviceMotionActive ? .red : .green))
                                    .font(.title)
                            }
                            
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
            .digitalCrownRotation($viewModel.setpoint, from: 0, through: 359, by: 0.1, sensitivity: .high, isContinuous: true, isHapticFeedbackEnabled: true)
            .onChange(of: viewModel.setpoint, { oldValue, newValue in
                let same = round(10 * oldValue) == round(10 * newValue)
                if viewModel.outputMode != .SetAndPress && !same{
                    setAngle()
                }
            })
            .ignoresSafeArea(.all,edges:[.bottom,.top])
            .toolbarRole(.navigationStack)
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            .sensoryFeedback(.impact(weight:.heavy), trigger: viewModel.success, condition: { old, new in
                if new{
                    viewModel.success = false
                    return true
                }
                return false
            })
            Picker("Output Mode", selection: $viewModel.outputMode, content: {
                ForEach(OutputMode.allCases, id:\.self){ mode in
                    Text(mode.rawValue)
                }
            })
        }
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
    func setAngle(){
        let setpoint = Double(round(10 * viewModel.setpoint) / 10)
        let sent = station.RotatePlatform(Angle: .degrees(setpoint))
        viewModel.success = sent
        Logger().info("\(sent)")
    }
    @Observable
    class ViewModel{
        var setpoint : Double = 0.0
        var outputMode : OutputMode = .Continuous
        let motion = CoreMotion.CMMotionManager()
        let imu = IMU()
        var timer : Timer?
        var success = false

        init() {
            // Configure a timer to fetch the motion data.
            self.timer = Timer(fire: Date(), interval: (1.0 / 50.0), repeats: true,
                               block: { (timer) in
                if let data = self.motion.deviceMotion {
                    // Get the attitude relative to the magnetic north reference frame.
                    self.imu.pitch = data.attitude.pitch
                    self.imu.roll = data.attitude.roll
                    self.imu.yaw = data.attitude.yaw
                    Logger().info("\(Angle(radians:self.imu.roll).degrees) \(Angle(radians:self.imu.pitch).degrees) \(Angle(radians:self.imu.yaw).degrees)")
                    self.setpoint = Angle(radians: self.imu.roll).degrees
                }
            })
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
        }
        

        func startDeviceMotion() {
            if motion.isDeviceMotionAvailable {
                self.motion.deviceMotionUpdateInterval = 1.0 / 50.0
                self.motion.showsDeviceMovementDisplay = true
                self.motion.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
                
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
