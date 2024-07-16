import SwiftUI


enum Constants{
    static let PORT = 5000
    static let DATA_RATE = 1/10.0
    static let UI_RATE = 1/10.0
    static let PRESSURE_MAX = 6.6
    static let offWhite = Color(red: 221/255, green: 221/255, blue: 221/255)
}


class Station : ObservableObject{
    class Station_Status : Codable , ObservableObject{
        var robot_status = Robot_Status()
        var digital_valve_status = Digital_Valve_Status()
        var launch_platform_status = LaunchPlatform_Status()
        var auto_status = Automation_Status()
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
    }
    class Automation_Status : Codable, ObservableObject{
        var state : String = "Manual"
        var detail : String = "Nothing"
        var action_queue : [String] = [String]()
    }
    class Camera_Status : Codable, ObservableObject{
        var data : Data = Data()
    }
    enum IP : String, CaseIterable{
        case hp = "kamholeung-HP-ENVY-x360-15-Convertible-PC.local"
        case pi = "cable.local"
        case statiom = "station.local"
    }
    @Published var status = Station_Status()
    @Published var ip : String
    @Published var desired_pressure : [Double] = [0.0,0.0,0.0,0.0]
    @Published var camera_frames : UIImage = .watermark
    
    var camera_status = Camera_Status()
    var image : UIImage? = UIImage()
    var getImage = false
    
    var data = Station_Status()
    
    var port = Constants.PORT
    let timer = Timer.publish(every: Constants.UI_RATE, on: .main, in: .common).autoconnect()
    let pressure_max = Constants.PRESSURE_MAX
    var free = true
    var free2 = true

    init(){
        let defaults = UserDefaults.standard
        self.ip = defaults.string(forKey: "IP") ?? IP.pi.rawValue
        self.init_RunLoop()
    }
    
    func init_RunLoop(){
        let thread = Thread{
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                if self.free{
                    self.get_request("/data")
                }
            })
            RunLoop.current.add(timer, forMode: .default)
            RunLoop.current.run()
        }
        thread.start()
//        let thread2 = Thread{
//            let timer = Timer.scheduledTimer(withTimeInterval: 1/30.0, repeats: true, block: { _ in
//                if self.free2 && self.getImage{
//                    self.get_frame()
//                }
//                
//            })
//            RunLoop.current.add(timer, forMode: .default)
//            RunLoop.current.run()
//        }
//        thread2.start()
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
                    print("a")
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
                        self.data = Station_Status()
                    }
                }
                guard let data = data else { return }
                do{
                    self.data = try JSONDecoder().decode(Station_Status.self, from: data)
                }catch{
                    print(error)
                }
                
            }
            task.resume()
        }
    }

    func test(){
            let a = Station.Station_Status()
            var temp = ""
            for _ in 0...7{
                temp += String(Int.random(in: 0...1))
            }
            a.robot_status.relay = temp
            a.digital_valve_status.pressure = [Double.random(in: 0...6),Double.random(in: 0...6),Double.random(in: 0...6),Double.random(in: 0...6)]
            a.launch_platform_status.angle = Int.random(in: 0...360)
            let direction = Int.random(in: -1...1)
            let LP = Int.random(in: 0...400)
            let RP = Int.random(in: 0...400)
            a.robot_status.tof = Array(repeating: Int.random(in: 0...255), count: 16)
            a.robot_status.servo = [direction * LP + 1500,direction * RP + 1500,1500,1500]
            var temp2 = [String]()
            for i in 0...Int.random(in: 1...10){
                let action = ["Checking Clearance", "Open Feet 1", "Change Pressure of Feet"]
                temp2.append("\(i+1). \(action[Int.random(in: 0...2)])")
            }
            a.auto_status.action_queue = temp2
            a.auto_status.detail = "Checking TOF 1"
            self.self.data = a
        
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
