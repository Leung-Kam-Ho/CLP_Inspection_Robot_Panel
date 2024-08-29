//
//  AudioSystemView.swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 28/8/2024.
//

import SwiftUI
import Charts

struct AudioSystemView: View {
    @EnvironmentObject var station: Station
    @State var viewModel = ViewModel()
    let bigEnough = UIScreen.main.traitCollection.userInterfaceIdiom == .pad
    var body: some View {
        let (data,y_data,x_data) = self.get_log()
        let y_domain = [data.min() ?? 0.0, (data.max() ?? 100.0 ) * 1.3]
        let x_domain = [0,data.count]
        VStack{
            Label("Audio System", systemImage: "waveform")
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundStyle(Constants.notBlack)
                .background(RoundedRectangle(cornerRadius: 25.0).fill(.white))
            GroupBox("Pulse in Audio"){
                Chart(Array(data.enumerated()), id:\.0){ nr,value in
                    LineMark(
                        x: .value("Time(s)", nr),
                        y: .value("Amplitude", value)
                    ).interpolationMethod(.cardinal).foregroundStyle(.indigo)
                }
                .chartYScale(domain: y_domain)
                .chartXScale(domain: x_domain)
                .chartXAxisLabel("Time(s)")
                .chartYAxisLabel("Amplitude")
            }.overlay(content: {
                if data.isEmpty{
                    Text("No Audio Record")
                }
            })
            .clipShape(.rect(cornerRadius: 25.0))
            GroupBox("Fourier Transform of the Pulse"){
                Chart(Array(y_data.enumerated()), id:\.0){ nr,value in
                    LineMark(
                        x: .value("Frequency(Hz)", x_data[nr]),
                        y: .value("Amplitude", value)
                    ).interpolationMethod(.cardinal).foregroundStyle(.green)
                }
                .chartYScale(domain: [y_data.min() ?? 0.0, (y_data.max() ?? 100.0 ) * 1.3])
                .chartXScale(domain: [x_data.min() ?? 0.0, (x_data.max() ?? 100.0)])
                .chartXAxisLabel("Frequency(Hz)")
                .chartYAxisLabel("Amplitude")
            }
            .clipShape(.rect(cornerRadius: 25.0))
            if bigEnough{
                HStack{
                    HStack{
                        HStack{
                            Text("Slot : ")
                            Picker("Audio Log", selection: $viewModel.slot_selection){
                                let list_of_slot = Array(Set(viewModel.audio_log.map{$0.slot}).sorted() )
                                Text("-")
                                    .tag(nil as Int?)
                                ForEach(list_of_slot, id: \.self){ slot in
                                    Text("\(slot)")
                                        .tag(slot)
                                }
                            }
                        }.padding()
                            .contentTransition(.numericText(countsDown: true))
                            .foregroundStyle(Constants.notBlack)
                            .background(Capsule().fill(.white))
                        HStack{
                            Text("Wedge : ")
                            Picker("Audio Log", selection: $viewModel.distance_selection){
                                let list_of_slot = Array(Set(viewModel.audio_log.map{$0.distance}).sorted() )
                                Text("-")
                                    .tag(nil as Int?)
                                ForEach(list_of_slot, id: \.self){ slot in
                                    Text("\(slot)")
                                        .tag(slot)
                                }
                            }
                        }.padding()
                            .contentTransition(.numericText(countsDown: true))
                            .background(Capsule().fill(.indigo))
                        HStack{
                            Text("No :")
                                
                            Picker("Audio Log", selection: $viewModel.file_num_selection){
                                let list_of_slot = Array(Set(viewModel.audio_log.map{$0.file_num}).sorted() )
                                Text("-")
                                    .tag(nil as Int?)
                                ForEach(list_of_slot, id: \.self){ slot in
                                    Text("\(slot)")
                                        .tag(slot)
                                }
                            }.foregroundStyle(Constants.notBlack)
                        }.padding()
                            .foregroundStyle(Constants.notBlack)
                            .background(Capsule().fill(Constants.offWhite))
                        Button(action:{
                            withAnimation{
                                refresh_Log()
                            }
                        }){
                            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                                .padding()
                                .foregroundStyle(Constants.notBlack)
                                .background(Circle().fill(.yellow))
                        }
                        .buttonStyle(.plain)
                        
                    }
                    .padding()
                    .background(Capsule().fill(.ultraThinMaterial))
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    HStack{
                        
                        Button(action:{
                            withAnimation{
                                viewModel.showingConfirmation.toggle()
                            }
                        }){
                            Image(systemName: "trash.fill")
                                .padding()
                                .background(Circle().fill(.red))
                        }
                        .buttonStyle(.plain)
                        .confirmationDialog("Clear Data", isPresented: $viewModel.showingConfirmation) {
                            Button("Clear", role: .destructive) { station.audio_log.removeAll() }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("Are you sure you want to clear the audio log?")
                        }
                    }
                    
                }.padding()
            }
            
                
        }
        .onAppear(perform: {
            withAnimation{
                refresh_Log()
            }
        })
        
    }
    func refresh_Log(){
        viewModel.audio_log = station.audio_log
        viewModel.distance_selection = viewModel.distance_selection ?? viewModel.audio_log.first?.distance ?? nil as Int?
        viewModel.slot_selection = viewModel.slot_selection ?? viewModel.audio_log.first?.slot ?? nil as Int?
        viewModel.file_num_selection = viewModel.file_num_selection ?? viewModel.audio_log.first?.file_num ?? nil as Int?
    }
}

struct RecordingButton: View {
    @EnvironmentObject var station: Station
    var body: some View {
        Button(action:{
            withAnimation{
                station.post_request("/record",value:!station.status.audio_status.recording)
            }
        }){
            ZStack{
                Image(systemName: "waveform")
                    .foregroundStyle(.clear)
                Image(systemName: station.status.audio_status.recording ? "stop.fill" : "waveform")
                    
                    
            }.padding().background(Circle().fill(.red))
        }
        .buttonStyle(.plain)
    }
}

extension AudioSystemView{
    @Observable
    class ViewModel {
        var audio_log = [Station.Audio_Status]()
        var showingConfirmation = false
        var slot_selection : Int? = nil as Int?
        var distance_selection : Int? = nil as Int?
        var file_num_selection : Int? = nil as Int?
    }
    
    func get_log() -> ([Float],[Float],[Float]){
            let log = viewModel.audio_log.filter({$0.file_num == viewModel.file_num_selection && $0.slot == viewModel.slot_selection && $0.distance == viewModel.distance_selection})
            if log.isEmpty{
                return ([Float](),[Float](),[Float]())
            }
            let audio_log = log.first!
            return (audio_log.Audio,audio_log.FFT,audio_log.FFT_freq)
    }
    
}
