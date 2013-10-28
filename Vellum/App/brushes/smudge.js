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
	
	init : function(){
		this.context = VLM.state.context;
        
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
                rgba = col.rgba;

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
                    avgsample = 0;
                
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
                        var o = ctx.getImageData(localx, localy, 1, 1);
                        sumsamples += ( 242 - o.data[0] ) / 242;
                    }
                }
                
                avgsample = sumsamples / ( numsamples + 1 );

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

                ctx.strokeStyle = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + smoothed + ')';
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
