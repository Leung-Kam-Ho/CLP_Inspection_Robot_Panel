//
//  InspectionProgressView.swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 15/8/2024.
//

import SwiftUI

struct InspectionProgressView: View {
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    let columns = [
        GridItem(.adaptive(minimum: 170,maximum: 500))
    ]
    var body: some View {
        let data = viewModel.progress
        let slot_now = Int(station.status.launch_platform_status.angle / 12) + 1
        VStack{
            ScrollViewReader{ proxy in
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(data, id: \.self) { slot in
                            let current_slot = slot_now == slot.slot_id
                            VStack{
                                HStack{
                                    Image(systemName: "\(slot.slot_id).circle.fill")
    //                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
    //                                    .foregroundStyle(.orange)
                                    Spacer()
                                    Image(systemName: slot.EL_CID_Progress != 1.0 ? "xmark.circle.fill" : "checkmark.circle.fill")
                                        .foregroundStyle(slot.EL_CID_Progress != 1.0 ? .red : .green)
                                    
                                }.padding()
                                Text(String(format: "%03d",slot.EL_CID_Progress * 100) + "%")
                                    .foregroundStyle(current_slot ? .white : .clear)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .contentTransition(.numericText(countsDown: true))
                                    .background(RoundedRectangle(cornerRadius: 25.0).stroke(current_slot ? .white : .clear, lineWidth: 5).fill(slot.EL_CID_Progress != 1.0 ? .red : .green))
                                VStack{
                                    if let result = slot.Knocker_result{
                                        Text(String(format: "%03d", result * 100) + "%")
                                            .foregroundStyle(current_slot ? .white : .clear)
                                        
                                    }else{
                                        Text("-")
                                            .foregroundStyle(current_slot ? .white : .clear)
                                    }
                                }
                                .frame(maxWidth: .infinity).padding()
                                .contentTransition(.numericText(countsDown: true))
                                .background(RoundedRectangle(cornerRadius: 25.0).stroke(current_slot ? .white : .clear,lineWidth: 5).fill(slot.Knocker_result == nil ? .gray : (slot.Knocker_result! >= 0.6 ? .green : .red )))
                            }.id(slot.slot_id)
                            .padding()
                            .font(.title)
                            .contentTransition(.numericText(countsDown: true))
                            .background(RoundedRectangle(cornerRadius: 25.0).stroke( current_slot ? .white : .clear, lineWidth: 5).fill(.ultraThickMaterial))
                            .padding()
                        }
                    }.onAppear(perform: {
                        withAnimation{
                            
                            proxy.scrollTo(slot_now)
                        }
                    })
                }
            }
        }.padding()
            .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThinMaterial).stroke(.white))
    }
}

extension InspectionProgressView{
    struct Inspection_Slot_Progress : Codable, Hashable{
        let slot_id : Int
        let EL_CID_Progress : Float  //percentage of complete
        let Knocker_result : Float?  //percentage of loosen, nil if haven't tested
        
    }

    @Observable
    class ViewModel{
        let defaults = UserDefaults.standard
        var progress = [Inspection_Slot_Progress]()
        
        init() {
            progress = defaults.array(forKey: "inspection_progress") as? [Inspection_Slot_Progress] ?? progress_reset()
        }
        
        func progress_reset() -> [Inspection_Slot_Progress]{
            var temp = [Inspection_Slot_Progress]()
            for i in 1...30{
                temp.append(Inspection_Slot_Progress(slot_id: i, EL_CID_Progress: 0.0, Knocker_result: nil))
            }
            return temp
        }
        
        func progress_save(){
            defaults.set(progress, forKey: "inspection_progress")
        }
    }
}

#Preview {
    InspectionProgressView()
}
