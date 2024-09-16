import SwiftUI


class Station : ObservableObject{
    class Station_Status : Codable , ObservableObject{
        var robot_status = Robot_Status()
        var digital_valve_status = Digital_Valve_Status()
        var launch_platform_status = LaunchPlatform_Status()
        var auto_status = Automation_Status()
        var audio_status = Audio_Status()
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
        var angle : Int = 6
        var connected : Bool = false
        var setpoint : Int = 0
    }
    class Automation_Status : Codable, ObservableObject{
        var sequence_name : String = ""
        var mode : String = "Manual"
        var action_update : String = ""
        var action_name : String = ""
        var tree_ascii : String = ""
    }
    class Camera_Status : Codable, ObservableObject{
        var data : Data = Data()
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
    }

    enum IP : String, CaseIterable{
        case hp = "kamholeung-HP-ENVY-x360-15-Convertible-PC.local"
        case station = "192.168.10.5"
        case cable_connection = "10.10.10.1"
    }
    @Published var status = Station_Status()
    @Published var server_connected = false
    @AppStorage("ip_selection") var ip : String = ""
    @Published var desired_pressure : [Double] = [0.0,0.0,0.0,0.0]
    @Published var camera_frames : UIImage = .watermark
    var audio_log : [Audio_Status] = []
    
    var camera_status = Camera_Status()
    var image : UIImage? = UIImage()
    var getImage = false
    
    var data = Station_Status()
    var tree = "No Tree"
    var most_recent_FFT = [Float]()
    var connected = false

    var port = Constants.PORT
    var timer = Timer.publish(every: Constants.UI_RATE, on: .main, in: .common).autoconnect()
    let pressure_max = Constants.PRESSURE_MAX
    var free = true
    var free2 = true
    
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
                if self.free{
                    self.get_request("/data")
                }
            })
            RunLoop.current.add(timer, forMode: .common)
            RunLoop.current.run()
        }
        thread.start()
    }
    
    func create_url(_ route : String) -> URL{
        return URL(string: "http://\(self.ip):\(self.port)\(route)")!
    }
    func updateData(_: Date){
        if let image = self.image{
            self.camera_frames = image
        }
        withAnimation(.easeOut(duration: 0.1)){
            let temp = self.data
            self.status = temp
            self.tree = self.status.auto_status.tree_ascii
            self.server_connected = self.connected
            self.save_audio(self.status.audio_status)
            
        }
        
    }
    func get_frame(){
        DispatchQueue.global(qos: .userInitiated).async{
            let url = self.create_url("/frame")
            let request = URLRequest(url: url, timeoutInterval: TimeInterval(1))
            self.free2 = false
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                defer{ self.free2 = true }
                guard let data = data else { return }
                do{
                    self.camera_status = try JSONDecoder().decode(Camera_Status.self, from: data)
                    self.image = UIImage(data: self.camera_status.data)
                }catch{
                    print(error)
                }
            }
            task.resume()
        }
    }
    func get_request(_ route : String = "/"){
        DispatchQueue.global(qos: .userInitiated).async{
            let url = self.create_url(route)
            let request = URLRequest(url: url, timeoutInterval: TimeInterval(1))
            self.free = false
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                defer{ self.free = true }
                if let _ = error{
                    DispatchQueue.main.async{
                        self.connected = false
                        // make everything offline
                        self.status.robot_status.connected = false
                        self.status.digital_valve_status.connected = false
                        self.status.launch_platform_status.connected = false
                    }
                }
                guard let data = data else { return }
                do{
                    self.data = try JSONDecoder().decode(Station_Status.self, from: data)
                    self.connected = true
                }catch{
                    print(error)
                    self.connected = false
                }
                
            }
            task.resume()
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
                        print(self.audio_log.count)
                    }
                }
                print(self.audio_log.count)
            }
        }
        
       
    }
    
    func RotatePlatform(Angle : Angle = .degrees(0)){
        print(Angle.degrees)
        post_request("/launch_platform",value: [Int(Angle.degrees)])
    }
    func post_request(_ route : String = "/", value : [Int]){
        DispatchQueue.global(qos: .userInitiated).async{
            // Value : [1100,1100,1100,1100] or [8]
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
                guard let _ = data else { return }
            }
            task.resume()
        }
    }
    
    func post_request(_ route : String = "/", value : Bool){
        DispatchQueue.global(qos: .userInitiated).async{
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
                guard let _ = data else { return }
            }
            task.resume()
        }
    }
    
    func post_request(_ route : String = "/", value : String){
        // Value : [1100,1100,1100,1100] or [8]
        DispatchQueue.global(qos: .userInitiated).async{
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
                guard let _ = data else { return }
            }
            
            task.resume()
        }
    }
    func post_request(_ route : String = "/", value : [Float]){
        // Value : [1100,1100,1100,1100] or [8]
        DispatchQueue.global(qos: .userInitiated).async{
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
                guard let _ = data else { return }
            }
            
            task.resume()
        }
    }
}
