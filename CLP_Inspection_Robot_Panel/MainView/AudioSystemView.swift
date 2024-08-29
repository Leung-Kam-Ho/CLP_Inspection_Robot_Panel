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
    let bigEnough = UIScreen.main.traitCollection.userInterfaceIdiom == .pad
    var body: some View {
        let data = self.station.status.audio_status.most_recent_Audio
        let y_data = self.station.status.audio_status.most_recent_FFT
        let x_data = self.station.status.audio_status.most_recent_FFT_freq
        VStack{
            Label("Audio System", systemImage: "waveform")
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundStyle(Constants.notBlack)
                .background(RoundedRectangle(cornerRadius: 25.0).fill(.white))
            GroupBox("Most recent Audio data"){
                Chart(Array(data.enumerated()), id:\.0){ nr,value in
                    LineMark(
                        x: .value("Time(s)", nr),
                        y: .value("Amplitude", value)
                    ).interpolationMethod(.cardinal).foregroundStyle(.indigo)
                }
                .chartYScale(domain: [data.min() ?? 0.0, (data.max() ?? 100.0 ) * 1.3])
                .chartXScale(domain: [0,data.count])
                .chartXAxisLabel("Time(s)")
                .chartYAxisLabel("Amplitude")
            }.overlay(content: {
                if data.isEmpty{
                    
                    Text("No Audio Record")
                }
            })
            .clipShape(.rect(cornerRadius: 25.0))
            GroupBox("Fourier Transform of the most recent audio data"){
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
                        SlotView()
                        WedgeView()
                    }
                    .padding()
                    .background(Capsule().fill(.ultraThinMaterial))
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)

                    RecordingButton()
                }.padding()
            }
            
                
        }
        
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
