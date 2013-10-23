function line(){
	this.init();
}

line.prototype = {
	context: null,
	target : { x:0, y:0 },
	prev : { x:0, y:0, nib:0, angle:0 },
	interpolation_multiplier : 0.25,
    distance_multiplier : 2,//1.5,
    nib_multiplier : 0.125,
	step : 0.25,
	accumdist : 0,
	
	init : function(){
		this.context = VLM.state.context;
	},
	
	begin : function(x,y){
        var prev = this.prev,
            target = this.target;
			prev.x = x;
		prev.y = y;
		prev.angle = 0;
		prev.nib = 5;
		target.x = x;
		target.y = y;
		this.accumdist = 0;
	},
	
	continue : function(x,y){
        var prev = this.prev,
            target = this.target;
		target.x = x;
		target.y = y;
		/*
		var dx = x-this.prev.x,
			dy = y-this.prev.y;
		this.accumdist += Math.sqrt( dx*dx + dy*dy );
         */
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
	        dx = x - prev.x,
	        dy = y - prev.y,
	        dist = Math.sqrt(dx * dx + dy * dy),
	        state = VLM.state,
	        zoomlevel = state.zoomlevel,
	        threshold = 0.001 / (zoomlevel * 1000);
        
        this.accumdist += dist;
        
        if (dist < threshold) {
            prev.x = x;
            prev.y = y;
            return;
        }
		var angle = Math.atan2(dy, dx) - Math.PI / 2,
            curnib = prev.nib + (dist * distance_multiplier - prev.nib) * nib_multiplier;
        
        if (state.isIPad){
            if ( curnib > 10 ) curnib = 10;
        } else {
            if ( curnib > 4 ) curnib = 4;
        }
	    var multiplier = 0.25,
	        count = 0,
	        cosangle = Math.cos(angle),
	        sinangle = Math.sin(angle),
	        cospangle = Math.cos(prev.angle),
	        sinpangle = Math.sin(prev.angle),
	        vertexCount = 0,
	        currange = curnib * multiplier,
	        prevrange = prev.nib * multiplier,
	        fgcolor = 'rgba(0,0,0,0.5)',
	        ctx = this.context;
        
        // overwrite fgcolor with whatever is in state
        var col = state.color,
        rgba = col.rgba,
        alpha = rgba[3];
        var fgg;

        // transform it
        if (state.isIPad){
            
            if ( alpha > 0.75 ){
                alpha = 0.5;
            } else if ( alpha > 0.5 ){
                alpha = 0.25;
            } else if ( alpha > 0.25 ){
                alpha = 0.1;
            } else {
                alpha = 0.05;
            }
            fgg = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + alpha*0.66  + ')';
        } else {
            if ( alpha > 0.75 ){
                alpha = 1.0;
            } else if ( alpha > 0.5 ){
                alpha = 0.5;
            } else if ( alpha > 0.25 ){
                alpha = 0.25;
            } else {
                alpha = 0.1;
            }
            fgg = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + alpha*0.5 + ')';
        }
        fgcolor = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + alpha + ')';

        ctx.beginPath();
        ctx.lineWidth = 0.125;
        ctx.strokeStyle = fgg;//color;
        
        var step = 1;
        
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

		var linwin = this.accumdist;
        linwin /= (500 / zoomlevel);
        if (linwin < 0.45) linwin = 0.45;
        if (linwin > 0.75) linwin = 0.75;
        ctx.strokeStyle = fgcolor;

        ctx.beginPath();
        
        if (state.isIPad){
            ctx.lineWidth = 1.5;
        } else {
            ctx.lineWidth = 0.5;
        }
        ctx.moveTo(prev.x, prev.y);
        ctx.lineTo(x, y);
        ctx.stroke();
        ctx.closePath();
		
		prev.angle = angle;
		prev.nib = curnib;
		prev.x = x;
	    prev.y = y;
	},
	
	destroy : function(){
        this.context = null;
		this.target = null;
		this.prev = null;
	}
};
