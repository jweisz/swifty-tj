# SwiftyTJ

This is a [TJ Bot recipe](https://github.com/ibmtjbot/tjbot) for controlling the LED from a [Swift](https://swift.org) program.

**This is an experimental recipe that has only been tested on Raspian (Jessie).**

## How It Works

As of this writing, there is no support for the NeoPixel LED in Swift. Therefore, we use the following architecture:

	Swift —> Node.js —> NeoPixel LED

Our Swift program will communicate over a socket with a Node.js server which uses the `rpi-ws281x-native` library to control the LED.

## Prerequisites

Before using this recipe, you need to install the Swift 3.0 runtime for your Raspberry Pi.

### Install Swift-3.0

Grab the latest build of Swift-3.0 for ARM processors.

	$ wget http://swift-arm.ddns.net/view/Swift%20on%20ARM/job/Swift-3.0-ARMv7-ubuntu1410/lastSuccessfulBuild/artifact/swift-3.0-2016-10-21-armv7-ubuntu14.04.tar.gz

> There may be a newer build than what is referenced above. Please check [the Jenkins build page](http://swift-arm.ddns.net/view/Swift%20on%20ARM/job/Swift-3.0-ARMv7-ubuntu1410/) for a newer version.

Extract the archive.

	$ tar xzvf swift-3.0-2016-10-21-armv7-ubuntu14.04.tar.gz

Add `swift-3.0/usr/bin` to your `$PATH`. I keep it in my Downloads folder, but you can move it wherever you want in the file system (e.g. `/opt/swift-3.0`).

	$ export PATH=~/Downloads/swift-3.0/usr/bin:$PATH

> You can add this line to the bottom of your `.bashrc` file to ensure Swift is always included in your $PATH.

Test to see what version of `swift` you have.

	$ swift --version
	Swift version 3.0-dev (LLVM 545d4be6ac, Clang 968470f170, Swift ac8b5bd472)
	Target: armv7--linux-gnueabihf

## Build

Now that `swift-3.0` is installed, let’s build the Swift client application.

	$ cd SwiftyTJ/Client
	$ sh build.sh

The build script will invoke `swiftc`, the Swift compiler, to build the Swift client. It will output a binary named `main`.

> As of this writing, `swift-build-tool` does not work on Raspberry Pi. This means that we cannot use `swift build` to build our app, nor can we use the Swift Package Manager to load 3rd party libraries. Our recipe has a dependency on [BlueSocket](https://github.com/IBM-Swift/BlueSocket), and we have included its sources directly. We also provide a Swift implementation of `OpcClientStream` that mirrors the client functionality from the `openpixelcontrol-stream` npm package.

Next, install the dependencies for the server.

	$ cd ../Server
	$ npm install

## Run

First, run the server.

	$ ./background.sh
	nohup: appending output to ‘nohup.out’

The `background.sh` script will run the Node.js server in the background (using `nohup`). The Node.js server is run using `sudo` because it needs root permissions to control the LED.

The next step is to head back to the `Client` folder and start changing the color of the LED!

	$ cd ../Client

The `main` program takes one argument on the command line, which is the color to which the LED should be set. It understands some colors by name (e.g. “red”, “green”, “blue”, “orange”, “aqua”, and more). It also understands colors specified in hexademical, such as “0x00FF00” (red) and “8B021A” (green).

> Colors are specified as GGRRBB, not the usual RRGGBB.

Try changing the colors around.

	$ ./main red
	changing pixel color to ff00
	connected to localhost:7890
	wrote 7 bytes to socket: 0100000300ff00
	$ ./main green
	changing pixel color to ff0000
	connected to localhost:7890
	wrote 7 bytes to socket: 01000003ff0000
	$ ./main orange
	changing pixel color to a5ff00
	connected to localhost:7890
	wrote 7 bytes to socket: 01000003a5ff00
	$ ./main yellow
	changing pixel color to c1ff35
	connected to localhost:7890
	wrote 7 bytes to socket: 01000003c1ff35
	$ ./main 332288
	changing pixel color to 332288
	connected to localhost:7890
	wrote 7 bytes to socket: 01000003332288
	$ ./main 0x82C497
	changing pixel color to 82c497
	connected to localhost:7890
	wrote 7 bytes to socket: 0100000382c497
	$ ./main off
	changing pixel color to 00
	connected to localhost:7890
	wrote 7 bytes to socket: 01000003000000

> You will see a status message printed each time you run `main` showing the color to be used for the LED, and the status of connecting to the Node.js server.

If there is a problem connecting to the server (e.g. because it isn’t running), you will see an error message.

	$ ./main red
	changing pixel color to ff00
	failed to connect to localhost:7890
	could not write data

To turn off the Node.js server, you need to find its process ID (PID) using the `ps` command and then terminate it using the `kill` command. The process you’re looking for is named `sudo nohup node server.js`. Make a note of the PID (1127 in our case) and use that in the `kill` command.

	$ ps au
	USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
	…
	root      1127  0.0  0.3   6780  3116 pts/0    S    09:16   0:00 sudo nohup node server.js
	…
	$ sudo kill 1127

> Make sure to use `sudo` to kill the process because it’s owned by root.

## Where to go from here

There are a few additional things to try out with SwiftyTJ.

1. Explore all of the colors you can set the LED to (hint: look in `main.swift`). Try adding some more colors!
2. Have some fun with disco mode! Try running `disco.sh` from the command line. Notice how the color order is the same every time? Can you re-implement this in Swift to make the color selectin random? (hint: look in `main.swift` for a section to uncomment).
3. (Advanced). Make TJ play music during disco mode!
3. (Advanced). Add the `watson-developer-sdk` to the Node.js server and make TJ speak from Swift using the Speech to Text service.

As the Swift 3.0 build matures on Raspberry Pi, it should become easier to include 3rd party libaries to provide additional functionality. For example, the [Watson iOS SDK](https://github.com/watson-developer-cloud/ios-sdk) is written in Swift, but may need to have iOS-specific dependencies factored out in order to run on Raspberry Pi.

## Dependencies

### Swift

- [Swift 3.0](http://swift-arm.ddns.net/view/Swift%20on%20ARM/job/Swift-3.0-ARMv7-ubuntu1410/)
- [BlueSocket](https://github.com/IBM-Swift/BlueSocket). Native Swift socket library.

### Node.js

- [rpi-ws281x-native](https://github.com/beyondscreen/node-rpi-ws281x-native). npm package to control a ws281x LED.
- [openpixelcontrol-stream](https://www.npmjs.com/package/openpixelcontrol-stream). Provides a stream-implementation for interfacing with the openpixelcontrol-protocol.

## License

This library is licensed under Apache 2.0. Full license text is
available in [LICENSE](LICENSE).
