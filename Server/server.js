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
 
var ParseStream = require('openpixelcontrol-stream').OpcParseStream,
    net = require('net'),
    ws281x = require('rpi-ws281x-native');


var server = net.createServer(function(conn) {
    var parser = new ParseStream({
        channel: 1,
        dataFormat: ParseStream.DataFormat.UINT32_ARRAY
    });

    parser.on('setpixelcolors', function(data) {
        ws281x.render(data);
    });

    conn.pipe(parser);
});

var NUM_LEDS = 1;
ws281x.init(NUM_LEDS);
server.listen(7890);
