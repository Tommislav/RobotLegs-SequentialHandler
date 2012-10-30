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
 * Test for composite task... duh
 * @author Tommy Salomonsson
 */
package se.salomonsson.sequence 
{
	import flash.events.ErrorEvent;
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;
	import org.hamcrest.object.hasProperty;
	import org.hamcrest.text.containsString;
	import org.robotlegs.adapters.SwiftSuspendersInjector;
	import org.robotlegs.core.IInjector;
	import se.salomonsson.sequence.stubs.TaskThatReportsComplete;
	import se.salomonsson.sequence.stubs.TaskWithAutoStartOption;
	import se.salomonsson.sequence.stubs.TaskWithInjection;
	import se.salomonsson.sequence.stubs.TaskWithManualTriggers;
	public class TestCompositeTask 
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
		
		private function swallowErrors(...args):void{}
		
		
		[Test]
		public function testHappyPath():void
		{
			var childTask1:TaskThatReportsComplete = new TaskThatReportsComplete();
			var childTask2:TaskThatReportsComplete = new TaskThatReportsComplete();
			
			var compositeTask:CompositeTask = new CompositeTask(childTask1, childTask2);
			
			_sequenceHandler.addSequentialTask(new TaskThatReportsComplete());
			_sequenceHandler.addSequentialTask(compositeTask);
			_sequenceHandler.addSequentialTask(new TaskThatReportsComplete());
			_sequenceHandler.start();
			
			assertThat("childTask1", 		childTask1.status, 			equalTo(Status.COMPLETED));
			assertThat("childTask2", 		childTask2.status, 			equalTo(Status.COMPLETED));
			assertThat("compositeTask", 	compositeTask.status, 		equalTo(Status.COMPLETED));
			assertThat("sequence", 			_sequenceHandler.status, 	equalTo(Status.COMPLETED));
		}
		
		[Test]
		public function testWithInjector():void 
		{
			var injectedString:String = "injected string";
			var injector:SwiftSuspendersInjector = new SwiftSuspendersInjector();
			injector.mapValue(IInjector, injector); // map itself, this is handled by robotlegs
			injector.mapValue(String,  injectedString);
			var sequenceHandler:SequenceHandler = new SequenceHandler(injector);
			
			
			var childTask1:TaskWithAutoStartOption = new TaskWithAutoStartOption();
			childTask1.autoStart = false;
			var childTask2:TaskWithInjection = new TaskWithInjection();
			
			var compositeTask:CompositeTask = new CompositeTask();
			compositeTask.addSequentialTask(childTask1);
			compositeTask.addSequentialTask(childTask2);
			
			sequenceHandler.addSequentialTask(compositeTask);
			sequenceHandler.start();
			
			trace(compositeTask.debug());
			
			assertThat("childTask1",		childTask1.status, equalTo(Status.SKIPPED));
			assertThat("inject",	 		childTask2.injectedString, equalTo(injectedString));
			assertThat("childTask2",		childTask2.status, equalTo(Status.RUNNING));
			assertThat("compositeTask",		compositeTask.status, equalTo(Status.RUNNING));
			
			childTask2.callComplete();
			
			assertThat("compositeTask",		compositeTask.status, equalTo(Status.COMPLETED));
			assertThat("sequenceHandler",	sequenceHandler.status, equalTo(Status.COMPLETED));
		}
		
		[Test]
		public function testError():void
		{
			var errorMessage:String = "error message";
			var errorId:int = 12345;
			
			var childTask1:TaskWithManualTriggers = new TaskWithManualTriggers();
			var childTask2:TaskThatReportsComplete = new TaskThatReportsComplete();
			
			var composite:CompositeTask = new CompositeTask(childTask1, childTask2);
			_sequenceHandler.addSequentialTask(composite);
			_sequenceHandler.start();
			
			childTask1.callError(errorMessage, errorId);
			assertThat( [childTask1.status, childTask2.status, composite.status, _sequenceHandler.status],
				array(Status.ERROR, Status.NOT_STARTED, Status.ERROR, Status.ERROR)
			);
			
			assertThat(_sequenceHandler.sequenceError, hasProperties({
				errorText: containsString(errorMessage),
				errorId: errorId
			}));
		}
		
		[Test]
		public function testAbortOnCompositeChildTask():void 
		{
			var childTask1:TaskWithManualTriggers = new TaskWithManualTriggers();
			var childTask2:TaskThatReportsComplete = new TaskThatReportsComplete();
			
			var composite:CompositeTask = new CompositeTask(childTask1, childTask2);
			_sequenceHandler.addSequentialTask(composite);
			_sequenceHandler.start();
			
			childTask1.abort();
			
			assertThat([childTask1.status, childTask2.status, composite.status, _sequenceHandler.status], 
				array(Status.ABORTED, Status.NOT_STARTED, Status.ABORTED, Status.ABORTED)
			);
		}
		
		[Test]
		public function testAbortOnCompositeTask():void 
		{
			var childTask1:TaskWithManualTriggers = new TaskWithManualTriggers();
			var childTask2:TaskThatReportsComplete = new TaskThatReportsComplete();
			
			var composite:CompositeTask = new CompositeTask(childTask1, childTask2);
			_sequenceHandler.addSequentialTask(composite);
			_sequenceHandler.start();
			
			composite.abort();
			
			assertThat([childTask1.status, childTask2.status, composite.status, _sequenceHandler.status], 
				array(Status.ABORTED, Status.NOT_STARTED, Status.ABORTED, Status.ABORTED)
			);
			
			assertThat(childTask1, hasProperty("exeAbortInvoked", equalTo(true)));
		}
		
		[Test]
		public function testAbortCompositeChildOnly():void {
			var childTask1:TaskWithManualTriggers = new TaskWithManualTriggers();
			var childTask2:TaskThatReportsComplete = new TaskThatReportsComplete();
			var composite:CompositeTask = new CompositeTask(childTask1, childTask2);
			_sequenceHandler.addSequentialTask(composite);
			_sequenceHandler.start();
			
			composite.abortChildTasksAndProceed();
			
			assertThat([childTask1.status, childTask2.status, composite.status, _sequenceHandler.status],
				array(Status.ABORTED, Status.NOT_STARTED, Status.COMPLETED, Status.COMPLETED)
			);
		}
	}
}