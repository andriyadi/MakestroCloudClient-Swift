//
//  Temperature.swift
//  MakestroClient
//
//  Created by Andri Yadi on 2/21/17.
//
//

import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

public enum TemperatureFormat: String {
    case Fahrenheit = "-F"
    case Celcius = "-C"
    case Number = "-N"
}

public class BoardInfo {
    
    public func getTemperature(format: TemperatureFormat) -> String {
        var temperature = "0"
        
        #if os(OSX)
            // Get the program from here: https://github.com/lavoiesl/osx-cpu-temp
            // Make sure to install it on /usr/local/bin by issuing `sudo make install`
            
            let out = BoardInfo.runCommand(cmd: "/usr/local/bin/osx-cpu-temp", args: format.rawValue).output
            
            if (out.count > 0) {
                temperature = out[0]
            }
            
        #elseif os(Linux)
            // From: http://dev.iachieved.it/iachievedit/mqtt-with-swift-on-linux/
            
            let BUFSIZE = 16
            let pp      = popen("cat /sys/class/hwmon/hwmon0/temp1_input", "r")
            var buf     = [CChar](repeating:0, count:BUFSIZE)
            guard fgets(&buf, Int32(BUFSIZE), pp) != nil else {
                pclose(pp)
                return nil
            }
            pclose(pp)
            
            let s = String(String(cString:buf).characters.dropLast())
            if let t = Double(s) {
                temperature = "\(t/1000)"
            }
        #endif
        
        return temperature
    }
    
    //From here: http://stackoverflow.com/questions/29514738/get-terminal-output-after-a-command-swift
    
    static func runCommand(cmd : String, args : String...) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
}
