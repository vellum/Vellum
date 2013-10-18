/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
                _   _                             _
 __   __  ___  | | | |  _   _   _ __ ___         (_)  ___
 \ \ / / / _ \ | | | | | | | | | '_ ` _ \        | | / __|
  \ V / |  __/ | | | | | |_| | | | | | | |  _    | | \__ \
   \_/   \___| |_| |_|  \__,_| |_| |_| |_| (_)  _/ | |___/
                                               |__/
  @vellumapp is a work in progress by david lu
  see also: @vellum, http://vellum.cc

  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

var BRIDGE = new Ejecta.Bridge(),
	canvas = document.getElementById('canvas'),
	ctx = canvas.getContext('2d'),
	isRestoringPixels = false,
	accum = { x:0, y:0 },
	prevmouse = { x: 0, y: 0 },
	mousedown = false;

var setDrawingMode = function(mode) {
		var ink = VLM.ink;
		ink.setBrush(mode);
	},

    setDrawingModeAndColor = function(mode, color, opacity){
        
        // set mode
		var ink = VLM.ink,
            s = VLM.state;

        // set color
        if ( color == 'black' ){
            s.color = {
                'name' : 'black',
                'rgba' : [0,0,0,Number(opacity)]
            };
        } else {
            s.color = {
                'name' : 'erase',
                'rgba' : [242,242,232,Number(opacity)]
            };
        }

		ink.setBrush(mode);

        //console.log('setting color: ' + s.color);
    },

    animate = function() {
	    if (isRestoringPixels) { return; }
	    if (mousedown) {
			var ink = VLM.ink;
			ink.tick();
	    }
	},
	
	setup = function() {
	    canvas.width = window.innerWidth;
	    canvas.height = window.innerHeight;
	    ctx.globalAlpha = 1;
	    ctx.lineWidth = 1;
	    clearScreen();
		setDrawingMode(VLM.constants.MODE_SCRIBBLE);
	    //setInterval(animate, 16);
        createjs.Ticker.setFPS(60);
        createjs.Ticker.addEventListener("tick", animate);
        
        VLM.state.isIPad = BRIDGE.isIPad;
	},

	beginStroke = function(x, y) {
	    cancelQueuedSave();
	    mousedown = true;
		var ink = VLM.ink;
		ink.beginStroke(x,y);
	    accum = { x:0, y:0 };
		prevmouse.x = x;
		prevmouse.y = y;
	},

	continueStroke = function(x, y) {
	    cancelQueuedSave();
	    mousedown = true;
		var ink = VLM.ink;
		ink.continueStroke(x,y);
	    accum.x += (x - prevmouse.x);
	    accum.y += (y - prevmouse.y);
		prevmouse.x = x;
		prevmouse.y = y;
	},

	endStroke = function(x, y) {
	    mousedown = false;
		var ink = VLM.ink;
		ink.endStroke(x,y);
	    saveUndoState();
	},
	
	setZoom = function(val) {
    	zoomlevel = Number(val);
		var s = VLM.state;
		s.zoomlevel = Number(val);
	},
	
	clearScreen = function() {
		var ink = VLM.ink;
		ink.clearScreen();
	    clearUndos();
	    saveUndoStateGuts();
	};

var undoStates = [],
	lastundostamp = 0,
	MAX_UNDO_COUNT = 10,
	undoIndex = 0,
	backingStorePixelRatio = ctx.backingStorePixelRatio,
	timerID = null;

// call this while drawing (to prevent temporary lag from glreadpixels)
var cancelQueuedSave = function() {
	    if (timerID != null) {
	        clearTimeout(timerID);
	        timerID = null;
	    }
	},

	saveUndoState = function() {
	    // disable undo for ipad, since glreadpixels is slow and blocks drawing operations
	    if (!BRIDGE) BRIDGE = new Ejecta.Bridge();
	    //
        if ( !BRIDGE.isUndoCapable ) return;
        
        if ( accum.x + accum.y < 5 ) return;
        
        // FIXME: restore the accum stuff to prevent saving undo states everyt eime
	    //if (Math.sqrt(accum.x * accum.x + accum.y * accum.y) < 5) return;
    
	    var millis = Date.now(),
			elapsed = millis - lastundostamp,
			ELAPSED_THRESHOLD = 1000; 
    
	    if (elapsed < ELAPSED_THRESHOLD) {
	        return;
	    }
    
	    saveUndoStateGuts();
    
	    // - - - -  this sets up a timer that calls saves sometime later - - - -
	    //cancelQueuedSave();
	    //timerID = setTimeout(saveUndoStateGuts, 1000);
	},

	saveUndoStateGuts = function() {
	    var millis = Date.now(),
			state = VLM.state,
			w = state.w,
			h = state.h,
			data = ctx.getImageDataHD(0, 0, w * backingStorePixelRatio, h * backingStorePixelRatio);
    
	    // if we've previously restored a state mid list, drop every state after the current state
	    if (undoIndex < undoStates.length - 1) {
	        clearUndosAfterIndex(undoIndex);
	    }
    
	    // remove first item if we're over our limit
	    if (undoStates.length + 1 > MAX_UNDO_COUNT) {
	        undoStates.splice(0, 1);
	    }
    
	    lastundostamp = millis;
	    undoStates.push(data);
	    undoIndex = undoStates.length - 1;
    
	    // call out to the native side and update these values
	    if (!BRIDGE) BRIDGE = new Ejecta.Bridge();
	    BRIDGE.undoCount = undoStates.length;
	    BRIDGE.undoIndex = undoIndex;
	},

	restoreUndoStateAtIndex = function(index_in) {
	    // this state probably never occurs
	    // bail if we're already restoring pixels
	    if (isRestoringPixels) {
	        //console.log('restoring pixels already... bailing');
	        return;
	    }
    
	    //console.log('javascriptview: restorestateatindex(' + index_in + ')');
	    // do some bounds checking
	    var length = undoStates.length;
	    if (length == 0) return;
	    if (index_in < 0 || index_in > length - 1) return;
    
	    //console.log('\tbounds check ok');
    
	    // restore pixels from array
	    isRestoringPixels = true;
	    var data = undoStates[index_in];
	    if (data == null) return;
    
	    ctx.putImageDataHD(data, 0, 0);
	    undoIndex = index_in;
    
	    //console.log('\tcalling out to bridge');
	    // call out to the native side and update these values
	    if (!BRIDGE) BRIDGE = new Ejecta.Bridge();
	    BRIDGE.undoIndex = undoIndex;
	    isRestoringPixels = false;
	},

	clearUndos = function() {
	    undoStates = [];
	    undoIndex = 0;
	    // call out to the native side and update these values
	    if (!BRIDGE) BRIDGE = new Ejecta.Bridge();
	    BRIDGE.undoCount = undoStates.length;
	    BRIDGE.undoIndex = undoIndex;
	},

	clearUndosAfterIndex = function(index_in) {
	    var numslotstodelete = undoStates.length - index_in - 1;
	    if (numslotstodelete > 0) {
	        //console.log('removing undo states after ' + index_in);
	        undoStates.splice(index_in + 1, numslotstodelete);
	    }
	};

setup();