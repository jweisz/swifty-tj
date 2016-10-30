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

import Glibc

let CHANNEL: UInt8 = 0x1
let HOST = "localhost"
let PORT = Int32(7890)

let COLORS: [String : UInt32] = [
    "red": 0x0000FF00,
    "green": 0x00FF0000,
    "blue": 0x000000FF,
    "purple": 0x00008080,
    "yellow": 0x00c1ff35,
    "magenta": 0x0000ffff,
    "orange": 0x00a5ff00,
    "aqua": 0x00ff00ff,
    "white": 0x00000000,
    "off": 0x00000000,
    "on": 0x00ffffff
]

guard let client: OpcClientStream = OpcClientStream(to: HOST, port: PORT) else {
    print("error creating OpcClientStream to \(HOST):\(PORT)")
    exit(-1)
}

let arguments = CommandLine.arguments
var color: UInt32 = 0x00FFFFFF

if arguments.count > 1 {
    let colorStr = arguments[1]
    
    // uncomment me for disco mode!
    //if colorStr == "disco" {
    //    let colors = Array(COLORS.values)
    //    repeat {
    //        let color = UInt32(random())
    //        client.setPixelColors(rgba: [color])
    //        usleep(100000)
    //    } while true
    //}
    
    // check if the color is specified as a word
    if let c = COLORS[colorStr] {
        color = c
    } else {
        // otherwise, it's specified as a hex value
        let sans0x = colorStr.hasPrefix("0x") ? String(colorStr.characters.dropFirst(2)) : colorStr
        if let c = UInt32(sans0x, radix: 16) {
            color = c
        }
    }
}

print("changing pixel color to \(color.hexadecimalString)")
client.setPixelColors(rgba: [color])
