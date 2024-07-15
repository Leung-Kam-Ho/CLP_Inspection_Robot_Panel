//
//  CameraView.swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 15/7/2024.
//

import SwiftUI

struct CameraView: View {
    @EnvironmentObject var station: Station
    var body: some View {
        VStack{
            Image(uiImage: self.station.camera_frames)
                .resizable()
                .clipShape(.rect(cornerRadius: 25.0))
                .padding()
                .background(Image("Watermark"))
        }.overlay(alignment: .bottomTrailing, content: {
            Button(action:{
                withAnimation{
                    self.station.getImage.toggle()
                }
            }){
                Image(systemName: self.station.getImage ? "pause.fill" : "play.fill")
                    .tint(.primary)
                    .padding()
                    .background(Circle().fill(self.station.getImage ? .red : .green))
                    .padding()
                    .padding()
            }
                
        })
    }
}


#Preview {
    CameraView()
}
