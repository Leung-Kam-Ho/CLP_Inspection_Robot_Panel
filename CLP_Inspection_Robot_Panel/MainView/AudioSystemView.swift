//
//  AudioSystemView.swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 28/8/2024.
//

import SwiftUI
import Charts
import os

struct EL_CID_TriggerButton: View {
    @EnvironmentObject var elcidStatus : ElCidStatusObject
    @EnvironmentObject var settings: SettingsHandler
    var body: some View {
        Button(action:{
//            _ = station.post_request("/EL_CID",value: true)
            elcidStatus.setRelay(ip: settings.ip, port: settings.port, state: true)
        }){
            Text("EL-CID")
                .foregroundStyle(elcidStatus.status.connected ? (elcidStatus.status.relay_state == 0 ? .green : .orange ): .red)
                .padding().background(Capsule().fill(Constants.notBlack))
                .onLongPressGesture(minimumDuration: 1,perform: {
                    elcidStatus.setRelay(ip: settings.ip, port: settings.port, state: false)
                    Logger().info("Reset EL-CID")
                })
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    @Previewable var settings = SettingsHandler()
    @Previewable var elcidStatus = ElCidStatusObject()
    EL_CID_TriggerButton()
        .environmentObject(settings)
        .environmentObject(elcidStatus)
}
