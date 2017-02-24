//
//  MakestroClient.swift
//  MakestroClient
//
//  Created by Andri Yadi on 2/18/17.
//
//

import Foundation
import Aphid
import Jay

#if os(Linux)
    import SwiftGlibc
    
    public func arc4random_uniform(_ max: UInt32) -> Int32 {
        return (SwiftGlibc.rand() % Int32(max-1))
    }
#endif

public typealias MakestroCloudSubscribedPropertyCallback = (Any, Any) -> Void

public class MakestroClient: Aphid, MQTTDelegate {
    
    public var isConnected: Bool = false
    
    var deviceId: String!
    var projectName: String!
    
    var mqttDefaultSubscribeTopic: String!
    var mqttDefaultPublishTopic: String!
    
    var subscribedPropertyHandlers = [String: MakestroCloudSubscribedPropertyCallback]()
    
    internal var shouldParseMessageAsJson: Bool = false
    
    public init(project: String, userName: String, userKey: String, deviceId devId: String? = nil) {
        
        let theDeviceId = devId != nil ? devId!: MakestroClient.randomString(length: 10)
        
        super.init(clientId: theDeviceId)
        super.delegate = self
        
        self.deviceId = theDeviceId
        self.projectName = project
        
        config.username = userName
        config.password = userKey
        config.host = "cloud.makestro.com"
        config.keepAlive = 5
        
        mqttDefaultPublishTopic = "\(userName)/\(project)/data"
        mqttDefaultSubscribeTopic = "\(userName)/\(project)/control"
    }
    
    public func publishData(payload: String) {
        publish(topic: mqttDefaultPublishTopic, withMessage: payload, qos: .atMostOnce, retain: false)
    }
    
    public func publish(keyValue: [String: Any], iftttEvent: String? = nil) {
        var keyVal : [String: Any] = keyValue
        
        if iftttEvent != nil {
            keyVal["ifttt_event"] = iftttEvent
        }
        
        if let jsonData = try? Jay(formatting: .prettified).dataFromJson(anyDictionary: keyVal) {
            if let jsonStr = String(bytes: jsonData, encoding: .utf8) {
                print(jsonStr)
                
                publishData(payload: jsonStr)
            }
        }
    }
    
    public func subscribe(property: String, callback: @escaping MakestroCloudSubscribedPropertyCallback) {
        subscribedPropertyHandlers[property] = callback
        shouldParseMessageAsJson = true
    }
    
    // MARK: MQTTDelegate methods
    
    public func didConnect() {
        print("I connected! Now subscribing to \(mqttDefaultSubscribeTopic!)")
        isConnected = true
        subscribe(topic: [mqttDefaultSubscribeTopic], qoss: [QosType.atMostOnce])
    }
    
    public func didLoseConnection(error: Error?) {
        isConnected = false
        print("connection lost")
    }
    
    public func didCompleteDelivery(token: String) {
        print("Event: \(token)")
    }
    
    public func didReceiveMessage(topic: String, message: String) {
        //print(topic, message)
        
        let messageClean = message.replacingOccurrences(of: "\0\u{01}", with: "")
        
        if shouldParseMessageAsJson && subscribedPropertyHandlers.count > 0 {
            let msgData = messageClean.data(using: .utf8)!;
            
            if let json = try? Jay().anyJsonFromData(Array(msgData)) {
                
                for (prop, cb) in subscribedPropertyHandlers {
                    if let val = (json as? [String: Any])?[prop] {
                        cb(prop, val)
                    }
                }
            }
        }
    }
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            let nextChar = letters.character(at: Int(rand))
            //randomString += NSString(characters: &nextChar, length: 1) as String
            randomString += String(nextChar)
        }
        
        return randomString
    }
}

