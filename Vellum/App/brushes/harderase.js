function harderase(){
	this.init();
}

harderase.prototype = {
    
context: null,
	prev : { x:0, y:0 },
	target : { x:0, y:0 },
	color : '#000000',
    stack : [],
    
	init : function(){
		this.context = VLM.state.context;
		var col = VLM.state.color,
        rgba = col.rgba,
        hue,
        sat,
        lig;
        
        var rgba2 = col.rgba2;
        this.color = 'rgba(' + rgba2[0] + ',' + rgba2[1] + ',' + rgba2[2] + ',' + 1 + ')';
	},
	
	begin : function(x,y){
        this.stack = [];
		var prev = this.prev,
        target = this.target;
		prev.x = x;
		prev.y = y;
        target.x = x;
		target.y = y;
	},
	
	continue : function(obj){
        var arr = [],
            a = obj.arr,
            ivl = 20;
        var travel = obj.travel,
            threshold = 15;
        console.log( travel, threshold);
        
        if ( a.length < ivl ){
            this.stack.push( a[a.length-1] );
        } else {
            ivl *= 30;
            var num = a.length/ivl;
            for ( var i = 0; i < num; i++ ){
                var pct = i/num,
                ind = Math.round( a.length * pct );
                if ( ind > a.length-1 ) ind = a.length-1;
                
                this.stack.push( a[ind] );
            }
        }
	},
	
	end : function(x,y){},
	
	tick : function(){
        var interpolation_multiplier = 0.25,
        ctx = this.context,
        state = VLM.state,
        zoomlevel = state.zoomlevel;
        
        if ( this.stack.length > 0 ){
            var o = this.stack[0];
            this.target.x = o.x;
            this.target.y = o.y;
            this.stack.splice(0,1);
        } else {
            return;
        }
        
        var prev = this.prev,
        target = this.target,
        x = prev.x + (target.x - prev.x) * interpolation_multiplier,
        y = prev.y + (target.y - prev.y) * interpolation_multiplier,
        dx = target.x-x,
        dy = target.y-y,
        dist = Math.sqrt(dx * dx + dy * dy),
        prevnib = prev.nib,
        threshold = 0.001 / (zoomlevel * 1000);
        
        //console.log( dist +', ' + threshold);
        if (dist>=threshold) {
            var curnib = Math.round( 30 / zoomlevel );
            
            ctx.beginPath();
            ctx.strokeStyle = this.color;
            ctx.lineWidth = curnib;
            ctx.moveTo( prev.x, prev.y );
            ctx.lineTo( x, y );
            ctx.stroke();
            ctx.closePath();
            
            curnib *= 0.5;
            ctx.fillStyle = this.color;
            ctx.beginPath();
            ctx.arc(prev.x, prev.y, curnib, 0, Math.PI * 2, true);
            ctx.arc(x, y, curnib, 0, Math.PI * 2, true);
            ctx.fill();
            ctx.closePath();
        }
        prev.x = x;
        prev.y = y;
        
        /*
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
         ctx.closePath();*/
    },
	
	destroy : function(){
		this.prev = null;
		this.context = null;
	}
};
