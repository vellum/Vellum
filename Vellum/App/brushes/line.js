function line(){
	this.init();
}


line.prototype = {
	context: null,
	prev : { x:0, y:0 },
	
	init : function(){
		this.context = VLM.state.context;
	},
	
	begin : function(x,y){
		var prev = this.prev;
		prev.x = x;
		prev.y = y;
	},
	
	continue : function(obj){
		
        var arr = obj.arr,
            travel = obj.travel,
            scalar = travel / 15;

		if ( scalar > 1 ) scalar = 1;
		
		var prev = this.prev,
			origin = { x: prev.x, y:prev.y, angle:prev.angle},
			state = VLM.state,
			zoomlevel = state.zoomlevel,
			col = state.color,
			rgba = col.rgba,
			alpha = rgba[ 3 ],
			fgdecoration = '';
		
		
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
			fgdecoration = 'rgba(' + rgba[ 0 ] + ',' + rgba[ 1 ] + ',' + rgba[ 2 ] + ',' + alpha * 0.66 * scalar  + ')';
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
			fgdecoration = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + alpha * 0.5 * scalar  + ')';
		}
		fgcolor = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + alpha * scalar  + ')';
		ctx.beginPath();
		for ( var i = 0; i < arr.length; i++ ){
			var lw = ctx.lineWidth,
                p = arr[ i ],
                x = p.x,
                y = p.y,
                len = arr.length + 8;

			ctx.strokeStyle = fgcolor;
			ctx.fillStyle = fgdecoration;
			ctx.lineWidth = state.isIPad ? 1.5 * ( scalar + 0.2 )  : 0.5 * ( scalar + 0.2 );
			ctx.moveTo( prev.x, prev.y );
			ctx.lineTo( x, y );

            if ( len > 20 ) len = 20;
			for ( var j = 0; j < len; j++ ) {
				ctx.fillRect( x + Math.random() * lw - Math.random() * lw, y + Math.random() * lw - Math.random() * lw, 0.25, 0.25);
			}
			prev.x = p.x;
			prev.y = p.y;
		}
		ctx.stroke();
		ctx.closePath();
	},
	
	end : function(x,y){},
	
	tick : function(){},
	
	destroy : function(){
		this.context = null;
		this.prev = null;
	}
};
