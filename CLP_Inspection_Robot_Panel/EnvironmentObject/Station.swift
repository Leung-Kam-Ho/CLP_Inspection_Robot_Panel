import SwiftUI
import os


class Station : ObservableObject{
    class Station_Status : Codable , ObservableObject{
        var robot_status = Robot_Status()
        var digital_valve_status = Digital_Valve_Status()
        var launch_platform_status = LaunchPlatform_Status()
        var auto_status = Automation_Status()
        var audio_status = Audio_Status()
        var el_cid_status = El_cid_status()
        var camera_status = false
    }
    class Robot_Status : Codable, ObservableObject{
        var servo : [Int] = [1500,1500,1500,1500]
        var relay : String = "00000000"
        var tof : [Int] = Array(repeating: 0, count: 18)
        var roll_angle : Int = 0
        var lazer : Int = 0
        var connected : Bool = false
    }
    class Digital_Valve_Status : Codable, ObservableObject{
        var pressure : [Double] = [0,0,0,0]
        var connected : Bool = false
    }
    class LaunchPlatform_Status : Codable, ObservableObject{
        var angle : Float = 1.0
        var relay : String = "00000000"
        var connected : Bool = false
        var setpoint : Float = 0
    }
    class Automation_Status : Codable, ObservableObject{
        var sequence_name : String = ""
        var mode : String = "Manual"
        var action_update : String = ""
        var action_name : String = ""
        var tree_ascii : String = ""
    }
    class Audio_Status : Codable, ObservableObject{
        var recording : Bool = false
        var file_num : Int = 0
        var date: String = ""
        var slot : Int = 0
        var distance : Int = 0
        var FFT : [Float] = []
        var FFT_freq : [Float] = []
        var Audio : [Float] = []
        var connected : Bool = false
    }
    class El_cid_status : Codable, ObservableObject{
        var distance_per_click = 100
        var relay_state = 0
        var connected = false
    }
    
    class TrafficStatus {
        // since the DispatchSemaphore() won't tell us anything,
        // if we use timer to trigger a threading event,
        // there will be tons of task stuck in teh background,
        // delay of every task will be exponential,
        // here we will just use simple Bool to track if there is a same task in progress
        var get_data_semaphore : Bool = true
        var post_data_semaphore : Bool = true
        
        func getCheck() -> Bool{
            return self.get_data_semaphore
        }
        func postCheck() -> Bool{
            return self.post_data_semaphore
        }
        func getStart(){
            self.get_data_semaphore = false
        }
        func getEnd(){
            self.get_data_semaphore = true
        }
        func postStart(){
            self.post_data_semaphore = false
        }
        func postEnd(){
            self.post_data_semaphore = true
        }
    }
    
    @Published var status = Station_Status()
    @Published var server_connected = false
    @AppStorage("ip_selection") var ip : String = "192.168.10.5"
    @AppStorage("camera_ip_selection") var cam_ip : String = "localhost"
    @Published var desired_pressure : [Double] = [0.0,0.0,0.0,0.0]
    
    var audio_log : [Audio_Status] = []
    
    var image : UIImage? = UIImage()
    var getImage = false
    
    var data = Station_Status()
    var tree = "No Tree"
    var most_recent_FFT = [Float]()
    var connected = false
    
    var port = Constants.PORT
    var timer = Timer.publish(every: Constants.SLOW_RATE, on: .main, in: .common).autoconnect()
    let pressure_max = Constants.PRESSURE_MAX
    
    var trafficStatus = TrafficStatus()
    
    init(){
        if let data = UserDefaults.standard.data(forKey: "audio_log"),
           let log = try? JSONDecoder().decode([Audio_Status].self, from: data) {
            self.audio_log = log
        }
        self.init_RunLoop()
    }
    
    func init_RunLoop(){
        let thread = Thread{
            let timer = Timer.scheduledTimer(withTimeInterval: Constants.DATA_RATE, repeats: true, block: { _ in
                _ = self.get_request("/data")
                
            })
            RunLoop.current.add(timer, forMode: .common)
            RunLoop.current.run()
        }
        thread.start()
        print("Station Init")
    }
    func dataUpdateRate(_ FPS : Double){
        self.timer = Timer.publish(every: FPS, on: .main, in: .common).autoconnect()
    }
    func create_url(_ route : String) -> URL{
        return URL(string: "http://\(self.ip):\(self.port)\(route)") ?? URL(string:"http://127.0.0.1")!
    }
    func updateData(_: Date){
        withAnimation(.easeOut(duration: 0.1)){
            self.status = self.data
            self.tree = self.status.auto_status.tree_ascii
            self.server_connected = self.connected
            self.save_audio(self.status.audio_status)
        }
        
    }
    
    func ErrorHandle(){
        self.connected = false
        // make everything offline
        self.data.robot_status.connected = false
        self.data.digital_valve_status.connected = false
        self.data.launch_platform_status.connected = false
        self.data.el_cid_status.connected = false
        
    }
    
    func get_request(_ route : String = "/") -> Bool{
        if self.trafficStatus.get_data_semaphore{
            self.trafficStatus.getStart()
            Logger().notice("Data Update")
            let url = self.create_url(route)
            let request = URLRequest(url: url, timeoutInterval: TimeInterval(1))
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                defer{
                    self.trafficStatus.getEnd()
                    Logger().notice("Data Update Ended")
                }
                if let _ = error{
                    self.ErrorHandle()
                }
                guard let data = data else { return }
                do{
                    self.data = try JSONDecoder().decode(Station_Status.self, from: data)
                    Logger().notice("Data Update Success")
                    self.connected = true
                }catch{
                    print(error)
                    self.connected = false
                }
            }
            task.resume()
            return true
        }else{
            return false
        }
    }
    
    func checkAudioLogExistence(audioLogs: [Audio_Status], newAudioLog: Audio_Status) -> Bool {
        for existingLog in audioLogs {
            if existingLog.date == newAudioLog.date && existingLog.slot == newAudioLog.slot && existingLog.distance == newAudioLog.distance && existingLog.file_num == newAudioLog.file_num {
                return true // AudioLog already exists
            }
        }
        return false // AudioLog does not exist
    }
    
    func save_audio_to_user_defaults(){
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self.audio_log) {
            UserDefaults.standard.set(data, forKey: "audio_log")
        }
    }
    
    func save_audio(_ log : Audio_Status){
        // check if log.date in self.audio_log
        if !log.recording{
            let exist = checkAudioLogExistence(audioLogs: self.audio_log, newAudioLog: log)
            if !exist{
                if log.date != "" && !log.Audio.isEmpty && !log.FFT.isEmpty{
                    DispatchQueue.main.async{
                        self.audio_log.append(log)
                        //save to UserDefaults
                        self.save_audio_to_user_defaults()
                    }
                }
            }
        }
    }
    func RotatePlatform(Angle : Angle = .degrees(0)) -> Bool{
        let angle : Double
        if Angle.degrees < 0{
            angle = 360 + Angle.degrees
        }else{
            angle = Angle.degrees
        }
        
        Logger().info("set \(angle)")
        return post_request("/launch_platform",value: [Float(angle)])
    }
    func post_request<T : Codable>(_ route : String = "/", value : T) -> Bool{
        if self.trafficStatus.postCheck(){
            Logger().info("Send Post Request")
            self.trafficStatus.postStart()
            let url = self.create_url(route)
            var request = URLRequest(url: url, timeoutInterval: TimeInterval(1))
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpMethod = "POST"
            let message = ["value":value]
            let data = try! JSONEncoder().encode(message)
            request.httpBody = data
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                defer{ self.trafficStatus.postEnd() }
                guard let _ = data else { return }
            }
            task.resume()
            return true
        }else{
            return false
        }
    }
}
