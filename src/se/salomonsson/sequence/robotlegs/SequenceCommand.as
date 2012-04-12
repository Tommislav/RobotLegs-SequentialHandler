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
 * Command that handles asynchronous sequences. Will automatically call detain and release
 * on the commandmap. Will automatically abort sequence on ContextEvent.SHUTDOWN.
 * @author Tommislav
 */
package se.salomonsson.sequence.robotlegs
{
	import flash.events.ErrorEvent;
	import flash.events.Event;

	import org.robotlegs.base.ContextEvent;

	import org.robotlegs.mvcs.Command;

	import se.salomonsson.sequence.SequenceError;

	import se.salomonsson.sequence.SequenceHandler;
	import se.salomonsson.sequence.SequentialTask;

	public class SequenceCommand extends Command
	{
		public static var USE_DEBUG:Boolean = false;
		
		[PostConstruct]
		public function createSequenceHandler():void 
		{ 
			_sequenceHandler = new SequenceHandler(injector);
			_sequenceHandler.setName(String(this));
			if (USE_DEBUG)
				_sequenceHandler.debugMessagesEnabled = true;
			
		}
		private var _sequenceHandler:SequenceHandler;


		/**
		 * Call from subclass to add a task to sequence
		 */
		protected function addSequentialTask(task:SequentialTask):void
		{
			_sequenceHandler.addSequentialTask(task);
		}

		/**
		 * Call from subclass to start sequence, after all tasks are added
		 */
		protected function start():void
		{
			commandMap.detain(this);
			_sequenceHandler.addEventListener(Event.COMPLETE, onSequenceCompleted);
			_sequenceHandler.addEventListener(ErrorEvent.ERROR, onSequenceError);
			eventDispatcher.addEventListener(ContextEvent.SHUTDOWN, onContextShutDown);
			_sequenceHandler.start();
		}


		/**
		 * Override to handle completed sequence
		 */
		protected function onCompleted():void {}

		/**
		 * Override to handle errors
		 */
		protected function onError(e:SequenceError):void {}
		
		
		
		/**
		 * Call from subclass to abort a running sequence
		 */
		protected function abort():void
		{
			clearListeners();
			_sequenceHandler.abort();
		}
		
		private function onSequenceCompleted(e:Event):void
		{
			clearListeners();
			onCompleted();
		}
		
		private function onSequenceError(e:ErrorEvent):void
		{
			clearListeners();
			onError(_sequenceHandler.sequenceError);
		}
		
		private function clearListeners():void
		{
			commandMap.release(this);
			_sequenceHandler.removeEventListener(Event.COMPLETE, onSequenceCompleted);
			_sequenceHandler.removeEventListener(ErrorEvent.ERROR, onSequenceError);
			eventDispatcher.removeEventListener(ContextEvent.SHUTDOWN, onContextShutDown);
		}
		
		private function onContextShutDown(e:Event):void
		{
			abort();
		}
	}
}
