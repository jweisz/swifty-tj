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
