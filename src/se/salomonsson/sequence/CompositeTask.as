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
 * CompositeTask, wraps a SequenceHandler and gives possibility to add a seqence inside a sequence.
 * 
 * @author Tommy Salomonsson
 */
package se.salomonsson.sequence 
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import org.robotlegs.core.IInjector;

	public class CompositeTask extends SequentialTask 
	{
		[Inject] 
		public var injector:IInjector;
		
		private var _sequenceHandler:SequenceHandler;
		private var _listOfTasks:Vector.<SequentialTask>;
		
		public function CompositeTask(...listOfSequentialTasks) 
		{
			_listOfTasks = new Vector.<SequentialTask>();
			for each(var task:SequentialTask in listOfSequentialTasks)
				addSequentialTask(task);
			
		}
		
		public final function addSequentialTask(task:SequentialTask):SequentialTask
		{
			_listOfTasks.push(task);
			return task;
		}
		
		override protected function exeStart():void 
		{
			setupSequenceHandler();
			_sequenceHandler.start();
		}
		
		private function setupSequenceHandler():void 
		{
			if (_sequenceHandler == null)
			{
				_sequenceHandler = new SequenceHandler(injector);
				_sequenceHandler.addEventListener(Event.COMPLETE, onCompositeCompleted);
				_sequenceHandler.addEventListener(Status.ABORTED, onCompositeAborted);
				_sequenceHandler.addEventListener(ErrorEvent.ERROR, onCompositeError);
				
				for each(var task:SequentialTask in _listOfTasks)
				_sequenceHandler.addSequentialTask(task);
			}
		}
		
		
		private function onCompositeCompleted(e:Event):void
		{
			onCompleted();
		}
		
		private function onCompositeAborted(e:Event):void 
		{
			abortThisTaskAndRestOfSequence();
		}
		
		private function onCompositeError(e:ErrorEvent):void 
		{
			onError(e.text, e.errorID);
		}
		
		override protected function exeCleanUp():void 
		{
			teardownSequenceHandler();
		}
		
		
		private function teardownSequenceHandler():void {
			if (_sequenceHandler != null)
			{
				_sequenceHandler.removeEventListener(SequentialTask.TASK_COMPLETE, onCompleted);
				_sequenceHandler.removeEventListener(Status.ABORTED, onCompositeAborted);
				_sequenceHandler.removeEventListener(ErrorEvent.ERROR, onCompositeError);
				_sequenceHandler.destroy();
				_sequenceHandler = null;
			}
		}
		
		override public function debug():String 
		{
			var myDebug:String = super.debug();
			var sequenceDebug:String = _sequenceHandler == null ? "" : _sequenceHandler.debug();
			
			return "<" + myDebug + " children=(\n  " + sequenceDebug + ")>";
		}
	}

}