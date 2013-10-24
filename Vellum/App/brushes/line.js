function line(){
	this.init();
}


line.prototype = {
	context: null,
	prev : { x:0, y:0 },
	bezierRequired : true,
	count : 0,
	
	init : function(){
		this.context = VLM.state.context;
	},
	
	begin : function(x,y){
		var prev = this.prev;
		prev.x = x;
		prev.y = y;
		this.count = 0;
	},
	
	continue : function(arr){
		
		var scalar = this.count / 8;
		if ( scalar > 1 ) scalar = 1;
		
		var prev = this.prev,
			origin = null,
			state = VLM.state,
			zoomlevel = state.zoomlevel,
			col = state.color,
			rgba = col.rgba,
			alpha = rgba[ 3 ],
			fgg = ''; // spotted alpha
		
		origin = { x: prev.x, y:prev.y, angle:prev.angle};
		
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
			fgg = 'rgba(' + rgba[ 0 ] + ',' + rgba[ 1 ] + ',' + rgba[ 2 ] + ',' + alpha * 0.66 * scalar  + ')';
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
			fgg = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + alpha * 0.5 * scalar  + ')';
		}
		fgcolor = 'rgba(' + rgba[0] + ',' + rgba[1] + ',' + rgba[2] + ',' + alpha * scalar  + ')';
		ctx.beginPath();

		// draw base mark, which is just a thick line 
		for ( var i = 0; i < arr.length; i++ ){
			this.count++;
			ctx.strokeStyle = fgcolor;
			ctx.fillStyle = fgg;
			ctx.lineWidth = state.isIPad ? 1.5 * ( scalar + 0.2 )  : 0.5 * ( scalar + 0.2 );
	
			var lw = ctx.lineWidth,
				p = arr[ i ],
				x = p[ 'x' ],
				y = p[ 'y' ];
			ctx.moveTo( prev.x, prev.y );
			ctx.lineTo( x, y );
			
			for ( var j = 0; j < 24; j++ ) {
				ctx.fillRect( x + Math.random() * lw - Math.random() * lw, y + Math.random() * lw - Math.random() * lw, 0.25, 0.25);
			}
			/*
			var lw = ctx.lineWidth,
				p = arr[ i ],
				x = p[ 'x' ],
				y = p[ 'y' ];
			ctx.moveTo( prev.x, prev.y );
			ctx.lineTo( x, y );
			
			
			/*
			var dx = p.x - prev.x,
				dy = p.y - prev.y,
				numsteps = Math.sqrt( dx*dx + dy*dy ) * 20;
			for ( var j = 0; j < numsteps; j++ ) {
				var localx = prev.x + ( x - prev.x ) * j/numsteps,
					localy = prev.y + ( y - prev.y ) * j/numsteps;
					
				ctx.fillRect( localx + Math.random() * lw - Math.random() * lw, localy + Math.random() * lw - Math.random() * lw, 0.25, 0.25 );
			}
			*/
			prev.x = p.x;
			prev.y = p.y;
		}
		ctx.stroke();
		ctx.closePath();
	},
	
	end : function(x,y){
	},
	
	tick : function(){
		
	},
	
	destroy : function(){
		this.context = null;
		this.prev = null;
	}
};
