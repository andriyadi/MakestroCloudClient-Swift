import Foundation
import Dispatch
import MakestroClient

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

let client = MakestroClient(project: "[YOUR_PROJECT_NAME]",
                            userName: "[YOUR_USER_NAME]",
                            userKey: "[YOUR_USER_KEY]",
                            deviceId: "[YOUR_DEVICE_ID]")

print("" +
    "         (__)\n"                +
    "       /   @@      ______\n"    +
    "      |  /\\_|     |      \\\n" +
    "      |  |___     |       |\n"  +
    "      |   ---@    |_______|\n"  +
    "      |  |   ----   |    |\n"   +
    "      |  |_____\n"              +
    "*____/|________|\n"             +
    "CompuCow After an All-niter\n"
)

let PUBLISH_INTERVAL = 5 //5 seconds
let boardInfo = BoardInfo()

do {
    
    try client.connect()
    
    if #available(OSX 10.12, *) {
        let heartbeat = Timer.scheduledTimer(withTimeInterval: TimeInterval(PUBLISH_INTERVAL), repeats:true){
            _ in
            
            if client.isConnected {
                
                let tempStr = boardInfo.getTemperature(format: .Number)
                if let temp = Double(tempStr) {
                    var keyVal: [String: Any] = ["temp": temp]
                    client.publish(keyValue: keyVal)
                }
            }
        }
        
        RunLoop.current.add(heartbeat, forMode:RunLoopMode.defaultRunLoopMode)
        RunLoop.current.run()
        
    } else {
        // Fallback on earlier versions
    }
}
catch {
    print("Connection failed!")
}
