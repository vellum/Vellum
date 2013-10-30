function ink(){
	this.init();
}

ink.prototype = {
	context: null,
	target : { x:0, y:0 },
	prev : { x:0, y:0, nib:0 },
	interpolation_multiplier : 0.25,
	color : 'rgba(0,0,0,1)',
    tickcount: 0,
    locked : false,
    stack : [],
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
        var prev = this.prev,
            target = this.target;
        prev.x = x;
		prev.y = y;
		prev.nib = 0;
		target.x = x;
		target.y = y;
        
        this.stack = [];
        this.locked = false;
        var state = VLM.state;
        if ( window.devicePixelRatio == 1 && state.zoomlevel < 1 ){
            this.interpolation_multiplier *= 1/state.zoomlevel;
        }
        
        this.tickcount = 0;
	},
	
	continue : function(o){
        /*
        var arr = o.arr,
            last = arr[arr.length-1],
            x = last.x,
            y = last.y,
            target = this.target;
        
        this.locked = true;
		target.x = x;
		target.y = y;
        this.locked = false;
        console.log( arr.length );
         */
        //this.stack.push( o.arr );
        var arr = [],
            a = o.arr;
        for ( var i = 0; i < a.length; i++ ){
            arr.push( a[i] );
        }
        this.stack.push( arr );
        
        var lastie = arr[ arr.length - 1 ];
        this.target.x = lastie.x;
        this.target.y = lastie.y;
        console.log('reset target / ', this.target.x, this.target.y);

	},
    
	end : function(x,y){
	    var prev = this.prev,
	        target = this.target;
	    target.x = x;
	    target.y = y;
	},  
	
	tick : function(){
        
        //if ( this.stack.length == 0 ) return;
        //console.log( this.stack.length );

        this.tickcount++;
        var arr = this.stack[ 0 ];
        
        //console.log( arr.length );
        
        //if ( arr == null || arr.length < 30 ){
        if ( arr == null ){
            /*
            console.log( 'lazypuck' );
            var interpolation_multiplier = 0.25,
            ctx = this.context,
            state = VLM.state,
            zoomlevel = state.zoomlevel;
            
            if ( !state.isRetina ){
                if (zoomlevel < 1 ){
                    interpolation_multiplier *= 1/zoomlevel;
                }
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
                var curnib = prevnib;
                
                var nib = 20 * dist * 0.005;
                nib = 5 - nib;
                if (nib < 0.5) nib = 0.5;
                
                nib /= zoomlevel * 0.5;
                curnib += (nib - curnib) * 0.125;
                
                // DEBUGGING
                curnib = 1;

                ctx.beginPath();
                ctx.fillStyle = this.color;
                ctx.arc(x, y, curnib / 2, 0, Math.PI * 2, true);
                ctx.fill();
                ctx.closePath();
                
                ctx.beginPath();
                ctx.lineWidth = (zoomlevel < 10) ? curnib : 0.5;
                ctx.strokeStyle = this.color;
                ctx.moveTo(x, y);
                ctx.lineTo(prev.x, prev.y);
                ctx.stroke();
                ctx.closePath();
                
                prev.nib = curnib;
            }
            prev.x = x;
            prev.y = y;
             */
            
        } else {
            console.log('bezier');
            
            for ( var i = 0; i < arr.length; i++ ){
                var curpoint = arr[ i ],
                prev = this.prev,
                prevnib = prev.nib,
                x = curpoint.x,
                y = curpoint.y,
                ctx = this.context;
                
                var curnib = prevnib;
                /*
                var nib = 20 * dist * 0.005;
                nib = 5 - nib;
                if (nib < 0.5) nib = 0.5;
                
                nib /= zoomlevel * 0.5;
                curnib += (nib - curnib) * 0.125;
                 */
                var nib = curpoint.p;
                if ( nib > 10 ) nib = 10;
                //nib /= zoomlevel * 0.5;
                curnib += (nib - curnib) * 0.125;
                
                ctx.beginPath();
                ctx.fillStyle = this.color;
                ctx.arc(x, y, curnib / 2, 0, Math.PI * 2, true);
                ctx.fill();
                ctx.closePath();
                
                ctx.beginPath();
                ctx.lineWidth = (zoomlevel < 10) ? curnib : 0.5;
                ctx.strokeStyle = this.color;
                ctx.moveTo(x, y);
                ctx.lineTo(prev.x, prev.y);
                ctx.stroke();
                ctx.closePath();
                
                this.prev.nib = curnib;
                this.prev.x = x;
                this.prev.y = y;
                this.target.x = x;
                this.target.y = y;
            }

        }
        this.stack.splice( 0, 1 );
        

    },
	
	destroy : function(){
        //this.context.globalCompositeOperation = 'source-over';
		this.target = null;
		this.prev = null;	
		this.context = null;
		this.interpolation_multiplier = null;
	}
};
