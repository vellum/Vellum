function shade(){
	this.init();
}

shade.prototype = {
	context: null,
	target : { x:0, y:0 },
	prev : { x:0, y:0, nib:0, angle:0 },
	interpolation_multiplier : 0.5,
    distance_multiplier : 2.5,
    nib_multiplier : 0.25,
	step : 1.5,
	
	init : function(){
		this.context = VLM.state.context;
	    if ( VLM.utilities.is3GS() ){
	        this.interpolation_multiplier = 0.375;
	        this.distance_multiplier = 2.0;
			this.nib_multiplier = 0.25;
			this.step = 1.1;
	    }
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
            nib_multiplier = this.nib_multiplier;

		var x = prev.x + (target.x - prev.x) * interpolation_multiplier,
	        y = prev.y + (target.y - prev.y) * interpolation_multiplier,
	        //dx = x - prev.x,
	        //dy = y - prev.y,
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
            ctx = this.context;
            
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

                ctx.strokeStyle = fgcolor;
                var step = 1.5;
                for (var i = -currange; i <= currange; i += step) {
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
                ctx.stroke();
                ctx.closePath();
            } else {
                ctx.beginPath();
                ctx.lineWidth = 0.45;
                ctx.strokeStyle = fgcolor;
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
	}
};
