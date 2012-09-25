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

package se.salomonsson.sequence {
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * Base class for all task sequences
	 * @author Tommislav
	 */
	public class SequentialTask extends SequenceBase {
		
		public static const TASK_COMPLETE:String = "TaskSequence::taskComplete";
		public static const TASK_ERROR:String = "TaskSequence::taskError";
		public static const TASK_ABORT:String = "TaskSequence::taskAbort";
		
		
		// optimize RL-injections
		internal var initiated:Boolean = false;

		private var _preconditionEvaluators:Array = [];
		
		private var _eventBus:EventBus = new EventBus();

		/**
		 * Override to add logic if you want your Task to start or not.
		 * Called just before onStart is invoked
		 * @return
		 */
		public function wantsToStart():Boolean { return true; }

		internal function internalWantsToStart():Boolean {
			for each(var f:Function in _preconditionEvaluators) {
				if (!f()) {
					wipePreconditions();
					return false;
				}
			}
			wipePreconditions();
			return wantsToStart();
		}

		private function wipePreconditions():void {
			_preconditionEvaluators = [];
		}

		public final function addPreCondition(f:Function):SequentialTask {
			_preconditionEvaluators.push(f);
			return this;
		}


		protected function exeStart():void {}

		protected function exeAbort():void { }

		protected function exeCleanUp():void {} // called both after complete, abort and error


		protected final function abortThisTaskAndRestOfSequence():void {
			dispatchEvent(new Event(TASK_ABORT));
		}

		protected final function onCompleted():void {
			_status = Status.COMPLETED;
			dispatchEvent(new Event(TASK_COMPLETE));
			internalExeCleanUp();
		}

		protected final function onError(errorMessage:String, errorId:int = 0):void {
			_status = Status.ERROR;
			dispatchEvent(new ErrorEvent(TASK_ERROR, false, false, errorMessage, errorId));
			internalExeCleanUp();
		}


		public final function start():void {
			_status = Status.RUNNING;
			exeStart();
		}

		public final function abort():void {
			_status = Status.ABORTED;
			dispatchEvent(new Event(TASK_ABORT));
			exeAbort();
			internalExeCleanUp();
		}

		public final function skip():void {
			_status = Status.SKIPPED;
		}

		private function internalExeCleanUp():void {
			exeCleanUp();
			cleanupEventBus();
		}


		
		// not very elegant... but would like to be able to avoid [Inject] e:IEventDispatcher... =/
		internal function setSharedEventDispatcher(sharedDispatcher:IEventDispatcher):void {
			_eventBus.setSharedEventDispatcher(sharedDispatcher);
		}
		
		protected function addListener(type:String, listener:Function, eventClass:Class = null):void {
			_eventBus.addListener(type, listener, eventClass);
		}

		protected function removeListener(type:String, listener:Function, eventClass:Class = null):void {
			_eventBus.removeListener(type, listener, eventClass);
		}

		protected function dispatch(e:Event):void {
			_eventBus.dispatch(e);
		}
		
		private function cleanupEventBus():void {
			if (_eventBus) {
				_eventBus.destroy();
				_eventBus = null;
			}
		}
	}

}