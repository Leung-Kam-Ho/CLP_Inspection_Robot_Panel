import SwiftUI

struct AutoView : View{
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    var body: some View{
        VStack{
            ZStack{
                Color.clear
                VStack{
                    Text(self.station.status.auto_status.state)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .contentTransition(.numericText(countsDown: true))
                        .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThinMaterial))
                    ScrollView(.vertical,showsIndicators: false){
                        VStack(alignment : .leading,spacing : 40){
                            let q = self.station.status.auto_status.action_queue
                            let current = q.first
                            if let current = current{
                                VStack(alignment : .leading){
                                    Text(current)
                                        .tint(.primary)
                                    .contentTransition(.numericText(countsDown: true))
                                    Text(self.station.status.auto_status.detail)
                                        .foregroundStyle(.orange)
                                    .contentTransition(.numericText(countsDown: true))
                                }.padding()
                                    .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThickMaterial))
                                
                            }
                            if q.count > 1{
                                let extendTo = q.count > 5 ? 5 : q.count
                                ForEach(0..<extendTo, id:\.self){ action in
                                    if action != 0{
                                        Text(q[action])
                                        .contentTransition(.numericText(countsDown: true))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }.frame(maxWidth: .infinity, alignment : .leading)
                        
                    }
                    .padding()
                    HStack{
                        Menu(content: {
                            let inProgress = (self.station.status.auto_status.mode != "Manual")
                                Section{
                                    ForEach(AutoMode.allCases, id: \.self){ mode in
                                        let name = mode.rawValue
                                        Button(action: {
                                            self.station.post_request("/auto", value: name)
                                        }, label: {
                                            Text(name)
                                                .font(.title)
                                                .padding()
                                                
                                            
                                        })
                                    }
                                }
                            if inProgress{
                                Button(role: .destructive, action: {
                                    self.station.post_request("/auto", value: "Manual")
                                }, label: {
                                    Text("Stop Inspection")
                                        .font(.title)
                                        .padding()
                                    
                                })
                            }else{
                                Button(action: {
                                    self.station.post_request("/auto", value: AutoMode.Manual.rawValue)
                                }, label: {
                                    Label("Start Inspection",systemImage: "text.page.badge.magnifyingglass")
//                                        .font(.title)
                                        .bold()
                                        .foregroundStyle(.green)
                                        .padding()
                                        
                                    
                                }).foregroundStyle(.green)
                            }
                        }, label: {
                            let inProgress = (self.station.status.auto_status.mode != "Manual")
                                Image(systemName: inProgress ? "stop.fill" : "play.fill" )
                                .padding()
                                .padding(.horizontal)
                                .tint(.primary)
                                .background(RoundedRectangle(cornerRadius: 25.0)
                                    .fill( inProgress ? .red : .green))
                        })
                        Spacer()
                        Text(station.status.auto_status.mode)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThickMaterial))
                            .padding()
                    }
                }
                
            }
            
        }
    }
}

extension AutoView{
    enum AutoMode : String , CaseIterable{
        case Manual
        case Enter
        case Exit
        case Elevate
        case Drop
        case Enter_Generator
        case Exit_Generator
    }
    @Observable
    class ViewModel{
        var pop = false
    }
}
