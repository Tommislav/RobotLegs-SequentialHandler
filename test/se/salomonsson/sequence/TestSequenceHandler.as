package se.salomonsson.sequence
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.system.ApplicationDomain;

	import org.flexunit.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;
	import org.hamcrest.object.nullValue;
	import org.robotlegs.adapters.SwiftSuspendersInjector;
	import org.robotlegs.core.IInjector;

	import se.salomonsson.sequence.stubs.TaskThatReportsComplete;
	import se.salomonsson.sequence.stubs.TaskWithAutoStartOption;
	import se.salomonsson.sequence.stubs.TaskWithInjection;
	import se.salomonsson.sequence.stubs.TaskWithManualTriggers;
	import se.salomonsson.sequence.stubs.TaskWithManualTriggers;

	import utils.EventCatcher;

	/**
	 * ...
	 * @author Tommislav
	 */
	public class TestSequenceHandler
	{
		private var _sequenceHandler:SequenceHandler;

		[Before]
		public function setup():void
		{
			_sequenceHandler = new SequenceHandler();
			_sequenceHandler.addEventListener(ErrorEvent.ERROR, swallowErrors);
		}

		[After]
		public function teardown():void
		{
			_sequenceHandler.addEventListener(ErrorEvent.ERROR, swallowErrors);
			_sequenceHandler.destroy();
		}


		private function swallowErrors(e:ErrorEvent):void { /* avoid errors in test */ }

		private function addTask(task:SequentialTask):*
		{
			return _sequenceHandler.addSequentialTask(task);
		}


		[Test]
		public function testCompleteStatus():void
		{
			var task1:TaskThatReportsComplete = addTask(new TaskThatReportsComplete());
			var task2:TaskThatReportsComplete = addTask(new TaskThatReportsComplete());
			_sequenceHandler.start();

			assertThat("sequence", _sequenceHandler.isCompleted, equalTo(true));
			assertThat("task1", task1.isCompleted, equalTo(true));
			assertThat("task2", task2.isCompleted, equalTo(true));
		}

		[Test]
		public function testCompleteInSequence():void
		{
			var task1:TaskWithManualTriggers = addTask(new TaskWithManualTriggers());
			var task2:TaskWithManualTriggers = addTask(new TaskWithManualTriggers());

			assertThat("before sequence has started",
					[_sequenceHandler.status, task1.status, task2.status],
					array(Status.NOT_STARTED, Status.NOT_STARTED, Status.NOT_STARTED));

			_sequenceHandler.start();
			assertThat("sequence has started, first task hasn't reported complete",
					[_sequenceHandler.status, task1.status, task2.status],
					array(Status.RUNNING, Status.RUNNING, Status.NOT_STARTED));


			task1.callComplete();
			assertThat("task 1 has reported complete, task 2 is running",
					[_sequenceHandler.status, task1.status, task2.status],
					array(Status.RUNNING, Status.COMPLETED, Status.RUNNING));

			task2.callComplete();
			assertThat("task 2 completed, sequence completed",
					[_sequenceHandler.status, task1.status, task2.status],
					array(Status.COMPLETED, Status.COMPLETED, Status.COMPLETED));
		}

		[Test]
		public function testAbortSequence():void
		{
			var task1:TaskWithManualTriggers = addTask(new TaskWithManualTriggers());
			var task2:TaskWithManualTriggers = addTask(new TaskWithManualTriggers());

			_sequenceHandler.start();
			task1.callComplete();
			_sequenceHandler.abort();

			assertThat("second task running when sequence aborted",
					[_sequenceHandler.status, task1.status, task2.status],
					array(Status.ABORTED, Status.COMPLETED, Status.ABORTED));
		}

		[Test]
		public function testErrorSequence():void
		{
			var testErrorTask:String = "errorTask";
			var testErrorMsg:String = "an error has occured";
			var testErrorId:int = 1234567;

			var task1:TaskWithManualTriggers = addTask(new TaskWithManualTriggers());
			var task2:TaskWithManualTriggers = addTask(new TaskWithManualTriggers());

			task1.setName(testErrorTask);
			_sequenceHandler.start();
			task1.callError(testErrorMsg, testErrorId);

			assertThat("Error invoked in first task",
					[_sequenceHandler.status, task1.status, task2.status],
					array(Status.ERROR, Status.ERROR, Status.NOT_STARTED));

			_sequenceHandler.sequenceError.errorId
			assertThat(_sequenceHandler.sequenceError, hasProperties({
				errorTaskName:testErrorTask,
				errorText    :testErrorMsg,
				errorId      :testErrorId
			}));
		}

		[Test]
		public function testWantsToStart():void
		{
			var task1:TaskWithAutoStartOption = addTask(new TaskWithAutoStartOption());
			var task2:TaskWithAutoStartOption = addTask(new TaskWithAutoStartOption());

			task1.autoStart = false;
			_sequenceHandler.start();

			assertThat("First task reports wantsToStart=false",
					[_sequenceHandler.status, task1.status, task2.status],
					array(Status.COMPLETED, Status.SKIPPED, Status.COMPLETED));
		}

		[Test]
		public function testTaskHooksInvokedOnAbort():void
		{
			var task1:TaskWithManualTriggers = addTask(new TaskWithManualTriggers());
			var task2:TaskWithManualTriggers = addTask(new TaskWithManualTriggers());

			_sequenceHandler.start();
			task1.callComplete();
			
			assertThat(task1, hasProperties({
				exeStartInvoked  :true,
				exeAbortInvoked  :false,
				exeCleanUpInvoked:true
			}));

			_sequenceHandler.abort();
			
			assertThat(task2, hasProperties({
				exeStartInvoked  :true,
				exeAbortInvoked  :true,
				exeCleanUpInvoked:true
			}));
		}

		[Test]
		public function testTaskHooksInvokedOnError():void
		{
			var task1:TaskWithManualTriggers = addTask(new TaskWithManualTriggers());
			var task2:TaskWithManualTriggers = addTask(new TaskWithManualTriggers());

			_sequenceHandler.start();
			task1.callError("error");

			assertThat(task1, hasProperties({
				exeStartInvoked  :true,
				exeAbortInvoked  :false,
				exeCleanUpInvoked:true
			}));

			assertThat(task2, hasProperties({
				exeStartInvoked  :false,
				exeAbortInvoked  :false,
				exeCleanUpInvoked:false
			}));
		}

		// Test injection
		[Test]
		public function testInjections():void
		{
			var stringToInject:String = "test string";
			var injector:IInjector = new SwiftSuspendersInjector();
			injector.applicationDomain = ApplicationDomain.currentDomain;
			injector.mapValue(String, stringToInject);

			_sequenceHandler = new SequenceHandler(injector); // replace instance


			var task1:TaskWithInjection = addTask(new TaskWithInjection());
			var task2:TaskWithInjection = addTask(new TaskWithInjection());


			assertThat("task 1 before seq.start", task1.injectedString, nullValue());
			assertThat("task 2 before seq.start", task2.injectedString, nullValue());

			_sequenceHandler.start();

			assertThat("task 1, task 1 has started", task1.injectedString, equalTo(stringToInject));
			assertThat("task 2, task 1 has started", task2.injectedString, nullValue());

			task1.callComplete();

			assertThat("task 1, task 1 completed", task1.injectedString, equalTo(stringToInject));
			assertThat("task 2, task 1 completed", task2.injectedString, equalTo(stringToInject));
		}


		// Test callbacks
		[Test]
		public function testCallbackComplete():void
		{
			addTask(new TaskThatReportsComplete());
			addTask(new TaskThatReportsComplete());

			var eventCatcher:EventCatcher = EventCatcher.catchOneEvent(Event.COMPLETE, _sequenceHandler);
			_sequenceHandler.start();
			assertThat(eventCatcher.invokeCount, equalTo(1));
		}

		[Test]
		public function testCallbackError():void
		{
			var task1:TaskWithManualTriggers = new TaskWithManualTriggers();
			var task2:TaskWithManualTriggers = new TaskWithManualTriggers();
			addTask(task1);
			addTask(task2);

			var eventCatcher:EventCatcher = EventCatcher.catchOneEvent(ErrorEvent.ERROR, _sequenceHandler);
			_sequenceHandler.start();
			task1.callError("error from test", 12345);
			assertThat(eventCatcher.invokeCount, equalTo(1));
		}

		[Test]
		public function testDestroy():void
		{
			addTask(new TaskWithManualTriggers());
			_sequenceHandler.destroy();
			
			assertThat(_sequenceHandler, hasProperties({
				status: Status.DESTROYED,
				numTasks: 0
			}));
		}

		[Test]
		public function testAbortTaskOnDestroy():void
		{
			var task1:TaskWithManualTriggers = addTask(new TaskWithManualTriggers());
			_sequenceHandler.start();

			assertThat(task1.status, equalTo(Status.RUNNING));
			
			_sequenceHandler.destroy();
			
			assertThat(task1.status, equalTo(Status.ABORTED));
		}
		
		[Test]
		public function testAbortInsideTask():void
		{
			var task1:TaskWithManualTriggers = new TaskWithManualTriggers();
			var task2:TaskWithManualTriggers = new TaskWithManualTriggers();
			addTask(task1);
			addTask(task2);
			_sequenceHandler.start();
			task1.callAbortRestOfSequence();
			
			var statusArray:Array = [_sequenceHandler.status, task1.status, task2.status];
			
			assertThat(statusArray, array(Status.ABORTED, Status.ABORTED, Status.NOT_STARTED));
		}
	}

}