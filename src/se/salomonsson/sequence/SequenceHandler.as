
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

package se.salomonsson.sequence
{
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;

	import org.robotlegs.core.IInjector;

	import se.salomonsson.sequence.SequentialTask;

	/**
	 * Holds and manages all the asynchronous tasks in the sequence.
	 * It can take an optional injector as parameter to the constructor to allow sequential tasks to be
	 * injected with values if used in robotlegs context.
	 * @author Tommislav
	 */
	public class SequenceHandler extends SequenceBase
	{
		private var _injector:IInjector;
		private var _taskSequence:Vector.<SequentialTask>;
		private var _currentIndex:int = 0;
		private var _currentTask:SequentialTask;

		private var _error:SequenceError;
		private var _debugMessagesEnabled:Boolean = false;

		public function get sequenceError():SequenceError { return _error; }
		
		private static var _DEBUG_STAGE:Stage;
		public static function set debugStage(s:Stage):void 
		{ 
			if (s != null) 
				_DEBUG_STAGE = s; 
		}
		
		public function SequenceHandler(injector:IInjector = null)
		{
			_injector = injector;
			_taskSequence = new Vector.<SequentialTask>();
		}

		public function addSequentialTask(task:SequentialTask):SequentialTask
		{
			_taskSequence.push(task);
			return task;
		}

		/**
		 * Starts the sequence by invoking start() on the first sequentialTask
		 * Currently no support for re-running sequences...
		 */
		public function start():void
		{
			// if status != NOT_RUNNING : reset all tasks and run again...?
			
			if (_status != Status.RUNNING)
			{
				setupKeyboardDebug();
				_error = null;
				_status = Status.RUNNING;
				_currentIndex = 0;
				startNextTask();
			}
		}

		/**
		 * Aborts the current sequence - only if we are actually running
		 */
		public function abort():void
		{
			if (_status == Status.RUNNING)
			{
				_status = Status.ABORTED;

				if (_currentTask){
					removeListenersFromTask(_currentTask);
					_currentTask.abort();
				}
				
				onSequenceAborted();
			}
		}

		/**
		 * Kills all tasks and clears all references.
		 * If status is RUNNING we'll abort the running task.
		 */
		public function destroy():void
		{
			_status = Status.DESTROYED;
			
			if (_currentTask != null && _currentTask.status == Status.RUNNING)
			{
				removeListenersFromTask(_currentTask);
				_currentTask.abort();
				_currentTask = null;
			}
			
			_taskSequence = new Vector.<SequentialTask>();
		}

		private function startNextTask():void
		{
			if (_currentTask != null)
			{
				removeListenersFromTask(_currentTask);
			}

			if (_currentIndex < _taskSequence.length)
			{
				_currentTask = getNextTaskAndMovePointer();
				initiateTask(_currentTask);

				if (_currentTask.internalWantsToStart())
				{
					debugStatus("startTask", _currentTask);
					_currentTask.addEventListener(SequentialTask.TASK_COMPLETE, onTaskComplete);
					_currentTask.addEventListener(SequentialTask.TASK_ERROR, onTaskError);
					_currentTask.addEventListener(SequentialTask.TASK_ABORT, onTaskAbort);
					_currentTask.start();
				}
				else
				{
					debugStatus("skipTask", _currentTask);
					
					_currentTask.skip();
					startNextTask();
				}
			}
			else
			{
				// SEQUENCE COMPLETE
				onSequenceCompleted();
			}
		}

		private function removeListenersFromTask(task:SequentialTask):void {
			task.removeEventListener(SequentialTask.TASK_COMPLETE, onTaskComplete);
			task.removeEventListener(SequentialTask.TASK_ERROR, onTaskError);
			task.removeEventListener(SequentialTask.TASK_ABORT, onTaskAbort);
			task = null;
		}

		private function getNextTaskAndMovePointer():SequentialTask
		{
			var task:SequentialTask = _taskSequence[_currentIndex];
			_currentIndex++;
			return task;
		}

		private function initiateTask(currentTask:SequentialTask):void
		{
			if (_injector != null)
			{
				if (!currentTask.initiated)
				{
					currentTask.initiated = true,
					_injector.injectInto(currentTask);
				}
			}
		}


		private function onTaskComplete(e:Event):void
		{
			debugStatus("taskCompleted", _currentTask);
			startNextTask();
		}

		private function onTaskError(e:ErrorEvent):void
		{
			_error = new SequenceError(_currentTask.name, e.text, e.errorID);
			debugStatus("taskError", _currentTask);
			onSequenceError();
		}
		
		private function onTaskAbort(e:Event):void
		{
			debugStatus("taskAbortsSequence", _currentTask);
			abort();
		}
		
		
		private function onSequenceCompleted():void
		{
			_status = Status.COMPLETED;
			
			debugStatus("sequenceComplete");
			teardownKeyboardDebug();
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onSequenceError():void
		{
			_status = Status.ERROR;
			teardownKeyboardDebug();
			
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Error in sequence: " + name + "\n" +_error.errorText, _error.errorId));
		}
		
		private function onSequenceAborted():void
		{
			dispatchEvent(new Event(Status.ABORTED));
			teardownKeyboardDebug();
		}
		
		
		/**
		 * Will print out our status, and the status of each task
		 * @return
		 */
		override public function debug():String
		{
			var dbg:String = super.debug() + "\n";
			for each(var task:SequentialTask in _taskSequence)
				dbg += "   " + task.debug() + "\n";

			return dbg;
		}
		
		public function get debugMessagesEnabled():Boolean { return _debugMessagesEnabled; }
		public function set debugMessagesEnabled(flag:Boolean):void 
		{
			_debugMessagesEnabled = flag;
		}
		
		private function debugStatus(event:String, task:SequentialTask=null):void
		{
			if (_debugMessagesEnabled)
			{
				var msg:String = "[SequenceHandler (" + name + ")] :: " + event + " (" + _currentIndex +"/" + _taskSequence.length + ")";
				if (task != null)
					msg += " :: " + task.name;
				
				trace(msg);
			}
		}
		
		private function setupKeyboardDebug():void
		{
			if (_DEBUG_STAGE)
				_DEBUG_STAGE.addEventListener(KeyboardEvent.KEY_UP, onKeyboardDebug);
		}
		
		private function teardownKeyboardDebug():void
		{
			if (_DEBUG_STAGE)
				_DEBUG_STAGE.removeEventListener(KeyboardEvent.KEY_UP, onKeyboardDebug);
		}
		
		private function onKeyboardDebug(e:KeyboardEvent):void
		{
			var keycodeF1:uint = 112;
			if (e.keyCode == keycodeF1)
				trace(debug());
		}
		
		public function get numTasks():int { return (_taskSequence != null) ? _taskSequence.length : 0; }
	}

}