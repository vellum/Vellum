function genericBrush(){
	this.init();
}

genericBrush.prototype = {
	context: null,
	queue: [],
	processed: {
		cur : { x:0, y:0 },
		prev : { x:0, y:0 }
	},
	
	init : function(){
		this.context = VLM.state.context;
		console.log('genericBrush.init');
	},
	
	begin : function(x,y){
		var q = this.queue;
		q.splice(0,this.queue.length);
		q.push({x:x,y:y});
		console.log('genericBrush.begin');
	},
	
	continue : function(x,y){
		var q = this.queue;
		q.push({x:x,y:y});
		console.log('genericBrush.continue');
	},
    
    end:function(x,y){
		var q = this.queue;
		q.push({x:x,y:y});
		console.log('genericBrush.end');
    },
	
	tick : function(){
		var q = this.queue;
		if ( q.length == 0 ) return;
		console.log('genericBrush.tick');
	},
	
	destroy : function(){
		this.queue.splice(0,this.queue.length);
		this.queue = null;
		this.context = null;
		console.log('genericBrush.destroy');
	}
};
