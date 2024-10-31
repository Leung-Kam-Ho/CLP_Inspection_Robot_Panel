//
//  ContentView.swift
//  Inspection_Watch Watch App
//
//  Created by Kam Ho Leung on 17/10/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    var body: some View {
        VStack{
            NavigationStack{
                List{
                    HStack{
                        Text("Server")
                        Spacer()
                        Image(systemName: station.connected ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(station.connected ?.green : .red)
                    }
                    HStack{
                        Text("Robot")
                        Spacer()
                        Image(systemName: station.status.robot_status.connected ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(station.status.robot_status.connected ?.green : .red)
                    }
                    HStack{
                        Text("Valve")
                        Spacer()
                        Image(systemName: station.status.digital_valve_status.connected ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(station.status.digital_valve_status.connected ?.green : .red)
                    }
                    Button(action:{
                        viewModel.show_launchPlatform = true
                    }){
                        HStack{
                            Text("Launcher")
                            Spacer()
                            Image(systemName: station.status.launch_platform_status.connected ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(station.status.launch_platform_status.connected ?.green : .red)
                        }
                    }.navigationDestination(isPresented: $viewModel.show_launchPlatform, destination: {
                        launchPlatformView()
                    })
                    
                    HStack{
                        Text("El-CID")
                        Spacer()
                        Image(systemName: station.status.el_cid_status.connected ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(station.status.el_cid_status.connected ? .green : .red)
                    }
                    HStack{
                        Text("Tapper")
                        Spacer()
                        Image(systemName: station.connected ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(station.status.audio_status.connected ?.green : .red)
                    }
                    TextField("Enter custom IP", text: $viewModel.custom_ip)
                        .onSubmit {
                            station.ip = viewModel.custom_ip
                        }
                    
                }.padding(.horizontal)
                
            }
          
        }
        
        .bold()
        .preferredColorScheme(.dark)
        .onReceive(station.timer, perform: station.updateData)
        .monospacedDigit()

    }
    
}

extension ContentView{
    @Observable
    class ViewModel{
        var showAlert = false
        var custom_ip = "192.168.10.5"
        var show_launchPlatform = false
    }
}

#Preview {
    ContentView()
}
