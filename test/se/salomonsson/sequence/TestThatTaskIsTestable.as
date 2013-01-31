package se.salomonsson.sequence 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import org.flexunit.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperty;
	import se.salomonsson.sequence.stubs.DispatchTask;
	/**
	 * The tasks themselves should be easy to test of course!!!
	 * @author Tommy Salomonsson
	 */
	public class TestThatTaskIsTestable 
	{
		private var _dispatcher:EventDispatcher;
		private var _event:Event;
		private const CUSTOM_EVENT_TYPE:String = "CUSTOM_EVENT_TYPE";
		
		
		[Before]
		public function setup():void {
			_dispatcher = new EventDispatcher();
			_dispatcher.addEventListener(CUSTOM_EVENT_TYPE, recordEvent);
			_event = null;
		}
		
		[After]
		public function teardown():void {
			_dispatcher.removeEventListener(CUSTOM_EVENT_TYPE, recordEvent);
			_event = null;
			_dispatcher = null;
		}
		
		private function recordEvent(e:Event):void {
			_event = e;
		}
		
		
		
		
		[Test]
		public function testTaskDispatchhesThroughSharedEventDispatcher():void {
			
			var task:DispatchTask = new DispatchTask();
			task.setSharedEventDispatcher(_dispatcher);
			task.dispatchThroughSharedDispatcher(new Event(CUSTOM_EVENT_TYPE));
			
			// make sure we caught the event through our fake dispatcher
			assertThat(_event, hasProperty("type", equalTo(CUSTOM_EVENT_TYPE)));
		}
		
		
		
	}

}