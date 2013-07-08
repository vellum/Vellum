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

var MODE_SCRIBBLE = 0,
	MODE_SHADE = 1,
	MODE_INK = 2,
	MODE_SCRATCH = 3,
	MODE_LINE = 4,
	MODE_ERASE = 5,
	MODE_SCRAMBLE = 6, // ?
	MODE_OUTLINE = 7,
	MODE_GRAPHITE = 8,
    MODE_WASH = 9,
    MODE_GENTLE_ERASE = 10,
    MODE_CIRCLE_ERASE = 11,
    BGCOLOR = '#f2f2e8',
    BGCOLOR_RGBA = 'rgba(242,242,232,1)',
    BGCOLOR_RGBA2 = 'rgba(242,242,232,0.75)',
BGCOLOR_RGBA3 = 'rgba(242,242,232,0.25)',
BGCOLOR_RGBA4 = 'rgba(242,242,232,0.666)',

    BRIDGE = new Ejecta.Bridge(),
    FGCOLOR_RGBA = 'rgba(0,0,0,0.5)',
    FGCOLOR_RGBA2 = 'rgba(0,0,0,0.5)';

var w = window.innerWidth,
	h = window.innerHeight,
	canvas = document.getElementById('canvas'),
	ctx = canvas.getContext('2d'),
	prevmouse = { x: 0, y: 0 },
	targetmouse = { x: 0, y: 0 },
	accum = { x:0, y:0 },
	isRestoringPixels = false,
	mousedown = false,
	curnib = 1,
	angle = 0,
	zoomlevel = 1,
	drawmode = MODE_LINE,
	accumdist = 0;

var is3GS = function(){
		if ( window.devicePixelRatio == 1 && w < 768 ) return true;
		return false;
	},
	
	setDrawingMode = function(mode) {
	    drawmode = mode;
	},

	animate = function() {
	    if (isRestoringPixels) { return; }
	    if (mousedown) {
	        switch (drawmode) {
	            case MODE_GRAPHITE:
	                drawgraphite();
	                break;
                
	            case MODE_SCRIBBLE:
	                drawscribble();
	                break;
                
	            case MODE_SHADE:
	                drawshade();
	                break;
                
	            case MODE_SCRATCH:
	                drawscratch();
	                break;
                
	            case MODE_ERASE:
	            case MODE_GENTLE_ERASE:
	                drawerase();
	                break;
                
                case MODE_CIRCLE_ERASE:
                    circleerase();
                    break;

	            case MODE_OUTLINE:
	            case MODE_LINE:
	                drawpencil();
	                break;
                
	            case MODE_INK:
	                drawink();
	                break;
	        }
	    }
	},
	
	drawink = function() {
        
        var interpolation_multiplier = 0.25;
	    if ( window.devicePixelRatio == 1 && zoomlevel < 1 ){
            //interpolation_multiplier = 0.5;
            interpolation_multiplier *= 1/zoomlevel;
        }
        
	    var x = prevmouse.x + (targetmouse.x - prevmouse.x) * interpolation_multiplier,
		    y = prevmouse.y + (targetmouse.y - prevmouse.y) * interpolation_multiplier,
		    dx = targetmouse.x - x,
		    dy = targetmouse.y - y,
		    dist = Math.sqrt(dx * dx + dy * dy),
		    prevnib = curnib,
		    pangle = angle,
		    threshold = 0.001 / (zoomlevel * 1000);
    
	    if (dist >= threshold) {
	        var nib = 20 * dist * 0.005;
	        nib = 5 - nib;
	        if (nib < 0.5) nib = 0.5;
        
	        nib /= zoomlevel * 0.5;
	        curnib += (nib - curnib) * 0.125;
	        ctx.beginPath();
	        ctx.fillStyle = '#000000';
	        ctx.arc(x, y, curnib / 2, 0, Math.PI * 2, true);
	        ctx.fill();
	        ctx.closePath();
        
	        ctx.beginPath();
	        ctx.lineWidth = (zoomlevel < 10) ? curnib : 0.5;
	        ctx.strokeStyle = '#000000';
	        ctx.moveTo(x, y);
	        ctx.lineTo(prevmouse.x, prevmouse.y);
	        ctx.stroke();
	        ctx.closePath();
	    }
	    prevmouse.x = x;
	    prevmouse.y = y;
	},

	drawgraphite = function() {
    
	    var interpolation_multiplier = 0.5,
		    distance_multiplier = 2.5,
		    nib_multiplier = 0.25,
			grr_fg = FGCOLOR_RGBA;
    
	    if ( is3GS() ){
	        interpolation_multiplier = 0.375;
	        distance_multiplier = 2.0;
			nib_multiplier = 0.25;
			grr_fg = 'rgba(0,0,0,0.75)';
	    } 

        
        if ( zoomlevel < 1 ){
            interpolation_multiplier *= 1/zoomlevel;
        }

	    var x = prevmouse.x + (targetmouse.x - prevmouse.x) * interpolation_multiplier,
		    y = prevmouse.y + (targetmouse.y - prevmouse.y) * interpolation_multiplier,
		    dx = targetmouse.x - x,
		    dy = targetmouse.y - y,
		    dist = Math.sqrt(dx * dx + dy * dy),
		    prevnib = curnib,
		    pangle = angle,
		    threshold = 0.001 / (zoomlevel * 1000);
    
	    if (dist >= threshold) {
	        angle = Math.atan2(dy, dx) - Math.PI / 2;
	        curnib += dist * distance_multiplier;
	        curnib *= nib_multiplier;
        
	        var multiplier = 1.0,
	        count = 0,
	        cosangle = Math.cos(angle),
	        sinangle = Math.sin(angle),
	        cospangle = Math.cos(pangle),
	        sinpangle = Math.sin(pangle),
	        vertexCount = 0,
	        currange = curnib * multiplier,
	        prevrange = prevnib * multiplier,
	        fgcolor = grr_fg;
        
        
	        if (zoomlevel < 10) {
	            ctx.beginPath();
	            ctx.strokeStyle = fgcolor;
	            ctx.lineWidth = 0.45;
	            var step = 2.5;
	            if ( is3GS() ){
	                step = 4;
	                ctx.strokeStyle = grr_fg;
	                ctx.lineWidth = 0.5;
	            }
	            for (var i = -currange; i <= currange; i += step) {
	                var pct = i / currange,
	                localx = x + cosangle * pct * currange,
	                localy = y + sinangle * pct * currange,
	                localpx = prevmouse.x + cospangle * pct * prevrange,
	                localpy = prevmouse.y + sinpangle * pct * prevrange;
					ctx.moveTo(localpx, localpy);
	                ctx.lineTo(localx, localy);
	            }
            
	            if (window.devicePixelRatio>1){
	                ctx.stroke();
	                ctx.closePath();
	                ctx.beginPath();
	                ctx.lineWidth = 0.15;
                
	                // interpolate a series of cross hatch marks
	                for ( var i = 0; i <= dist; i += step ){
                    
	                    // interpolated point along line with pressure
	                    var pct = i / dist,
		                    curloc = {
			                    x: x + pct * (x-prevmouse.x),
			                    y: y + pct * (y-prevmouse.y),
			                    p: prevrange + pct * (currange-prevrange)
		                    };
		                    // now compute endpoints of the cross hatch mark
		                    var p0 = {
			                    x:curloc.x + cosangle * -curloc.p,
			                    y:curloc.y + sinangle * -curloc.p
		                    },
		                    p1 = {
			                    x:curloc.x + cosangle * curloc.p,
			                    y:curloc.y + sinangle * curloc.p
		                    };
	                    ctx.moveTo(p0.x,p0.y);
	                    ctx.lineTo(p1.x,p1.y);
	                }
	            }
	            ctx.stroke();
	            ctx.closePath();
	        } else {
	            ctx.beginPath();
	            ctx.lineWidth = 0.45;
	            ctx.strokeStyle = fgcolor;
	            ctx.moveTo(x, y);
	            ctx.lineTo(prevmouse.x, prevmouse.y);
	            ctx.stroke();
	            ctx.closePath();
	        }
	    }
	    prevmouse.x = x;
	    prevmouse.y = y;
	},
	
	drawscribble = function() {
		var interpolation_multiplier = 0.5,
		    distance_multiplier = 2.5,
		    nib_multiplier = 0.25;
    
	    if ( is3GS() ){
	        interpolation_multiplier = 0.375;
	        distance_multiplier = 2.0;
			nib_multiplier = 0.25;
	    }
    
		var x = prevmouse.x + (targetmouse.x - prevmouse.x) * interpolation_multiplier, 
			y = prevmouse.y + (targetmouse.y - prevmouse.y) * interpolation_multiplier, 
			dx = targetmouse.x - x, 
			dy = targetmouse.y - y, 
			dist = Math.sqrt(dx * dx + dy * dy), 
			prevnib = curnib, 
			pangle = angle, 
			threshold = 0.001 / (zoomlevel * 1000);
    
	    if (dist >= threshold) {
	        angle = Math.atan2(dy, dx) - Math.PI / 2;
	        curnib += dist * distance_multiplier;
	        curnib *= nib_multiplier;
        
	        var multiplier = (drawmode == MODE_SCRATCH) ? 0.25 : 1.0, 
				count = 0, 
				cosangle = Math.cos(angle), 
				sinangle = Math.sin(angle), 
				cospangle = Math.cos(pangle), 
				sinpangle = Math.sin(pangle), 
				vertexCount = 0, 
				currange = curnib * multiplier, 
				prevrange = prevnib * multiplier, 
				fgcolor = '#000000';
        
			if (zoomlevel < 10) {
	            ctx.beginPath();
	            if (zoomlevel < 1) {
	                ctx.lineWidth = 0.5; // solid lines MOIRE
	            } else {
	                ctx.lineWidth = 0.45; // these look ok
	            }
	            ctx.strokeStyle = fgcolor;
	            var step = 1.5;
	            for (var i = -currange; i <= currange; i += step) {
	                var pct = i / currange, 
						localx = x + cosangle * pct * currange, 
						localy = y + sinangle * pct * currange, 
						localpx = prevmouse.x + cospangle * pct * prevrange, 
						localpy = prevmouse.y + sinpangle * pct * prevrange;
					var deltax, deltay;
	                deltax = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
	                deltay = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
	                ctx.moveTo(localpx + deltax, localpy + deltay);
	                deltax = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
	                deltay = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
	                ctx.lineTo(localx + deltax, localy + deltay);
	            }            
	            ctx.stroke();
	            ctx.closePath();
	        } else {
	            ctx.beginPath();
	            ctx.lineWidth = 0.45;
	            ctx.strokeStyle = fgcolor;
	            ctx.moveTo(x, y);
	            ctx.lineTo(prevmouse.x, prevmouse.y);
	            ctx.stroke();
	            ctx.closePath();
	        }
	    }
	    prevmouse.x = x;
	    prevmouse.y = y;
	},
	
	drawshade = function() {
    
	    var interpolation_multiplier = 0.5,
		    distance_multiplier = 2.5,
		    nib_multiplier = 0.25,
            step = 1.5;
    
	    if ( is3GS() ){
	        interpolation_multiplier = 0.375;
	        distance_multiplier = 2.0;
			nib_multiplier = 0.25;
			step = 1.1;
	    }
    
	    var x = prevmouse.x + (targetmouse.x - prevmouse.x) * interpolation_multiplier, 
			y = prevmouse.y + (targetmouse.y - prevmouse.y) * interpolation_multiplier, 
			dx = targetmouse.x - x, 
			dy = targetmouse.y - y, 
			dist = Math.sqrt(dx * dx + dy * dy), 
			prevnib = curnib, 
			pangle = angle, 
			threshold = 0.001 / (zoomlevel * 1000);
    
	    if (dist >= threshold) {
	        angle = Math.atan2(dy, dx) - Math.PI / 2;
	        curnib += dist * distance_multiplier;
	        curnib *= nib_multiplier;
        
	        var multiplier = 1.0, 
				count = 0, 
				cosangle = Math.cos(angle), 
				sinangle = Math.sin(angle), 
				cospangle = Math.cos(pangle), 
				sinpangle = Math.sin(pangle), 
				vertexCount = 0, 
				currange = curnib * multiplier, 
				prevrange = prevnib * multiplier, 
				fgcolor = '#000000';
			
	        if (zoomlevel < 10) {
	            ctx.beginPath();
	            if (zoomlevel < 1) {
	                ctx.lineWidth = 0.05; // dots
	            } else {
	                ctx.lineWidth = 0.1; // dots (these look great)
	            }
				if ( is3GS() ){
					ctx.lineWidth *= 0.5;
				}
	            ctx.strokeStyle = fgcolor;
	            for (var i = -currange; i <= currange; i += step) {
	                var pct = i / currange, 
						localx = x + cosangle * pct * currange, 
						localy = y + sinangle * pct * currange, 
						localpx = prevmouse.x + cospangle * pct * prevrange, 
						localpy = prevmouse.y + sinpangle * pct * prevrange;
                
	                var deltax, deltay;
	                deltax = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
	                deltay = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
	                ctx.moveTo(localpx + deltax, localpy + deltay);
                
	                deltax = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
	                deltay = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
	                ctx.lineTo(localx + deltax, localy + deltay);
	            }
	            ctx.stroke();
	            ctx.closePath();
	        } else {
	            ctx.beginPath();
	            ctx.lineWidth = 0.45;
	            ctx.strokeStyle = fgcolor;
	            ctx.moveTo(x, y);
	            ctx.lineTo(prevmouse.x, prevmouse.y);
	            ctx.stroke();
	            ctx.closePath();
	        }
	    }
	    prevmouse.x = x;
	    prevmouse.y = y;
	},

    drawpencil = function() {
        var x = prevmouse.x + (targetmouse.x - prevmouse.x) * 0.25
        , y = prevmouse.y + (targetmouse.y - prevmouse.y) * 0.25
        , dx = targetmouse.x - x
        , dy = targetmouse.y - y
        , dist = Math.sqrt(dx * dx + dy * dy)
        , prevnib = curnib
        , pangle = angle
        , threshold = 0.001 / (zoomlevel * 1000)
        ;
        accumdist += dist;
        if (dist >= threshold) {
            angle = Math.atan2(dy, dx) - Math.PI / 2;
            
            curnib += dist * 1.5;
            curnib *= 0.125;
            
            var multiplier = 0.25
            , count = 0
            , cosangle = Math.cos(angle)
            , sinangle = Math.sin(angle)
            , cospangle = Math.cos(pangle)
            , sinpangle = Math.sin(pangle)
            , vertexCount = 0
            , currange = curnib * multiplier
            , prevrange = prevnib * multiplier
            , fgcolor = FGCOLOR_RGBA2//'#000000'
            ;
            
            ctx.beginPath();
            ctx.lineWidth = 0.125;
            ctx.strokeStyle = FGCOLOR_RGBA2;//'rgba(0,0,0,0.25)';
            
            for (var i = -currange; i <= currange; i += 1) {
                var pct = i / currange
                , localx = x + cosangle * pct * currange
                , localy = y + sinangle * pct * currange
                , localpx = prevmouse.x + cospangle * pct * prevrange
                , localpy = prevmouse.y + sinpangle * pct * prevrange
                ;
                
                deltax = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
                deltay = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
                ctx.moveTo(localpx + deltax, localpy + deltay);
                
                deltax = (Math.random() > 0.5) ? Math.random() * -prevrange / 2 : Math.random() * prevrange / 2;
                deltay = (Math.random() > 0.5) ? Math.random() * -prevrange / 2 : Math.random() * prevrange / 2;
                ctx.lineTo(localx + deltax, localy + deltay);
            }
            ctx.stroke();
            ctx.closePath();
            
            var linwin = accumdist;
            linwin /= (500 / zoomlevel);
            if (linwin < 0.45) linwin = 0.45;
            if (linwin > 0.75) linwin = 0.75;
            
            ctx.beginPath();
            ctx.lineWidth = linwin;
            //ctx.strokeStyle = 'rgba(0,0,0,0.5)';
            
            ctx.moveTo(prevmouse.x, prevmouse.y);
            ctx.lineTo(x, y);
            ctx.stroke();
            ctx.closePath();
        }
        prevmouse.x = x;
        prevmouse.y = y;
    },

    drawerase = function() {
    var interpolation_multiplier = 0.5,
	    distance_multiplier = 2.5,
	    nib_multiplier = 0.25,
		step = 0.75;

    //if ( is3GS() ){
    if ( window.devicePixelRatio == 1 ){
        interpolation_multiplier = 0.375;
        distance_multiplier = 4.0;
		nib_multiplier = 0.125;
		step = 1.5;
    } else {
        if ( canvas.width > 768 && drawmode != MODE_GENTLE_ERASE ){
            interpolation_multiplier = 0.375;
            distance_multiplier = 4.0;
            nib_multiplier = 0.125;
            step = 1.5;
        }
    }
    var x = prevmouse.x + (targetmouse.x - prevmouse.x) * interpolation_multiplier, 
		y = prevmouse.y + (targetmouse.y - prevmouse.y) * interpolation_multiplier, 
		dx = targetmouse.x - x, 
		dy = targetmouse.y - y, 
		dist = Math.sqrt(dx * dx + dy * dy), 
		prevnib = curnib, 
		pangle = angle, 
		threshold = 0.001 / (zoomlevel * 1000);
    
    if (dist >= threshold) {
        angle = Math.atan2(dy, dx) - Math.PI / 2;
        curnib += dist * distance_multiplier;
        curnib *= nib_multiplier;
    
        var multiplier = 1.0, 
			count = 0, 
			cosangle = Math.cos(angle), 
			sinangle = Math.sin(angle), 
			cospangle = Math.cos(pangle), 
			sinpangle = Math.sin(pangle), 
			vertexCount = 0, 
			currange = curnib * multiplier, 
			prevrange = prevnib * multiplier, 
			fgcolor = BGCOLOR_RGBA;
        
        if ( drawmode == MODE_GENTLE_ERASE ){
            fgcolor = BGCOLOR_RGBA3;
        }
        if (zoomlevel < 10) {
            ctx.beginPath();
            
            if (zoomlevel < 1) {
                ctx.lineWidth = 0.5; // solid lines MOIRE
            } else {
                ctx.lineWidth = 0.15; //
            }
            ctx.strokeStyle = fgcolor;
            
            for (var i = -currange; i <= currange; i += step) {
                var pct = i / currange
                , localx = x + cosangle * pct * currange
                , localy = y + sinangle * pct * currange
                , localpx = prevmouse.x + cospangle * pct * prevrange
                , localpy = prevmouse.y + sinpangle * pct * prevrange
                ;
                ctx.moveTo(localpx, localpy);
                ctx.lineTo(localx, localy);
            }
            ctx.stroke();
            ctx.closePath();
        } else {
            ctx.beginPath();
            ctx.lineWidth = 0.45;
            ctx.strokeStyle = fgcolor;
            ctx.moveTo(x, y);
            ctx.lineTo(prevmouse.x, prevmouse.y);
            ctx.stroke();
            ctx.closePath();
        }
    }
    prevmouse.x = x;
    prevmouse.y = y;
},

    drawscratch = function() {
    
    var interpolation_multiplier = 0.5;
    var distance_multiplier = 2.5;
	var nib_multiplier = 0.25;
    
    if ( is3GS() ){
        interpolation_multiplier = 0.333;
        distance_multiplier = 1.25;
		nib_multiplier = 0.25;
    }

    var x = prevmouse.x + (targetmouse.x - prevmouse.x) * interpolation_multiplier
	    , y = prevmouse.y + (targetmouse.y - prevmouse.y) * interpolation_multiplier
	    , dx = targetmouse.x - x
	    , dy = targetmouse.y - y
	    , dist = Math.sqrt(dx * dx + dy * dy)
	    , prevnib = curnib
	    , pangle = angle
	    , threshold = 0.001 / (zoomlevel * 1000)
	    ;
    
    if (dist >= threshold) {
        angle = Math.atan2(dy, dx) - Math.PI / 2;
        
        curnib += dist * distance_multiplier;
        curnib *= nib_multiplier;
        
        var multiplier = 0.25
        , count = 0
        , cosangle = Math.cos(angle)
        , sinangle = Math.sin(angle)
        , cospangle = Math.cos(pangle)
        , sinpangle = Math.sin(pangle)
        , vertexCount = 0
        , currange = curnib * multiplier
        , prevrange = prevnib * multiplier
        , fgcolor = BGCOLOR_RGBA4
        ;
        
        
        if (zoomlevel < 10) {
            ctx.beginPath();
            
            if (zoomlevel < 1) {
                ctx.lineWidth = 0.5; // solid lines MOIRE
            } else {
                ctx.lineWidth = 0.5; //
            }
            ctx.strokeStyle = fgcolor;
            var step = 1.5;
            
            for (var i = -currange; i <= currange; i += step) {
                var pct = i / currange
                , localx = x + cosangle * pct * currange
                , localy = y + sinangle * pct * currange
                , localpx = prevmouse.x + cospangle * pct * prevrange
                , localpy = prevmouse.y + sinpangle * pct * prevrange
                ;
                
                ctx.moveTo(localpx, localpy);
                ctx.lineTo(localx, localy);
            }
            
            ctx.stroke();
            ctx.closePath();
        } else {
            ctx.beginPath();
            ctx.lineWidth = 0.45;
            ctx.strokeStyle = fgcolor;
            ctx.moveTo(x, y);
            ctx.lineTo(prevmouse.x, prevmouse.y);
            ctx.stroke();
            ctx.closePath();
        }
    }
    prevmouse.x = x;
    prevmouse.y = y;
};

var line = function() {
    var x = prevmouse.x + (targetmouse.x - prevmouse.x) * 0.25
    , y = prevmouse.y + (targetmouse.y - prevmouse.y) * 0.25
    , dx = targetmouse.x - x
    , dy = targetmouse.y - y
    , dist = Math.sqrt(dx * dx + dy * dy)
    , prevnib = curnib
    , pangle = angle
    , threshold = 0.001 / (zoomlevel * 1000)
    ;
    if (dist >= threshold) {
        // this version is like one width
        /*        var nib = 20 * dist * 0.005;
         nib = 20 - nib;
         if ( nib < 0.125 )
         nib = 0.125;
         if (nib > 3)nib = 3;
         */
        // this version is like paper draw
        var nib = dist * 0.125;
        curnib += (nib - curnib) * 0.125;
        
        ctx.beginPath();
        ctx.fillStyle = '#000000';
        ctx.arc(x, y, curnib / 2, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.closePath();
        
        ctx.beginPath();
        ctx.lineWidth = (zoomlevel < 10) ? curnib : 0.5;
        ctx.strokeStyle = '#000000';
        ctx.moveTo(x, y);
        ctx.lineTo(prevmouse.x, prevmouse.y);
        ctx.stroke();
        ctx.closePath();
    }
    prevmouse.x = x;
    prevmouse.y = y;
};

var circleerase = function(){
    var interpolation_multiplier = ( window.devicePixelRatio == 1 ) ? 0.5 : 0.25;
    var x = prevmouse.x + (targetmouse.x - prevmouse.x) * interpolation_multiplier,
    y = prevmouse.y + (targetmouse.y - prevmouse.y) * interpolation_multiplier,
    dx = targetmouse.x - x,
    dy = targetmouse.y - y,
    dist = Math.sqrt(dx * dx + dy * dy),
    pangle = angle,
    threshold = 0.001 / (zoomlevel * 1000);
    
    if (dist >= threshold) {
       
        curnib = 30;
        curnib /= zoomlevel;

        ctx.beginPath();
        ctx.fillStyle = BGCOLOR_RGBA;
        ctx.arc(x, y, curnib / 2, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.closePath();
        
        ctx.beginPath();
        ctx.lineWidth = curnib;
        ctx.strokeStyle = BGCOLOR_RGBA;
        ctx.moveTo(x, y);
        ctx.lineTo(prevmouse.x, prevmouse.y);
        ctx.stroke();
        ctx.closePath();
    }
    prevmouse.x = x;
    prevmouse.y = y;
};

var setup = function() {
    canvas.width = w;
    canvas.height = h;
    clearScreen();
    ctx.globalAlpha = 1;
    ctx.lineWidth = 1;
    setInterval(animate, 16);
};

var beginStroke = function(x, y) {
    cancelQueuedSave();
    ////console.log( 'beginStroke: ' + x + ', ' + y );
    accumdist = 0;
    accum = { x:0, y:0 };
    mousedown = true;
    targetmouse.x = prevmouse.x = x;
    targetmouse.y = prevmouse.y = y;
    curnib = 1;
    angle = 0;
};

var continueStroke = function(x, y) {
    cancelQueuedSave();
    ////console.log( 'continueStroke: ' + x + ', ' + y );
    mousedown = true;
    targetmouse.x = x;
    targetmouse.y = y;
    
    // this is lame
    accum.x += (x - prevmouse.x);
    accum.y += (y - prevmouse.y);
};

var endStroke = function(x, y) {
    mousedown = false;
    ////console.log( 'endStroke: ' + x + ', ' + y );
    //var backingStorePixelRatio = ctx.backingStorePixelRatio;
    saveUndoState();
};

var setZoom = function(val) {
    zoomlevel = Number(val);
    ////console.log('setzoom:'+zoomlevel);
};

var clearScreen = function() {
    ctx.fillStyle = BGCOLOR;
    ctx.fillRect(0, 0, w, h);
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
}

var saveUndoState = function() {
    // disable undo for ipad, since glreadpixels is slow and blocks drawing operations
    if (!BRIDGE) BRIDGE = new Ejecta.Bridge();
    if ( BRIDGE.isIPad ) return;
    
    if (Math.sqrt(accum.x * accum.x + accum.y * accum.y) < 5) return;
    var millis = Date.now();
    var elapsed = millis - lastundostamp;
    var ELAPSED_THRESHOLD = 1000; // good for retina iphone
    //var ELAPSED_THRESHOLD = 5000;// good for retina ipad (glreadpixels is slow)
    
    if (elapsed < ELAPSED_THRESHOLD) {
        return;
    }
    
    saveUndoStateGuts();
    
    // - - - -  this sets up a timer that calls saves sometime later - - - -
    //cancelQueuedSave();
    //timerID = setTimeout(saveUndoStateGuts, 1000);
};

var saveUndoStateGuts = function() {
    var millis = Date.now();
    
    // if we've previously restored a state mid list, drop every state after the current state
    if (undoIndex < undoStates.length - 1) {
        clearUndosAfterIndex(undoIndex);
    }
    
    // remove first item if we're over our limit
    if (undoStates.length + 1 > MAX_UNDO_COUNT) {
        undoStates.splice(0, 1);
    }
    
    lastundostamp = millis;
    var data = ctx.getImageDataHD(0, 0, w * backingStorePixelRatio, h * backingStorePixelRatio);
    undoStates.push(data);
    undoIndex = undoStates.length - 1;
    
    
    // call out to the native side and update these values
    if (!BRIDGE) BRIDGE = new Ejecta.Bridge();
    BRIDGE.undoCount = undoStates.length;
    BRIDGE.undoIndex = undoIndex;
}

var restoreUndoStateAtIndex = function(index_in) {
    
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
};

var clearUndos = function() {
    undoStates = [];
    undoIndex = 0;
    // call out to the native side and update these values
    if (!BRIDGE) BRIDGE = new Ejecta.Bridge();
    BRIDGE.undoCount = undoStates.length;
    BRIDGE.undoIndex = undoIndex;
}

var clearUndosAfterIndex = function(index_in) {
    var numslotstodelete = undoStates.length - index_in - 1;
    if (numslotstodelete > 0) {
        //console.log('removing undo states after ' + index_in);
        undoStates.splice(index_in + 1, numslotstodelete);
    }
}
setup();