package se.salomonsson.sequence 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import org.flexunit.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.text.containsString;

	import utils.EventCatcher;

	/**
	 * ...
	 * @author Tommislav
	 */
	public class TestEventBus 
	{
		private const EVENT_TYPE:String = "event";
		
		private var eventDispatcher:EventDispatcher;
		private var eventBus:EventBus;
		private var catcher:EventCatcher;
		
		[Before]
		public function setup():void
		{
			eventDispatcher = new EventDispatcher();
			eventBus = new EventBus(eventDispatcher);
		}
		
		[After]
		public function teardown():void
		{
			eventBus.destroy();
			if (catcher != null)
				catcher.destroy();
		}
		
		[Test]
		public function testSimpleDispatch():void
		{
			catcher = EventCatcher.catchEvents(EVENT_TYPE, eventDispatcher);
			
			eventBus.dispatch(new Event(EVENT_TYPE));
			assertThat(catcher.invokeCount, equalTo(1));
		}
		
		[Test]
		public function testAddRemoveListeners():void
		{
			eventBus.addListener(EVENT_TYPE, onEvent);
			eventDispatcher.dispatchEvent(new Event(EVENT_TYPE));
			assertThat(_invokeCount, equalTo(1));
			
			eventBus.removeListener(EVENT_TYPE, onEvent);
			eventDispatcher.dispatchEvent(new Event(EVENT_TYPE));
			assertThat(_invokeCount, equalTo(1));
		}
		
		[Test]
		public function testRemoveAllListeners():void 
		{
			eventBus.addListener(EVENT_TYPE, onEvent);
			eventDispatcher.dispatchEvent(new Event(EVENT_TYPE));
			assertThat(_invokeCount, equalTo(1));
			
			eventBus.removeAllListeners();
			eventDispatcher.dispatchEvent(new Event(EVENT_TYPE));
			assertThat(_invokeCount, equalTo(1));
		}
		
		
		
		private var _invokeCount:int;
		private function onEvent(e:Event):void
		{
			_invokeCount++;
		}
		
		
		
		
		
		[Test]
		public function testAddListenerBeforeDispatcherIsSet():void
		{
			eventBus = new EventBus(null);
			eventBus.addListener(EVENT_TYPE, onEvent); // first add eventlistener
			eventBus.setSharedEventDispatcher(eventDispatcher); // THEN set the dispatcher on which to listen
			eventBus.dispatch(new Event(EVENT_TYPE));
			assertThat(_invokeCount, equalTo(1));
		}
		
		
		[Test]
		public function testErrorIfDispatchingWithNullDispatcher():void {
			var nullDispatcher:IEventDispatcher = null;
			eventBus = new EventBus(nullDispatcher);

			var dispatchError:Error;

			try {
				eventBus.dispatch(new Event(EVENT_TYPE));
			} catch (err:Error) {
				dispatchError = err;
			}
			
			assertThat(dispatchError, notNullValue());
			assertThat(dispatchError.message, containsString("No shared eventdispatcher was configured"));
		}
		
		
		[Test]
		public function testNoErrorsWhenRemovingListenersFromNullDispatcher():void
		{
			var nullDispatcher:IEventDispatcher = null;
			eventBus = new EventBus(nullDispatcher);
			
			// should not throw errors, even if dispatcher is null. 
			try {
				eventBus.removeListener(EVENT_TYPE, onEvent);
				eventBus.removeAllListeners();
			} catch (e:Error) {
				Assert.fail("removeListener or removeListeners should not throw errors on nulldispatchers. Cleanup should always be legal");
			}
		}
		
		[Test]
		public function guardForNullDispatchers():void {
			eventBus = new EventBus(null);
			eventBus.addListener(EVENT_TYPE, onEvent);
			eventBus.setSharedEventDispatcher(null);
		}
	}

}