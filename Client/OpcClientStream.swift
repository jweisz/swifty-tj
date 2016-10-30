/**
 * Copyright 2016 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

class OpcClientStream {
    enum Channel: UInt8 {
        case one = 0x1
    }
    
    enum Command: UInt8 {
        case setPixelColors = 0x00
        case sysEx = 0xff
    }
    
    let socket: Socket
    let host: String
    let port: Int32
    
    public var channel: Channel = Channel.one
    
    init?(to host: String, port: Int32) {
        do {
            self.socket = try Socket.create()
        } catch {
            return nil
        }
        
        self.host = host
        self.port = port
    }
    
    deinit {
        self.disconnect()
    }
    
    func connect() {
        if !self.socket.isConnected {
            do {
                try self.socket.connect(to: self.host, port: self.port)
                print("connected to \(self.host):\(self.port)")
            } catch {
                print("failed to connect to \(self.host):\(self.port)")
            }
        }
    }
    
    func disconnect() {
        self.socket.close()
    }
    
    func setPixelColors(rgba: [UInt32]) {
        var data: [UInt8] = []
        
        for color in rgba {
            let r = color.secondByte
            let g = color.thirdByte
            let b = color.fourthByte
            
            data.append(r)
            data.append(g)
            data.append(b)
        }
        
        let msg = OpcClientStream.createMessageData(channel: self.channel, command: .setPixelColors, data: data)
        self.connect()
        
        do {
            let bytesWritten = try self.socket.write(from: msg)
            print("wrote \(bytesWritten) bytes to socket: \(msg.hexadecimalString)")
        } catch {
            print("could not write data")
        }
    }
    
    func sysEx(systemId: UInt16, data: [UInt8]) {
        var data: [UInt8] = []
        
        // systemId
        data.append(systemId.bigEndian.high)
        data.append(systemId.bigEndian.low)
        
        let msg = OpcClientStream.createMessageData(channel: self.channel, command: .sysEx, data: data)
        self.connect()
        
        do {
            try self.socket.write(from: msg)
            print("wrote data to socket: \(msg.hexadecimalString)")
        } catch {
            print("could not write data")
        }
    }
}

extension OpcClientStream {
    static func createMessageData(channel: Channel, command: Command, data: [UInt8]) -> Data {
        var msg: Data = Data()
        
        // channel
        msg.append(channel.rawValue)
    
        // command
        msg.append(command.rawValue)
    
        // data.count
        let length = UInt16(data.count).bigEndian
        msg.append(length.low)
        msg.append(length.high)
    
        // data
        msg.append(contentsOf: data)
    
        return msg
    }
}

extension Data {
    var hexadecimalString: String {
        return self.map{ String(format: "%02x", $0) }.joined()
    }
}

extension UInt16 {
    var high: UInt8 {
        return UInt8((self >> 8) & 0xFF)
    }
    
    var low: UInt8 {
        return UInt8(self & 0xFF)
    }
}

extension UInt32 {
    var firstByte: UInt8 {
        return UInt8((self >> 24) & 0xFF)
    }
    
    var secondByte: UInt8 {
        return UInt8((self >> 16) & 0xFF)
    }
    
    var thirdByte: UInt8 {
        return UInt8((self >> 8) & 0xFF)
    }
    
    var fourthByte: UInt8 {
        return UInt8(self & 0xFF)
    }
    
    var hexadecimalString: String {
        return String(format: "%02x", self)
    }
}
