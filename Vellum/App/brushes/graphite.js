function graphite(){
	this.init();
}

graphite.prototype = {
	context: null,
	target : { x:0, y:0 },
	prev : { x:0, y:0, nib:0, angle:0 },
	interpolation_multiplier : 0.5,
    distance_multiplier : 2.5,
    nib_multiplier : 0.25,
	grr_fg : 'rgba(0,0,0,0.5)',
	tickcount : 0,
    
	init : function(){
		this.context = VLM.state.context;
        
        
        
        // overwrite fgcolor with whatever is in state
        var col = VLM.state.color,
        rgba = col.rgba;
        var alpha = rgba[3];

        
        var state = VLM.state;
        if (state.isIPad){
        
            if (state.isRetina){

                console.log('this is a retina ipad');
                
                if ( alpha > 0.75 ){
                    alpha = 1;
                } else if ( alpha > 0.5 ){
                    alpha = 0.4;
                } else if ( alpha > 0.25 ){
                    alpha = 0.2;
                } else {
                    alpha = 0.1;
                }
                this.grr_fg = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + alpha*0.75 + ')';

            } else {
                
                if ( alpha > 0.75 ){
                    alpha = 1;
                } else if ( alpha > 0.5 ){
                    alpha = 0.4;
                } else if ( alpha > 0.25 ){
                    alpha = 0.2;
                } else {
                    alpha = 0.1;
                }
                console.log('this is a non-retina ipad');
                this.grr_fg = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + alpha*0.75 + ')';

            }
            
        } else {
            
            if (state.isRetina){
                
                console.log('this is a retina iphone');
                if ( alpha > 0.75 ){
                    alpha = 1;
                } else if ( alpha > 0.5 ){
                    alpha = 0.4;
                } else if ( alpha > 0.25 ){
                    alpha = 0.2;
                } else {
                    alpha = 0.1;
                }

                this.grr_fg = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + alpha*0.75 + ')';

                
            }
            else {
                
                console.log('this is a non-retina iphone');
                
                this.interpolation_multiplier = 0.375;
                this.distance_multiplier = 0.75;
                this.nib_multiplier = 0.5;
                
                if ( alpha > 0.75 ){
                    alpha = 0.9;
                } else if ( alpha > 0.5 ){
                    alpha = 0.6;
                } else if ( alpha > 0.25 ){
                    alpha = 0.3;
                } else {
                    alpha = 0.15;
                }
                this.grr_fg = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + alpha*0.75 + ')';

            }
   
        }
        
        this.begin(0,0);
        this.end(0,0);
        
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
        this.tickcount = 0;
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
        
        this.tickcount = this.tickcount + 1;
        var state = VLM.state;

        var prev = this.prev,
            target = this.target,
            interpolation_multiplier = this.interpolation_multiplier,
            distance_multiplier = this.distance_multiplier,
            nib_multiplier = this.nib_multiplier;

		var x = prev.x + (target.x - prev.x) * interpolation_multiplier,
	        y = prev.y + (target.y - prev.y) * interpolation_multiplier,
            dx = target.x-x,
            dy = target.y-y,
	        dist = Math.sqrt(dx * dx + dy * dy),
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
            ctx = this.context;
            
            
            if (zoomlevel < 10) {
                ctx.beginPath();
                ctx.strokeStyle = this.grr_fg;
                ctx.lineWidth = 0.45; // solid lines MOIRE
                
				// FIXME: this should be an instance variable 
                var step = 2.5;
                if ( !state.isRetina ){
                    if ( !state.isIPad ){
                        ctx.lineWidth = 0.45;//0.9;
                    }
                }
                
                for (var i = -currange; i <= currange; i += step) {
                    var pct = i / currange,
                    localx = x + cosangle * pct * currange,
                    localy = y + sinangle * pct * currange,
                    localpx = prev.x + cospangle * pct * prevrange,
                    localpy = prev.y + sinpangle * pct * prevrange;
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
			                    x: x + pct * (x-prev.x),
			                    y: y + pct * (y-prev.y),
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
                ctx.strokeStyle = this.grr_fg;
                ctx.moveTo(x, y);
                ctx.lineTo(prev.x, prev.y);
                ctx.stroke();
                ctx.closePath();
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
		this.context = null;
		this.interpolation_multiplier = null;
	    this.distance_multiplier = null;
	    this.nib_multiplier = null;
		this.grr_fg = null;
	}
};
