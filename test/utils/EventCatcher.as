/**
 * Created with IntelliJ IDEA.
 * User: Tommy
 * Date: 2012-02-20
 * Time: 11:34
 * Utility to create a listener and store all events that are being dispatched.
 */
package utils {
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	public class EventCatcher {
		
		public static function catchEvents(type:String, dispatcher:IEventDispatcher):EventCatcher
		{
			var catcher:EventCatcher = new EventCatcher();
			catcher.registerEvent(type, dispatcher, false);
			return catcher;
		}
		
		public static function catchOneEvent(type:String, dispatcher:IEventDispatcher):EventCatcher
		{
			var catcher:EventCatcher = new EventCatcher();
			catcher.registerEvent(type, dispatcher, true);
			return catcher;
		}
		
		
		
		
		private var _type:String;
		private var _dispatcher:IEventDispatcher;
		private var _listenOnce:Boolean;
		private var _invokeCount:int;
		private var _events:Vector.<Event>;
		
		
		public function get invokeCount():int 				{ return _invokeCount; }
		public function get allEvents():Vector.<Event> 		{ return _events; }
		public function get lastDispatchedEvent():Event 	{ return _events[_events.length-1];	}
		
		public function EventCatcher() {
			reset();
		}
		
		public function registerEvent(type:String, dispatcher:IEventDispatcher, listenOnce:Boolean):void
		{
			_listenOnce 	= listenOnce;
			_type 			= type;
			_dispatcher 	= dispatcher;
			
			_dispatcher.addEventListener(_type, onEvent);
		}
		
		private function onEvent(e:Event):void
		{
			_invokeCount++;
			_events.push(e);
			
			if (_listenOnce)
				destroy();
		}
		
		public function reset():void
		{
			_events = new Vector.<Event>();
			_invokeCount = 0;
		}
		
		public function destroy():void
		{
			_dispatcher.removeEventListener(_type, onEvent);
			_dispatcher = null;
			_events = null;
		}
	}
}
