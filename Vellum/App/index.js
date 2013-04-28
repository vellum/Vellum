var MODE_GRAPHITE = 0;
var MODE_DOTS = 1;
var MODE_INK = 2;

var w = window.innerWidth
  , h = window.innerHeight
  , canvas = document.getElementById('canvas')
  , ctx = canvas.getContext('2d')
  , prevmouse = { x: 0, y: 0 }
  , targetmouse = { x: 0, y: 0 }
  , mousedown = false
  , curnib = 1
  , angle = 0
  , zoomlevel = 1
  , drawmode = MODE_DOTS
  ;

var animate = function() {
    //console.log('animate');
    if ( mousedown ){
        switch (drawmode){
            case MODE_GRAPHITE:
            case MODE_DOTS:
                drawgraphite();
                break;
            case MODE_INK:
                drawink();
                break;
                
        }
    }
};

var drawink = function(){
    var x = prevmouse.x + (targetmouse.x-prevmouse.x)*0.25
    , y = prevmouse.y + (targetmouse.y-prevmouse.y)*0.25
    , dx = targetmouse.x - x
    , dy = targetmouse.y - y
    , dist = Math.sqrt( dx*dx + dy*dy)
    , prevnib = curnib
    , pangle = angle
    , threshold = (zoomlevel>10) ? 0.000001 : 1
    ;
    if ( dist >= threshold ){
        
        var nib = 20 * dist * 0.005;
        nib = 5 - nib;
        if ( nib < 0.25 )
            nib = 0.25;
        
        nib /= zoomlevel*0.5;
        curnib += ( nib - curnib ) * 0.125;
        ctx.beginPath();
        ctx.fillStyle = '#000000';
        ctx.arc(x, y, curnib/2, 0, Math.PI*2, true);
        ctx.fill();
        ctx.closePath();
        
        ctx.beginPath();
        ctx.lineWidth= ( zoomlevel < 10 ) ? curnib : 0.5;
        ctx.strokeStyle='#000000';
        ctx.moveTo(x, y);
        ctx.lineTo(prevmouse.x, prevmouse.y);
        ctx.stroke();
        ctx.closePath();
    }
    prevmouse.x = x;
    prevmouse.y = y;

}

var drawgraphite = function(){
    var x = prevmouse.x + (targetmouse.x-prevmouse.x)*0.5
    , y = prevmouse.y + (targetmouse.y-prevmouse.y)*0.5
    , dx = targetmouse.x - x
    , dy = targetmouse.y - y
    , dist = Math.sqrt( dx*dx + dy*dy)
    , prevnib = curnib
    , pangle = angle
    , threshold = (zoomlevel>10) ? 0.00001 : 1
    ;
    
    if ( dist >= threshold ){
        
        angle = Math.atan2( dy, dx ) - Math.PI/2;
        
        curnib += dist*2.5;
        curnib *= 0.25;
        
        var multiplier = 1.0
        , count = 0
        , cosangle = Math.cos( angle )
        , sinangle = Math.sin( angle )
        , cospangle = Math.cos( pangle )
        , sinpangle = Math.sin( pangle )
        , vertexCount = 0
        , currange = curnib * multiplier
        , prevrange = prevnib * multiplier
        ;
        if ( zoomlevel < 7.5 ){
            ctx.beginPath();
            
            if ( zoomlevel < 1 ) {
                ctx.lineWidth = 0.5; // solid lines MOIRE
            } else {
                if ( drawmode == MODE_DOTS ){
                    ctx.lineWidth = 0.1; // dots (these look great)
                } else {
                    ctx.lineWidth = 0.45; // these look ok
                }
            }
            ctx.strokeStyle='#000000';
            for (var i = -currange; i <= currange; i += 1.5){
                var pct = i/currange
                , localx = x + cosangle * pct * currange
                , localy = y + sinangle * pct * currange
                , localpx = prevmouse.x + cospangle * pct * prevrange
                , localpy = prevmouse.y + sinpangle * pct * prevrange
                ;
                ctx.moveTo(localpx, localpy);
                ctx.lineTo(localx, localy);
                
            }
            ctx.stroke();
            ctx.closePath();
        } else {
            
            ctx.beginPath();
            ctx.lineWidth= 0.35;
            ctx.strokeStyle='#000000';
            ctx.moveTo(x, y);
            ctx.lineTo(prevmouse.x, prevmouse.y);
            ctx.stroke();
            ctx.closePath();
        }
        
        
    }
    prevmouse.x = x;
    prevmouse.y = y;
}

var setup = function() {
    canvas.width = w;
    canvas.height = h;
    ctx.fillStyle = '#f2f2e8';
    ctx.fillRect( 0, 0, w, h );
    
    ctx.globalAlpha = 1;
    ctx.lineWidth = 1;
    setInterval( animate, 16 );
};

var beginStroke = function(x,y) {
    console.log( 'beginStroke: ' + x + ', ' + y );
    mousedown = true;
    targetmouse.x = prevmouse.x = x;
    targetmouse.y = prevmouse.y = y;
    curnib = 1;
    angle = 0;
};

var continueStroke = function(x,y) {
    console.log( 'continueStroke: ' + x + ', ' + y );
    mousedown = true;
    targetmouse.x = x;
    targetmouse.y = y;
};

var endStroke = function(x,y) {
    mousedown = false;
    console.log( 'endStroke: ' + x + ', ' + y );
};

var setZoom = function( val ){
    zoomlevel = Number(val);
    console.log('sezoom:'+zoomlevel);

}
setup();