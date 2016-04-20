# Network Visualization

A network traffic visualizer which takes a JSON file processed by Dshell as input. Draws up network topology and animates packet transfer while allowing individual packet details to be read.

Created as a tool to help analyse network traffic that maintains both clarity and detail to allow for most usefulness.

More information found in full report in /doc directory.

## Installation

Download source folder and [Processing IDE](https://processing.org/download) to run application.
ControlP5 library is required for running this tool.

## Usage

Run packet data through proper Dshell module into JSON object data.json. Place data.json into src/NetVis/data directory. Open NetVis.pde in Processing IDE and run it to start the application.

Controls:
Play/Timeline - Manipulate playback
Right Slider - Manipulate playback speed
Lock - Keeps node visible at all times, even when inactive
Anchor - Keeps node anchored at its current position, unaffected by automatic positioning
Start of Flow - Sets timeline to start of current flow

Keyboard Shortcuts:
Space - Play/Pause
L - Lock current node/all visible if no node is selected (Shift+L for all)
A - Anchor current node/all visible if no node is selected (Shift+A for all)
F - Start of Flow

## Demo

[Youtube Link]

## Future Work

Further functionality:
* Magnifier for packet selection
* TCP Flag portrayal
	* Highlight packets with specific flags (SYN, ACK)
* Distinctive node traits
	* Distinguish similar nodes in visuals as well as details
* Node Categorization and Filtering
	* Allow for visible data to be manipulated further by blocking out specific nodes
* Preference and Layout IO
* Integration into an external interface
	* Perhaps web-based (Processing.js)

## Contributors
Terry Wen - https://github.com/terry-wen

This project was directed by ARL as a compliment to [Dshell](https://github.com/USArmyResearchLab/Dshell)


	
