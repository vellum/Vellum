function ink(){
	this.init();
}

ink.prototype = {
	context: null,
	prev : { x:0, y:0, nib:0, angle:0 },
	color : 'rgba(0,0,0,1)',
    todo:[],
    index:0,
    
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
		prev.nib = 0;
        prev.angle = 0;
        
	},
	
	continue : function(obj){
        var arr = obj.arr,
            prev = this.prev,
            state = VLM.state,
            ctx = this.context;
        
        console.log(arr.length);
        
        ctx.beginPath();
        ctx.strokeStyle = this.color;
        ctx.fillStyle = this.color;
        var nib = prev.nib;
        for ( var i = 0; i < arr.length; i++ ){
            var p = arr[ i ],
                x = p.x,
                y = p.y,
                dx = x - prev.x,
                dy = y - prev.y;
            
            var angle = Math.atan2(dy, dx) - Math.PI / 2,
                cosangle = Math.cos(angle),
                sinangle = Math.sin(angle),
                pangle = prev.angle,
                cospangle = Math.cos(pangle),
                sinpangle = Math.sin(pangle);

            var tnib = p.p;
           if ( tnib > 5 ) tnib = 5;
            
            nib += (tnib - nib) * 0.25;
            //nib = tnib;
            
            /*
            ctx.lineWidth = p.p;
            ctx.moveTo(prev.x,prev.y);
            ctx.lineTo(x, y);
             */
            
            
            //ctx.fillRect( x, y, 0.5, 0.5 );

            var a0 = { x: prev.x + cospangle * -prev.nib/2, y: prev.y + sinpangle * -prev.nib/2 },
            a1 = { x: prev.x + cospangle * prev.nib/2, y: prev.y + sinpangle * prev.nib/2 },
            b0 = { x: x + cosangle * -nib/2, y: y + sinangle * -nib/2 },
            b1 = { x: x + cosangle * nib/2, y: y + sinangle * nib/2 };
            ctx.moveTo( a0.x, a0.y );
            ctx.lineTo( b0.x, b0.y );
            ctx.lineTo( b1.x, b1.y );
            ctx.lineTo( a1.x, a1.y );

            
            prev.x = p.x;
            prev.y = p.y;
            prev.angle = angle;
            prev.nib = nib;
        }
        ctx.fill();
        ctx.closePath();
        this.prev = prev;

	},
    
    
	end : function(x,y){
    },
	
	tick : function(){
    },
	
	tick_old : function(){
        this.tickcount++;
        
        
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
		
    },
	
	destroy : function(){
        //this.context.globalCompositeOperation = 'source-over';
		this.target = null;
		this.prev = null;	
		this.context = null;
		this.interpolation_multiplier = null;
	}
};
