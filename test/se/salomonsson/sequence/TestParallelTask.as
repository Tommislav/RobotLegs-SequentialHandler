/*
 * Copyright (c) 2012 Tommislav
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
 * documentation files (the "Software"), to deal in the Software without restriction, including without 
 * limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
 * Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions 
 * of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE.
 */

/*
 * Copyright (c) 2012 Tommislav
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
 * documentation files (the "Software"), to deal in the Software without restriction, including without 
 * limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
 * Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions 
 * of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE.
 */

/**
 *
 * @author Tommy Salomonsson, Quickspin AB
 */
package se.salomonsson.sequence {
	import flash.events.ErrorEvent;

	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;
	import org.robotlegs.adapters.SwiftSuspendersInjector;
	import org.robotlegs.core.IInjector;

	import se.salomonsson.sequence.ParallelTask;
	import se.salomonsson.sequence.stubs.TaskWithAutoStartOption;
	import se.salomonsson.sequence.stubs.TaskWithInjection;
	import se.salomonsson.sequence.stubs.TaskWithManualTriggers;

	public class TestParallelTask {
		
		
		[Test]
		public function testParallelTask():void
		{
			var sequenceHandler:SequenceHandler = new SequenceHandler();
			var task1:TaskWithManualTriggers = new TaskWithManualTriggers();
			var task2:TaskWithManualTriggers = new TaskWithManualTriggers();
			var parallelTask:ParallelTask = new ParallelTask(task1, task2);
			sequenceHandler.addSequentialTask(parallelTask);
			
			sequenceHandler.start();
			assertThat("sequenceHandler", sequenceHandler.status, equalTo(Status.RUNNING));
			assertThat("parallelTask", parallelTask.status, equalTo(Status.RUNNING));
			assertThat("task1", task1.status, equalTo(Status.RUNNING));
			assertThat("task2", task2.status, equalTo(Status.RUNNING));
			
			task1.callComplete();
			assertThat("sequenceHandler", sequenceHandler.status, equalTo(Status.RUNNING));
			assertThat("parallelTask", parallelTask.status, equalTo(Status.RUNNING));
			assertThat("task1", task1.status, equalTo(Status.COMPLETED));
			assertThat("task2", task2.status, equalTo(Status.RUNNING));
			
			task2.callComplete();
			assertThat("sequenceHandler", sequenceHandler.status, equalTo(Status.COMPLETED));
			assertThat("parallelTask", parallelTask.status, equalTo(Status.COMPLETED));
			assertThat("task1", task1.status, equalTo(Status.COMPLETED));
			assertThat("task2", task2.status, equalTo(Status.COMPLETED));
		}
		
		[Test]
		public function testParallelTaskWithInjection():void
		{
			var injectedString:String = "injected string";
			var injector:SwiftSuspendersInjector = new SwiftSuspendersInjector();
			injector.mapValue(IInjector, injector); // map itself, this is handled by robotlegs
			injector.mapValue(String,  injectedString);
			
			var sequenceHandler:SequenceHandler = new SequenceHandler(injector);
			var task1:TaskWithInjection = new TaskWithInjection();
			var task2:TaskWithManualTriggers = new TaskWithManualTriggers();
			var parallelTask:ParallelTask = new ParallelTask(task1, task2);
			sequenceHandler.addSequentialTask(parallelTask);
			sequenceHandler.start();
			
			assertThat(task1.injectedString, equalTo(injectedString));
		}
		
		[Test]
		public function testParallelTaskWantsToStart():void
		{
			var sequenceHandler:SequenceHandler = new SequenceHandler();
			var task1:TaskWithAutoStartOption = new TaskWithAutoStartOption();
			var task2:TaskWithAutoStartOption = new TaskWithAutoStartOption();
			task1.autoStart = false;
			var parallelTask:ParallelTask = new ParallelTask(task1, task2);
			sequenceHandler.addSequentialTask(parallelTask);
			sequenceHandler.start();
			
			assertThat([sequenceHandler.status, parallelTask.status, task1.status, task2.status], 
				array(Status.COMPLETED, Status.COMPLETED, Status.SKIPPED, Status.COMPLETED)
			);
		}
		
		[Test]
		public function testParallelTasksWithError():void
		{
			var sequenceHandler:SequenceHandler = new SequenceHandler();
			sequenceHandler.addEventListener(ErrorEvent.ERROR, function(e:ErrorEvent):void{}, false, 0, true); // swallow error events
			var task1:TaskWithManualTriggers = new TaskWithManualTriggers();
			var task2:TaskWithManualTriggers = new TaskWithManualTriggers();
			var task3:TaskWithManualTriggers = new TaskWithManualTriggers();
			
			var parallelTask:ParallelTask = new ParallelTask(task1, task2, task3);
			sequenceHandler.addSequentialTask(parallelTask);
			
			sequenceHandler.start();
			
			task1.callComplete();
			task2.callError("error", 1);
			
			assertThat([sequenceHandler.status, parallelTask.status, task1.status, task2.status, task3.status],
					array(Status.ERROR, Status.ERROR, Status.COMPLETED, Status.ERROR, Status.ABORTED));
			
			assertThat(sequenceHandler.sequenceError, hasProperties({
				errorText: "error",
				errorId: 1
			}));
		}
	}
}
