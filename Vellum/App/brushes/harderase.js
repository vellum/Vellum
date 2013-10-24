function harderase(){
	this.init();
}

harderase.prototype = {

	context: null,
	prev : { x:0, y:0 },
	color : '#000000',
	init : function(){
		this.context = VLM.state.context;
		var col = VLM.state.color,
			rgba = col.rgba,
			hue,
			sat,
			lig;
		if (rgba[0]==0){
			hue = 0;
			sat = 0;
			lig = 100 * (1-rgba[3]);
			var t = tinycolor('hsl(' + hue + ',' + 0 + '%,' + Math.round(lig) + '%)');
			this.color = t.toHexString();
		} else {
			this.color = 'rgba(242,242,232,1)';
		}
	},
	
	begin : function(x,y){
		var prev = this.prev;
		prev.x = x;
		prev.y = y;
	},
	
	continue : function(obj){
        var arr = obj.arr,
            travel = obj.travel,
            threshold = 15,
            prev = this.prev,
            origin = prev,
			ctx = this.context,
			state = VLM.state,
			zoomlevel = state.zoomlevel,
            curnib = Math.round( 30 / zoomlevel ),
			end = arr[ arr.length-1 ];
        ctx.beginPath();
        ctx.lineWidth = curnib;
        ctx.strokeStyle = ctx.fillStyle = this.color;
        curnib /= 2;
        var points = [];
        for ( var i = 0; i < arr.length; i++ ){
            var p = arr[ i ],
                x = p.x,
                y = p.y,
                dx = x - prev.x,
                dy = y - prev.y,
                angle = Math.atan2(dy, dx) - Math.PI / 2,
                cosangle = Math.cos(angle),
                sinangle = Math.sin(angle);
            if ( true ){
                ctx.moveTo( prev.x, prev.y );
                ctx.lineTo( x, y );
                var dangle = Math.abs( angle - prev.angle );
                if (dangle > 0.1 ){
                    points.push( prev );
                    points.push( p );
                }
            }
            prev.x = p.x;
            prev.y = p.y;
            prev.angle = angle;
            prev.cosangle = cosangle;
            prev.sinangle = sinangle;
        }
        if ( travel > threshold  ) {
            ctx.stroke();
        }
        ctx.closePath();
        this.prev = prev;
        if ( travel < threshold  ) return;
        ctx.beginPath();
        ctx.fillStyle = this.color;
        for ( var i = 0; i < points.length; i++ ){
            var p = points[i];
            ctx.arc(p.x, p.y, curnib, 0, Math.PI * 2, true);
        }
        ctx.arc(origin.x, origin.y, curnib, 0, Math.PI * 2, true);
        ctx.arc(end.x, end.y, curnib, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.closePath();
	},
	
	end : function(x,y){},
	
	tick : function(){},
	
	destroy : function(){
		this.prev = null;
		this.context = null;
	}
};
