package se.salomonsson.sequence 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.robotlegs.adapters.SwiftSuspendersInjector;

	import se.salomonsson.sequence.stubs.DispatchTask;
	import se.salomonsson.sequence.stubs.EventBusListenerTask;

	import utils.EventCatcher;

	/**
	 * Make sure that the tasks can dispatch events through the shared robotlegs event bus
	 * and that the any events listened to are automatically unmapped when task is complete.
	 * @author Tommy Salomonsson
	 */
	public class TestTaskWithEventBus 
	{
		private var injector:SwiftSuspendersInjector;
		private var sequentialHandler:SequenceHandler;
		private var sharedEventDispatcher:EventDispatcher;
		private const EVENT_TYPE:String = "EVENT_TYPE";
		
		[Before]
		public function setup():void
		{
			sharedEventDispatcher = new EventDispatcher();
			injector = new SwiftSuspendersInjector();
			injector.mapValue(IEventDispatcher, sharedEventDispatcher);
			
			sequentialHandler = new SequenceHandler(injector);
		}
		
		[After]
		public function teardown():void 
		{
			sequentialHandler.destroy();
		}
		
		[Test]
		public function testTaskThatDispatchesEvent():void 
		{
			var dispatchTask:DispatchTask = new DispatchTask();
			sequentialHandler.addSequentialTask(dispatchTask);
			sequentialHandler.start();
			
			var eventCatcher:EventCatcher = EventCatcher.catchOneEvent("type", sharedEventDispatcher);
			dispatchTask.dispatchThroughSharedDispatcher(new Event("type"));
			
			assertThat(eventCatcher.invokeCount, equalTo(1));
		}
		
		[Test]
		public function testAddRemoveListener():void {
			var listener:EventBusListenerTask = new EventBusListenerTask();
			sequentialHandler.addSequentialTask(listener);
			
			listener.listenForEventFromEventBus(EVENT_TYPE);
			assertThat("no events recieved before first dispatch", 
					listener.getNumberOfEventInvokes(), equalTo(0));
			
			sharedEventDispatcher.dispatchEvent(new Event(EVENT_TYPE));
			assertThat("one event recieved after first dispatch", 
					listener.getNumberOfEventInvokes(), equalTo(1));
			
			listener.removeListenerFromEventBus(EVENT_TYPE);
			sharedEventDispatcher.dispatchEvent(new Event(EVENT_TYPE));
			assertThat("no additional events after unregistring for an specific event", 
					listener.getNumberOfEventInvokes(), equalTo(1));
		}
		
		[Test]
		public function testAutoCleanupListenersOnTaskComplete():void {
			var listener:EventBusListenerTask = new EventBusListenerTask();
			sequentialHandler.addSequentialTask(listener);
			listener.listenForEventFromEventBus(EVENT_TYPE);
			sequentialHandler.start();
			listener.reportComplete(); // sequence complete
			
			assertThat(listener.status, equalTo(Status.COMPLETED));
			sharedEventDispatcher.dispatchEvent(new Event(EVENT_TYPE));
			
			assertThat("all events should be automatically unregistred when task is completed", 
					listener.getNumberOfEventInvokes(), equalTo(0));
		}
		
		[Test]
		public function testSetupListenerBeforeDispatcherIsReady():void {
			var listener:EventBusListenerTask = new EventBusListenerTask();
			listener.listenForEventFromEventBus(EVENT_TYPE);
		}
	}

}