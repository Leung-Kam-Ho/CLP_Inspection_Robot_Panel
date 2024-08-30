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
                            HStack{
                                Picker("Date",selection: $viewModel.date_selection){
                                    let list_of_slot = Array(Set(viewModel.audio_log.map{$0.date}).sorted() )
                                    Section("Date"){
                                        
                                        ForEach(list_of_slot, id: \.self){ slot in
                                            Text("\(slot)")
                                                .tag(slot)
                                        }
                                        Text("-")
                                            .tag(nil as String?)
                                    }
                                }
                            }
                            HStack{
                                Picker("Slot", selection: $viewModel.slot_selection){
                                    let list_of_slot = Array(Set(viewModel.audio_log.filter({$0.date == viewModel.date_selection}).map{$0.slot}).sorted() )
                                    Section("Slot"){
                                        ForEach(list_of_slot, id: \.self){ slot in
                                            Text("\(slot)")
                                                .tag(slot)
                                        }
                                        Text("-")
                                            .tag(nil as Int?)
                                    }
                                }
                            }
                            HStack{
                                Picker("Wedge", selection: $viewModel.distance_selection){
                                    let list_of_slot = Array(Set(viewModel.audio_log.filter({$0.date == viewModel.date_selection && $0.slot == viewModel.slot_selection}).map{$0.distance}).sorted() )
                                    Section("Wedge"){
                                        ForEach(list_of_slot, id: \.self){ slot in
                                            Text("\(slot)")
                                                .tag(slot)
                                        }
                                        Text("-")
                                            .tag(nil as Int?)
                                    }
                                }
                            }
                            HStack{
                                Picker("Number", selection: $viewModel.file_num_selection){
                                    let list_of_slot = Array(Set(viewModel.audio_log.filter({$0.date == viewModel.date_selection && $0.slot == viewModel.slot_selection && $0.distance == viewModel.distance_selection}).map{$0.file_num}).sorted() )
                                    Section("Audio Number"){
                                        ForEach(list_of_slot, id: \.self){ slot in
                                            Text("\(slot)")
                                                .tag(slot)
                                        }
                                        Text("-")
                                            .tag(nil as Int?)
                                    }
                                }.foregroundStyle(Constants.notBlack)
                            }
                        }
                        .padding()
                            .contentTransition(.numericText(countsDown: true))
                            .foregroundStyle(Constants.notBlack)
                            .background(Capsule().fill(.white))
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
                                viewModel.showingOption.toggle()
                            }
                        }){
                            Image(systemName: "option")
                                .padding()
                                .background(Circle().fill(.red))
                        }
                        .buttonStyle(.plain)
                        
                        .confirmationDialog("Option", isPresented: $viewModel.showingOption) {
                            Button("Download") { download_log() }
                            Button("Upload") {}
                            Button("Delete", role: .destructive) {
//                                download_log()
                                viewModel.showingConfirmation = true
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("Please select an action")
                        }
                    }
                }.padding()
                    .confirmationDialog("Clear Data", isPresented: $viewModel.showingConfirmation) {
                    Button("Delete", role: .destructive) {
//                                download_log()
                        station.audio_log.removeAll()
                        station.save_audio_to_user_defaults()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to clear the audio log?")
                }
            }
        }
        .alert("File Save Failed", isPresented: $viewModel.showAlert, actions: {
            Button(action:{
                
            }){
                Text("OK")
            }
        })
        .fileExporter(isPresented: $viewModel.showingExporter, document: viewModel.Document, contentType: .plainText) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .onAppear(perform: {
            withAnimation{
                refresh_Log()
            }
        })
        
    }
    func download_log(){
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(viewModel.audio_log) {
            let str = String(decoding: data, as: UTF8.self)
            viewModel.Document.text = str
            viewModel.showingExporter = true
        }else{
            viewModel.showAlert = true
        }
    }
    func refresh_Log(){
        viewModel.audio_log = station.audio_log
        viewModel.date_selection = viewModel.audio_log.last?.date ?? nil as String?
        viewModel.distance_selection = viewModel.audio_log.last?.distance ?? nil as Int?
        viewModel.slot_selection = viewModel.audio_log.last?.slot ?? nil as Int?
        viewModel.file_num_selection = viewModel.audio_log.last?.file_num ?? nil as Int?
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
        var Document = TextFile()
        var audio_log = [Station.Audio_Status]()
        var showingOption = false
        var showingConfirmation = false
        var showingExporter = false
        var showAlert = false
        var slot_selection : Int? = nil as Int?
        var distance_selection : Int? = nil as Int?
        var file_num_selection : Int? = nil as Int?
        var date_selection : String? = nil as String?
    }
    
    func get_log() -> ([Float],[Float],[Float]){
        let log = viewModel.audio_log.filter({$0.file_num == viewModel.file_num_selection && $0.slot == viewModel.slot_selection && $0.distance == viewModel.distance_selection && $0.date == viewModel.date_selection})
            if log.isEmpty{
                return ([Float](),[Float](),[Float]())
            }
            let audio_log = log.first!
            return (audio_log.Audio,audio_log.FFT,audio_log.FFT_freq)
    }
    
}
