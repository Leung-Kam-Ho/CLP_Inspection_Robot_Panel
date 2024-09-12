import SwiftUI

struct AutoView : View{
    @EnvironmentObject var station : Station
    @State var viewModel = ViewModel()
    var body: some View{
        VStack{
            ZStack{
                Color.clear
                VStack{
                    let connected = self.station.server_connected
                    Menu(content: {
                        HStack{
                            Picker("IP", selection: self.$station.ip, content: {
                                ForEach(Station.IP.allCases, id:\.self){ ip in
                                    Text(String(describing: ip))
                                        .padding()
                                        .tag(ip.rawValue)
                                }.pickerStyle(.automatic)
                            }).font(.title)
//                                .onChange(of: self.station.ip, { old, new in
//                                    let defaults = UserDefaults.standard
//                                    defaults.setValue(new, forKey: "IP")
//                                })
                        }
                    }, label: {
                        VStack{
                            let mt = self.station.status.auto_status.action_update == ""
                            Text(connected ? (mt ? "Server online" : "Current Action") : "Server offline")
                                
                                .padding()
                                .contentTransition(.numericText(countsDown: true))
                            Text(self.station.status.auto_status.action_update == "" ? "No Action": self.station.status.auto_status.action_update)
                                .padding()
                                .contentTransition(.numericText(countsDown: true))
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 17.0).fill(.ultraThinMaterial))
                                .padding()
                        }
                        .background(RoundedRectangle(cornerRadius: 25.0)
                            .fill(connected ? .green : .red))
                    }).buttonStyle(.plain)
                   
                    ScrollViewReader{ scrollView in
                        ScrollView(.vertical,showsIndicators: false){
                            VStack(alignment : .leading,spacing : 40){
                                ForEach(Array(tree2List().enumerated()), id:\.0){ idx,name in
                                    VStack(alignment : .leading){
                                        Text(name.replacingOccurrences(of: "-->", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                                            .tint(.primary)
                                        .contentTransition(.numericText(countsDown: true))
                                        if name.contains(String("🏃🏻‍➡️")){
                                            Text(self.station.status.auto_status.action_update)
                                                .foregroundStyle(.orange)
                                                .id("current_Action")
                                            .contentTransition(.numericText(countsDown: true))
                                            .onAppear{
                                                scrollView.scrollTo("current_Action")
                                            }
                                        }
                                    }.padding()
                                        .background(RoundedRectangle(cornerRadius: 25.0).fill(.ultraThickMaterial))
                                }
                            }.frame(maxWidth: .infinity, alignment : .leading)
                            
                        }
                        .padding()
                    }
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
                                }).keyboardShortcut("s",modifiers: .command)
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
                            .lineLimit(1)
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
        case Testing
    }
    @Observable
    class ViewModel{
        var pop = false
    }
    func splitAndFilterLines(text: String, targetStrings: [String]) -> [String] {
      return text.split(separator: "\n")
                 .map(String.init)
                 .filter { line in
                   targetStrings.contains { target in
                     line.lowercased().contains(target.lowercased())
                   }
                 }
    }
    func tree2List() -> [String]{
        let tree = self.station.status.auto_status.tree_ascii
        let better = tree.replacingOccurrences(of: "[o]", with: String("✅")).replacingOccurrences(of: "[x]", with: String("❌")).replacingOccurrences(of: "[*]", with: String("🏃🏻‍➡️")).replacingOccurrences(of: "[-]", with: String("💬"))
        let filtered = splitAndFilterLines(text:better, targetStrings:["-->",])
        return filtered
    }
}
