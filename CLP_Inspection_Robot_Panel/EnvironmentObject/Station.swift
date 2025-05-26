import SwiftUI
import os

enum AutoMode_segment: String, CaseIterable {
    case Manual, Standing, Lauch, Baffle, Testing
}

class Station: ObservableObject {
    // MARK: - Nested Status Classes

    class Station_Status: Codable, ObservableObject {
        var robot_status = Robot_Status()
        var digital_valve_status = Digital_Valve_Status()
        var launch_platform_status = LaunchPlatform_Status()
        var auto_status = Automation_Status()
        var audio_status = Audio_Status()
        var el_cid_status = El_cid_status()
        var camera_status = false
    }

    class Robot_Status: Codable, ObservableObject {
        var servo: [Int] = [1500, 1500, 1500, 1500]
        var relay: String = "00000000"
        var tof: [Int] = Array(repeating: 0, count: 18)
        var roll_angle: Int = 0
        var lazer: Int = 0
        var connected: Bool = false
    }

    class Digital_Valve_Status: Codable, ObservableObject {
        var pressure: [Double] = [0, 0, 0, 0]
        var connected: Bool = false
    }

    class LaunchPlatform_Status: Codable, ObservableObject {
        var angle: Float = 1.0
        var relay: String = "00000000"
        var connected: Bool = false
        var setpoint: Float = 0
        var lazer: Int = 0
    }

    class Automation_Status: Codable, ObservableObject {
        var sequence_name: String = ""
        var mode: String = "Manual"
        var action_update: String = ""
        var action_name: String = ""
        var tree_ascii: String = ""
    }

    class Audio_Status: Codable, ObservableObject {
        var recording: Bool = false
        var file_num: Int = 0
        var date: String = ""
        var slot: Int = 0
        var distance: Int = 0
        var FFT: [Float] = []
        var FFT_freq: [Float] = []
        var Audio: [Float] = []
        var connected: Bool = false
    }

    class El_cid_status: Codable, ObservableObject {
        var distance_per_click = 100
        var relay_state = 0
        var connected = false
    }

    // MARK: - Traffic Status

    class TrafficStatus {
        private var get_data_semaphore: Bool = true
        private var post_data_semaphore: Bool = true

        func getCheck() -> Bool { get_data_semaphore }
        func postCheck() -> Bool { post_data_semaphore }
        func getStart() { get_data_semaphore = false }
        func getEnd() { get_data_semaphore = true }
        func postStart() { post_data_semaphore = false }
        func postEnd() { post_data_semaphore = true }
    }

    // MARK: - Properties

    @Published var status = Station_Status()
    @Published var server_connected = false
    @AppStorage("ip_selection") var ip: String = "192.168.10.5"
    @Published var desired_pressure: [Double] = [0.0, 0.0, 0.0, 0.0]

    var audio_log: [Audio_Status] = []
    var latest_audio: Audio_Status = Audio_Status()
    var image: UIImage? = UIImage()
    var getImage = false
    var autoMode: AutoMode_segment = .Manual
    var data = Station_Status()
    var tree = "No Tree"
    var most_recent_FFT = [Float]()
    var connected = false
    var port = Constants.PORT
    var timer = Timer.publish(every: Constants.SLOW_RATE, on: .main, in: .common).autoconnect()
    let pressure_max = Constants.PRESSURE_MAX
    var trafficStatus = TrafficStatus()

    // MARK: - Initialization

    init() {
        if let data = UserDefaults.standard.data(forKey: "audio_log"),
           let log = try? JSONDecoder().decode([Audio_Status].self, from: data) {
            self.audio_log = log
        }
        self.init_RunLoop()
    }

    // MARK: - Run Loop

    func init_RunLoop() {
        let thread = Thread {
            let timer = Timer.scheduledTimer(withTimeInterval: Constants.DATA_RATE, repeats: true) { _ in
                _ = self.get_request("/data")
            }
            RunLoop.current.add(timer, forMode: .common)
            RunLoop.current.run()
        }
        thread.start()
        print("Station Init")
    }

    func dataUpdateRate(_ FPS: Double) {
        self.timer = Timer.publish(every: FPS, on: .main, in: .common).autoconnect()
    }

    // MARK: - Networking

    func create_url(_ route: String) -> URL {
        URL(string: "http://\(self.ip):\(self.port)\(route)") ?? URL(string: "http://127.0.0.1")!
    }

    func updateData(_: Date) {
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.1)) {
                self.status = self.data
                self.tree = self.status.auto_status.tree_ascii
                self.server_connected = self.connected
                self.latest_audio = self.status.audio_status
            }
        }
    }

    func ErrorHandle() {
        self.connected = false
        self.data.robot_status.connected = false
        self.data.digital_valve_status.connected = false
        self.data.launch_platform_status.connected = false
        self.data.el_cid_status.connected = false
    }

    func get_request(_ route: String = "/") -> Bool {
        guard self.trafficStatus.getCheck() else { return false }
        self.trafficStatus.getStart()
        Logger().notice("Data Fetch")
        let url = self.create_url(route)
        let request = URLRequest(url: url, timeoutInterval: 1)
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            defer {
                self.trafficStatus.getEnd()
                Logger().notice("Data Fetch Ended")
            }
            if error != nil {
                self.ErrorHandle()
                return
            }
            guard let data = data else { return }
            do {
                self.data = try JSONDecoder().decode(Station_Status.self, from: data)
                Logger().notice("Data Fetch Success")
                self.save_audio(self.data.audio_status)
                self.connected = true
            } catch {
                print(error)
                self.connected = false
            }
        }
        task.resume()
        return true
    }

    func post_request<T: Codable>(_ route: String = "/", value: T) -> Bool {
        guard self.trafficStatus.postCheck() else { return false }
        Logger().info("Send Post Request")
        self.trafficStatus.postStart()
        let url = self.create_url(route)
        var request = URLRequest(url: url, timeoutInterval: 1)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let message = ["value": value]
        request.httpBody = try? JSONEncoder().encode(message)
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            defer { self.trafficStatus.postEnd() }
            guard data != nil else { return }
        }
        task.resume()
        return true
    }

    // MARK: - Audio Log

    func checkAudioLogExistence(audioLogs: [Audio_Status], newAudioLog: Audio_Status) -> Bool {
        audioLogs.contains {
            $0.date == newAudioLog.date &&
            $0.slot == newAudioLog.slot &&
            $0.distance == newAudioLog.distance &&
            $0.file_num == newAudioLog.file_num
        }
    }

    func save_audio_to_user_defaults() {
        if let data = try? JSONEncoder().encode(self.audio_log) {
            UserDefaults.standard.set(data, forKey: "audio_log")
        }
    }

    func save_audio(_ log: Audio_Status) {
        guard !log.recording else { return }
        let exist = checkAudioLogExistence(audioLogs: self.audio_log, newAudioLog: log)
        if !exist, !log.date.isEmpty, !log.Audio.isEmpty, !log.FFT.isEmpty {
            DispatchQueue.main.async {
                self.audio_log.append(log)
                self.save_audio_to_user_defaults()
            }
        }
    }

    // MARK: - Platform Control

    func RotatePlatform(Angle: Angle = .degrees(0)) -> Bool {
        let angle = Angle.degrees < 0 ? 360 + Angle.degrees : Angle.degrees
        Logger().info("set \(angle)")
        return post_request("/launch_platform", value: [Float(angle)])
    }
}
