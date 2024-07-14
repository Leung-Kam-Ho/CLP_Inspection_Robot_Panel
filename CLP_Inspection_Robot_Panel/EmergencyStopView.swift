import SwiftUI

struct EmergencyStopView : View{
    @EnvironmentObject var station : Station
    var body: some View{
        Button(action: {
            self.station.post_request("/servo", value: [1500,1500,1500,1500])
        }, label: {
            Text("Emergency Stop")
                .padding()
                .background(Capsule().fill(.red))
        })
    }
}

