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

// namespace
var VLM = VLM || {};

(function(){
	// tiny namespaces
	VLM.ink = {};
	VLM.state = {};
	VLM.constants = {};
	VLM.utilities = {};
	
	// write constants
	var c = VLM.constants;
	c.MODE_SCRIBBLE = 0;
	c.MODE_SHADE = 1;
	c.MODE_INK = 2;
	c.MODE_SCRATCH = 3;
	c.MODE_LINE = 4;
	c.MODE_ERASE = 5;
	c.MODE_SCRAMBLE = 6;
	c.MODE_OUTLINE = 7;
	c.MODE_GRAPHITE = 8;
	c.MODE_WASH = 9;
	c.MODE_GENTLE_ERASE = 10;
	c.MODE_CIRCLE_ERASE = 11;
	
	c.BRUSH_NAME_BY_MODE = [];
	var bnbm = c.BRUSH_NAME_BY_MODE;
	bnbm[c.MODE_SCRIBBLE] = 'scribble';
	bnbm[c.MODE_SHADE] = 'shade';
	bnbm[c.MODE_LINE] = 'line';
	bnbm[c.MODE_INK] = 'ink';
    bnbm[c.MODE_ERASE] = 'erase';
    bnbm[c.MODE_SCRATCH] = 'scratch';
	bnbm[c.MODE_GRAPHITE] = 'graphite';
	bnbm[c.MODE_WASH] = 'wash';
	bnbm[c.MODE_GENTLE_ERASE] = 'softerase';
	bnbm[c.MODE_CIRCLE_ERASE] = 'harderase';
	
    c.BGCOLOR = '#f2f2e8';
 
	// write state - container refs and data
	var s = VLM.state;
	s.w = window.innerWidth;
	s.h = window.innerHeight;
	s.canvas = document.getElementById('canvas');
	s.context = canvas.getContext('2d');
	s.zoomlevel = 1;
	s.accumdist = 0;
 
    s.color = {
        'name' : 'black',
        'rgba' : [0,0,0,1]
    };
 
	// write some abstractions around brushes
	var i = VLM.ink;
	var brush;
	i.setBrush = function(brushID){
		if (brush){
			brush.destroy();
		}
		
		var brushname = VLM.constants.BRUSH_NAME_BY_MODE[brushID];
		if (brushname){
			//console.log('setting brush: ' + brushname);
			brush = eval( "new " + brushname + "()" );
		} else {
			//console.log('cannot find a matching brush for: ' + brushID);
		}
	};
	
	i.getBrush = function(){ 
		return brush; 
	};
	
	i.beginStroke = function(x,y){
		brush.begin(x,y);
	};
	
	i.continueStroke = function(x,y){
		brush.continue(x,y);
	};
	
	i.endStroke = function(x,y){
		brush.end(x,y);
	};
	
	i.tick = function(){
		brush.tick();
	};
	
	i.clearScreen = function(){
		var state = VLM.state,
			ctx = state.context;
	    ctx.fillStyle = VLM.constants.BGCOLOR;
	    ctx.fillRect(0, 0, state.w, state.h);
	};
	
	var u = VLM.utilities;
	u.is3GS = function(){
		if ( window.devicePixelRatio == 1 && s.w < 768 ) return true;
		return false;
	};

})();
