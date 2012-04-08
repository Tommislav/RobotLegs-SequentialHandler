
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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;

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

		public function get sequenceError():SequenceError { return _error; }


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
		 */
		public function start():void
		{
			// TODO: What should happen if we want to run a sequence several times??

			// if status != NOT_RUNNING : reset all tasks and run again...?

			if (_status != Status.RUNNING)
			{
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

				if (_currentTask)
					_currentTask.abort();
			}
		}

		/**
		 * Kills all tasks and clears all references.
		 * If status is RUNNING we'll abort the running task.
		 */
		public function destroy():void
		{
			_status = Status.DESTROYED;
			
			if (_currentTask != null)
			{
				_currentTask.abort();
				_currentTask.removeEventListener(SequentialTask.TASK_COMPLETE, onTaskComplete);
				_currentTask.removeEventListener(SequentialTask.TASK_ERROR, onTaskError);
				_currentTask = null;
			}
			
			_taskSequence = new Vector.<SequentialTask>();
		}

		private function startNextTask():void
		{
			if (_currentTask != null)
			{
				_currentTask.removeEventListener(SequentialTask.TASK_COMPLETE, onTaskComplete);
				_currentTask.removeEventListener(SequentialTask.TASK_ERROR, onTaskError);
				_currentTask = null;
			}

			if (_currentIndex < _taskSequence.length)
			{
				_currentTask = getNextTaskAndMovePointer();
				initiateTask(_currentTask);

				if (_currentTask.wantsToStart())
				{
					_currentTask.addEventListener(SequentialTask.TASK_COMPLETE, onTaskComplete);
					_currentTask.addEventListener(SequentialTask.TASK_ERROR, onTaskError);
					_currentTask.start();
				}
				else
				{
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
			startNextTask();
		}

		private function onTaskError(e:ErrorEvent):void
		{
			_error = new SequenceError(_currentTask.name, e.text, e.errorID);
			onSequenceError();
		}


		
		private function onSequenceCompleted():void
		{
			_status = Status.COMPLETED;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onSequenceError():void
		{
			_status = Status.ERROR;
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Error in sequence: " + name + "\n" +_error.errorText, _error.errorId))
		}
		
		
		/**
		 * Will print out our status, and the status of each task
		 * @return
		 */
		override public function debug():String
		{
			var dbg:String = super.debug();
			for each(var task:SequentialTask in _taskSequence)
				dbg += "   " + task.debug();

			return dbg;
		}
		
		public function get numTasks():int { return (_taskSequence != null) ? _taskSequence.length : 0; }
	}

}