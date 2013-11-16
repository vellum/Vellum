function smudge(){
	this.init();
}

smudge.prototype = {
	context: null,
	target : { x:0, y:0 },
	prev : { x:0, y:0, nib:0, angle:0 },
	interpolation_multiplier : 0.25,
    distance_multiplier : 2.5,
    nib_multiplier : 0.25,
	step : 1.5,
    smoothed_alpha : 0,
    smoothed_rgba : {r:0,g:0,b:0,a:0},
    smoothed_hsb : {h:0,s:0,b:0},
	
	init : function(){
		this.context = VLM.state.context;
        this.smoothed_rgba = {r:0,g:0,b:0,a:0};
        var state = VLM.state;
        if ( state.isIPad ){
            if ( state.isRetina ){
                
            } else {
                this.interpolation_multiplier = 0.375;
                this.distance_multiplier = 2.0;
                this.nib_multiplier = 0.25;
                this.step = 1.0;
                
            }
        } else {
            if ( state.isRetina ){
                
            } else {
                this.interpolation_multiplier = 0.375;
                this.distance_multiplier = 2.0;
                this.nib_multiplier = 0.25;
                this.step = 0.5;

            }
        }
        
        this.smoothed_alpha = 0;
	},
	
	begin : function(x,y){
        var prev = this.prev,
            target = this.target;
			prev.x = x;
		prev.y = y;
		prev.angle = 0;
		prev.nib = 0;
		target.x = x;
		target.y = y;
        this.smoothed_alpha = 0;
        this.smoothed_hsb = null;
	},
	
	continue : function(x,y){
        var prev = this.prev,
            target = this.target;
		target.x = x;
		target.y = y;
	},
    
	end : function(x,y){
	    var prev = this.prev,
	        target = this.target;
	    target.x = x;
	    target.y = y;
	},
	
	tick : function(){
        
        var prev = this.prev,
            target = this.target,
            interpolation_multiplier = this.interpolation_multiplier,
            distance_multiplier = this.distance_multiplier,
            nib_multiplier = this.nib_multiplier,
            ctx = this.context;
        
		var x = prev.x + (target.x - prev.x) * interpolation_multiplier,
	        y = prev.y + (target.y - prev.y) * interpolation_multiplier,
            dx = target.x-x,
            dy = target.y-y,
	        dist = Math.sqrt(dx * dx + dy * dy),
	        state = VLM.state,
	        zoomlevel = state.zoomlevel,
	        threshold = 0.001 / (zoomlevel * 1000);
        
	    if (dist >= threshold) {
            
			var angle = Math.atan2(dy, dx) - Math.PI / 2,
                curnib = (prev.nib + dist * distance_multiplier) * nib_multiplier,
                multiplier = 1.0,
                count = 0,
                cosangle = Math.cos(angle),
                sinangle = Math.sin(angle),
                cospangle = Math.cos(prev.angle),
                sinpangle = Math.sin(prev.angle),
                vertexCount = 0,
                currange = curnib * multiplier,
                prevrange = prev.nib * multiplier,
                fgcolor = '#000000',
                col = VLM.state.color,
                rgba = {r:0,g:0,b:0},
                hsv = {h:0,s:0,v:0};

            if (zoomlevel < 10) {

                ctx.beginPath();
                
                if (zoomlevel < 1) {
                    ctx.lineWidth = 0.05;
                } else {
                    ctx.lineWidth = 0.1;
                }

				var ut = VLM.utilities;
				if ( ut.is3GS() ){
					ctx.lineWidth *= 0.5;
				}

                var step = this.step,
                    numsteps = 0,
                    sumsamples = 0,
                    numsamples = dist / 1,
                    avgsample = 0,
                    validsamplecount = 0;

                
                for (var i = 0; i < numsamples; i++){

                    var pct = i / numsamples,
                        localx = prev.x + dx * pct,
                        localy = prev.y + dy * pct,
                        shouldProceed = true;

                    // bounds check
                    if ( localx < 0 ) shouldProceed = false;
                    else if ( localx > state.w - 3 ) shouldProceed = false;
                    else if ( localy < 0 ) shouldProceed = false;
                    else if ( localy > state.h - 3 ) shouldProceed = false;
                    
                    if ( shouldProceed ){
                        localx = Math.round( localx );
                        localy = Math.round( localy );
                        var o = ctx.getImageData(localx, localy, 1, 1),
                            tiny = tinycolor('rgb(' + o.data[0] + ', ' + o.data[1] + ',' + o.data[2] + ')'),
                            tohsv = tiny.toHsv();
                        //console.log(tiny.toHsvString());
                        
                        console.log( '*', tohsv.h, tohsv.s, tohsv.v );
                        
                        
                        if ( tohsv.v > 0 && tohsv.v < 0.9 ){
                            //hsv.h+= tohsv.h;
                            //hsv.s+= tohsv.s;
                            //hsv.v+= tohsv.v;
                            //validsamplecount++;
                        }
                        
                        if ( o.data[0] < 242 ){
                            rgba.r += o.data[0];
                            rgba.g += o.data[1];
                            rgba.b += o.data[2];
                            
                            sumsamples += ( 242 - o.data[0] ) / 242;
                            
                            hsv.h+= tohsv.h;
                            hsv.s+= tohsv.s;
                            hsv.v+= tohsv.v;
                            validsamplecount++;

                        }
                    }
                }
                
                avgsample = sumsamples / ( numsamples + 1 );
                rgba.r /= numsamples;
                rgba.g /= numsamples;
                rgba.b /= numsamples;
                
                if (validsamplecount>0){
                    hsv.h /= validsamplecount;
                    hsv.s /= validsamplecount;
                    hsv.v /= validsamplecount;
                    
                } else {
                    hsv.h = 0;
                    hsv.s = 0;
                    hsv.v = 0;
                }
                
                var ttt = tinycolor('hsv(' + hsv.h + ',' + hsv.s + ',' + hsv.v + ')'),
                    tinyrgb = ttt.toRgb();
                //console.log(ttt.toHsvString());
                this.smoothed_rgba.r += ( rgba.r - this.smoothed_rgba.r ) * 0.5;
                this.smoothed_rgba.g += ( rgba.g - this.smoothed_rgba.g ) * 0.5;
                this.smoothed_rgba.b += ( rgba.b - this.smoothed_rgba.b ) * 0.5;

                // clamp average sampled value
                if ( avgsample > 0.25 ) avgsample = 0.25;
                
                // get smoothed value
                var smoothed = this.smoothed_alpha;
                smoothed += ( avgsample - smoothed ) * 0.25;
                // smoothed = 0.5 * smoothed + 0.5 * avgsample;
                
                smoothed *= 100;
                smoothed = Math.round( smoothed );
                smoothed /= 100;

                // store it for the next tick
                this.smoothed_alpha = smoothed;
                
                var ss = hsv.s * 0.9,
                bb = hsv.v * 0.75;
                ttt = tinycolor('hsv(' + hsv.h + ',' + ss + ',' + bb + ')');
                tinyrgb = ttt.toRgb();
                ctx.strokeStyle = 'rgba(' + tinyrgb.r + ',' + tinyrgb.g + ',' + tinyrgb.b + ',' + smoothed + ')';
                //ctx.strokeStyle = 'rgba(' + tinyrgb.r + ',' + tinyrgb.g + ',' + tinyrgb.b + ',' + 0.25 + ')';
                ctx.fillStyle = 'rgba(0,0,0,0)';
                
                for (var i = -currange; i <= currange; i += step) {
                    numsteps++;
                    var pct = i / currange,
                    localx = x + cosangle * pct * currange,
                    localy = y + sinangle * pct * currange,
                    localpx = prev.x + cospangle * pct * prevrange,
                    localpy = prev.y + sinpangle * pct * prevrange;

                    var deltax, deltay;
                    deltax = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
                    deltay = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
                    ctx.moveTo(localpx + deltax, localpy + deltay);
                    deltax = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
                    deltay = (Math.random() > 0.5) ? Math.random() * -currange / 2 : Math.random() * currange / 2;
                    
                    ctx.lineTo(localx + deltax, localy + deltay);
                }
                //console.log (ctx.strokeStyle );

                ctx.stroke();
                ctx.closePath();
            } else {
                this.smoothed_alpha = 0;
            }
            
			prev.angle = angle;
			prev.nib = curnib;
		}
	    prev.x = x;
	    prev.y = y;
	},
	
	destroy : function(){
		this.target = null;
		this.prev = null;
	}
};
