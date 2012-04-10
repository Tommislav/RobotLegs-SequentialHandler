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
 * A sequential task that holds several other sequential tasks and reports complete
 * when all sub tasks has reported complete.
 * 
 * @author Tommy Salomonsson, Quickspin AB
 */
package se.salomonsson.sequence {
	import flash.events.ErrorEvent;
	import flash.events.Event;

	import org.robotlegs.core.IInjector;

	public class ParallelTask extends SequentialTask {
		
		[Inject]
		public var injector:IInjector;
		
		private var _allTasks:Vector.<SequentialTask>;
		private var _runningTasks:Vector.<SequentialTask>;
		private var _completedTasks:Vector.<SequentialTask>;
		
		public function ParallelTask(...sequentialTasks) {
			
			_allTasks = new Vector.<SequentialTask>();
			
			for (var i:int = 0; i < sequentialTasks.length; i++)
			{
				if (sequentialTasks[i] is SequentialTask)
					addTask(SequentialTask(sequentialTasks[i]));
			}
		}
		
		public function addTask(task:SequentialTask):void
		{
			_allTasks.push(task);
		}


		override protected function exeStart():void {
			_runningTasks = new Vector.<SequentialTask>();
			_completedTasks = new Vector.<SequentialTask>();
			
			for each(var task:SequentialTask in _allTasks)
				startSubtask(task);
		}


		override protected function exeAbort():void {
			abortSubTasks();
		}

		private function startSubtask(task:SequentialTask):void {
			
			if (injector != null)
				injector.injectInto(task);
			
			if (task.wantsToStart())
			{
				task.addEventListener(SequentialTask.TASK_COMPLETE, onSubTaskCompleted);
				task.addEventListener(SequentialTask.TASK_ERROR, onSubTaskError);
				_runningTasks.push(task);
				task.start();
			}
			else
				{
				task.skip();
				_completedTasks.push(task);
				checkAllTasksCompleted();
			}	
		}
		
		private function abortSubTasks():void
		{
			for each(var task:SequentialTask in _runningTasks)
				task.abort();
		}
		
		private function onSubTaskCompleted(e:Event):void {
			var task:SequentialTask = e.target as SequentialTask;
			onRunningSubTaskCompleted(task);
			
			_completedTasks.push(task);
			checkAllTasksCompleted();
		}
		
		private function checkAllTasksCompleted():void
		{
			if (_completedTasks.length == _allTasks.length)
				onCompleted();
		}
		
		private function onSubTaskError(e:ErrorEvent):void
		{
			onRunningSubTaskCompleted(e.target as SequentialTask);
			abortSubTasks(); // abort all running tasks
			onError(e.text, e.errorID);
		}
		
		private function onRunningSubTaskCompleted(task:SequentialTask):void
		{
			task.removeEventListener(SequentialTask.TASK_COMPLETE, onSubTaskCompleted);
			task.removeEventListener(SequentialTask.TASK_ERROR, onSubTaskError);

			var index:int = _runningTasks.indexOf(task);
			if (index > -1)
				_runningTasks.splice(index,  1);
		}


		override public function debug():String {
			var str:String = super.debug() + "\n";
			for each(var task:SequentialTask in _allTasks)
				str += "    <subtask> " + task.debug() + "\n";
			
			return str;
		}


		override protected function exeCleanUp():void {
			_allTasks = new Vector.<SequentialTask>();
			_runningTasks = new Vector.<SequentialTask>();
			_completedTasks = new Vector.<SequentialTask>();
		}
	}
}