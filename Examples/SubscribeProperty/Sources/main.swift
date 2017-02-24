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
    "       \\(:)/\n" +
    "       (o|o)\n"  +
    "  /-----\\_/\n"  +
    " /|      |\n"    +
    "^ ||----||\n"    +
    "  ^^    ^^\n"    +
    " Klingon Cow\n"
)

let PUBLISH_INTERVAL = 5 //5 seconds
let boardInfo = BoardInfo()

do {
    
    try client.connect()
    
    // Subscribe to the change of property "button"
    
    client.subscribe(property: "button", callback: {
        (prop, val) in
        print("Got data!!! -> \(prop) is \(val)")
        
        #if os(Linux)
            if prop as! String == "button" {
                ledGpio.value = Int(val as! UInt)
            }
        #endif
    })
    
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
