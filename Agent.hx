
class Agent {
	
	static var _UID : Int = 0;
	public var _id:Int = _UID++;
	
	public var name:String;
	
	public function new() 				{}
	public function update(dt:Float) 	{}
	public function dispose()			{}
}

class VizAgent extends Agent{
	public var visible(default,set)	:	Bool;
	
	public function new() 				{ super();  }
	function set_visible(v) {
		return visible = v;
	}
}

class AnonAgent extends Agent {
	var cbk : Float -> Void;
	
	public function new(cbk) {
		super();
		this.cbk = cbk;
	}
	
	public override function update(dt:Float) {
		super.update(dt);
		if( null != cbk ) cbk( dt );
	}
	
	public override function dispose(){
		super.dispose();
		cbk = null;
	}
}

class DelayedAgent extends Agent {
	public var dur : Float = 0.0;
	var cbk : Void -> Void;
	var list : AgentList;
	
	public function new(cbk : Void -> Void, delayMs : Int,list:AgentList) {
		super();
		this.cbk = cbk;
		this.list = list; 
		
		this.dur = delayMs;
		list.add( this );
		//trace("added " + id+" ->"+delayMs);
	}
	
	public override function update(dt:Float) {
		super.update(dt);
		if ( dur <= 0 && cbk != null) {
			var	l = list;
			cbk();
			l.remove( this );
			//trace("removed " + id + " ->" + dur);
			cbk = null;
		}
		dur -= dt * 1000.0;
	}
	
	public override function dispose(){
		super.dispose();
		cbk = null;
		list = null;
	}
}
#if h3d
class UiAgent extends Agent {
	var root : h2d.Sprite; //root is disposable
	
	public function resize() {
		
	}
	
	public override function dispose() {
		super.dispose();
		if( root!=null) root.dispose();
		root = null;
	}
}
#end
#if h3d
class SpriteAgent extends Agent {
	var root : h2d.Sprite; //root is disposable
	var visible(get, set):Bool; 
	
	inline function get_visible():Bool	 	return root.visible;
	inline function set_visible(v):Bool 	return root.visible = v;
	
	public inline function toFront() root.toFront();
	public inline function toBack() root.toBack();
	public inline function findByName(n) return root.findByName(n);
	
	public inline function getRoot() return root;
	
	public function new( ?p:h2d.Sprite ) {
		super();
		root = new h2d.Sprite( p );
	}
	
	public override function dispose() { //end of the story 
		super.dispose();
		if( root!=null) root.dispose();
		root = null;
	}
}
#end

class AgentList {
	var repo : hxd.Stack<Agent>;
	
	public inline function new() 
		repo = new hxd.Stack<Agent>();
	
	public
	inline 
	function update(dt) 
		for ( a in repo.backWardIterator() )
			a.update(dt);
			
	public var length(get, null):Int; 	function get_length() return repo.length;
	
	public inline function push(p) 		repo.push(p);
	public inline function add(p) 		repo.push(p);
	
	public 
	inline 
	function dispose() {
		for ( a in repo.backWardIterator() )
			a.dispose();
		repo.hardReset();
	}
	
	public inline function backWardIterator()  {
		return repo.backWardIterator();
	}
	
	public 
	inline
	function remove(a:Agent) {
		return repo.remove(a);
	}
	
	public 
	inline 
	function clear() {
		repo.hardReset();
	}
}

class SpinAgent extends AnonAgent {
	var spinMax = 0;
	var spin = 0;
	public function new( spin,cbk:Float->Void,?dl:AgentList) {
		super(cbk);
		spinMax = spin;
		if(dl!=null) dl.add( this );
	}
	
	override function update(dt)
	{
		if ( spin++> spinMax) {
			super.update(dt);
			spin = 0;
		}
	}
	
}

class TimeSpinAgent extends AnonAgent {
	var spinMax = 0.0;
	var spin = 0.0;
	
	public function new( spin_ms:Float,cbk:Float->Void,?dl:AgentList) {
		super(cbk);
		spinMax = spin_ms;
		if(dl!=null) dl.add( this );
	}
	
	public function trigger(dt) {
		cbk(dt);
	}
	
	override function update(dt:Float) {
		spin += dt * 1000.0;
		if ( spin >= spinMax) {
			super.update(dt);
			spin = 0.0;
		}
	}
	
}
