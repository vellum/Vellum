function harderase(){
	this.init();
}

harderase.prototype = {

	context: null,
	prev : { x:0, y:0 },
	accumdist : 0,
	interpolation_multiplier : ( window.devicePixelRatio == 1 ) ? 0.5 : 0.25,
	color : '#000000',
	init : function(){

		this.context = VLM.state.context;

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
		var prev = this.prev;
		prev.x = x;
		prev.y = y;
		this.accumdist = 0;
	},
	
	continue : function(arr){
		var prev = this.prev,
            origin = prev,
			ctx = this.context,
			state = VLM.state,
			zoomlevel = state.zoomlevel,
            curnib = 30 / zoomlevel,
			start = arr[ 0 ],
			end = arr[ arr.length-1 ],
			dx = end.x - start.x,
			dy = end.y - start.y;


		this.accumdist += Math.sqrt( dy*dy + dx*dx );
		if ( this.accumdist < 5 ) {
            this.prev.x = end.x;
            this.prev.y = end.y;
            return;
        }
        
        if ( true ){
            ctx.beginPath();
            ctx.lineWidth = curnib;
            ctx.strokeStyle = this.color;
            for ( var i = 0; i < arr.length; i++ ){
                var p = arr[ i ],
                x = p.x,
                y = p.y;
                ctx.moveTo( prev.x, prev.y );
                ctx.lineTo( x, y );
                prev.x = p.x;
                prev.y = p.y;
            }
            ctx.stroke();
            ctx.closePath();
            
            prev = origin;
            ctx.beginPath();
            ctx.fillStyle = this.color;
            for ( var i = 0; i < arr.length; i++ ){
                var p = arr[ i ];
                ctx.arc(p.x, p.y, curnib / 2, 0, Math.PI * 2, true);
            }
            ctx.arc(origin.x, origin.y, curnib / 2, 0, Math.PI * 2, true);
            ctx.fill();
            ctx.closePath();
        }
	},
	
	end : function(x,y){
	},
	
	tick : function(){
	},
	
	destroy : function(){
		this.prev = null;	
		this.context = null;
		this.interpolation_multiplier = null;
	}
};
