function harderase(){
	this.init();
}

harderase.prototype = {
	context: null,
	target : { x:0, y:0 },
	prev : { x:0, y:0 },
	interpolation_multiplier : ( window.devicePixelRatio == 1 ) ? 0.5 : 0.25,
	color : '#000000',
	init : function(){
		this.context = VLM.state.context;
        
        // overwrite fgcolor with whatever is in state
        var col = VLM.state.color,
        rgba = col.rgba,
        hue,
        sat,
        lig;
        
        // black
        if (rgba[0]==0){
            hue = 0;
            sat = 0;
            lig = 100 * (1-rgba[3]);
            var t = tinycolor('hsl(' + hue + ',' + 0 + '%,' + Math.round(lig) + '%)');
            this.color = t.toHexString();
            // erase
        } else {
            this.color = 'rgba(242,242,232,1)';
        }

	},
	
	begin : function(x,y){
        var prev = this.prev,
            target = this.target;
        prev.x = x;
		prev.y = y;
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
        var interpolation_multiplier = 0.25,
            ctx = this.context,
            state = VLM.state,
            zoomlevel = state.zoomlevel;

	    if ( window.devicePixelRatio == 1 && zoomlevel < 1 ){
            interpolation_multiplier *= 1/zoomlevel;
        }
        
        var prev = this.prev,
            target = this.target,
            x = prev.x + (target.x - prev.x) * interpolation_multiplier,
            y = prev.y + (target.y - prev.y) * interpolation_multiplier,
            dx = target.x-x,
            dy = target.y-y,
            dist = Math.sqrt(dx * dx + dy * dy),
            threshold = 0.001 / (zoomlevel * 1000);

	    if (dist>=threshold) {
            var curnib = 30 / zoomlevel;
            ctx.beginPath();
            ctx.fillStyle = this.color;//'rgba(242,242,232,1)';
            ctx.arc(x, y, curnib / 2, 0, Math.PI * 2, true);
            ctx.fill();
            ctx.closePath();
            
            ctx.beginPath();
            ctx.lineWidth = curnib;
            ctx.strokeStyle = this.color;//'rgba(242,242,232,1)';
            ctx.moveTo(x, y);
            ctx.lineTo(prev.x, prev.y);
            ctx.stroke();
            ctx.closePath();
            
	    }
	    prev.x = x;
	    prev.y = y;

    },
	
	destroy : function(){
		this.target = null;
		this.prev = null;	
		this.context = null;
		this.interpolation_multiplier = null;
	}
};
