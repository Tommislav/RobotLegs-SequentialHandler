package se.salomonsson.sequence 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import org.flexunit.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperty;
	import se.salomonsson.sequence.stubs.DispatchTask;
	import se.salomonsson.sequence.stubs.TaskThatImmediatelyAborts;
	import se.salomonsson.sequence.stubs.TaskThatReportsComplete;
	import se.salomonsson.sequence.stubs.TaskWithAutoStartOption;
	import se.salomonsson.sequence.stubs.TaskWithManualTriggers;
	/**
	 * The that a task by itself is testable. So that you can actually unittest your tasks.
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
		
		
		[Test]
		public function testTaskCallsCompleteByItself():void {
			var task:TaskThatReportsComplete = new TaskThatReportsComplete();
			task.addEventListener(SequentialTask.TASK_COMPLETE, recordEvent);
			task.start();
			
			assertThat(_event, hasProperty("type", equalTo(SequentialTask.TASK_COMPLETE)));
			
			// clean up
			task.removeEventListener(SequentialTask.TASK_COMPLETE, recordEvent);
		}
		
		[Test]
		public function testTaskCallsAbortByItself():void {
			var task:TaskThatImmediatelyAborts = new TaskThatImmediatelyAborts();
			task.addEventListener(SequentialTask.TASK_ABORT, recordEvent);
			task.start();
			
			assertThat(_event, hasProperty("type", equalTo(SequentialTask.TASK_ABORT)));
			
			// clean up
			task.removeEventListener(SequentialTask.TASK_COMPLETE, recordEvent);
		}
	}
}