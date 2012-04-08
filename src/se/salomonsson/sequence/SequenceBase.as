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
 * Base class for all sequence classes.
 * 
 * User: Tommy
 */
package se.salomonsson.sequence {
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	public class SequenceBase extends EventDispatcher {

		protected var _status:String = Status.NOT_STARTED;
		public final function get status():String 			{ return _status; }
		public final function get isRunning():Boolean 		{ return _status == Status.RUNNING; }
		public final function get isStarted():Boolean 		{ return _status != Status.NOT_STARTED; }
		public final function get isCompleted():Boolean 	{ return _status == Status.COMPLETED; }

		private var _name:String = "";
		public function setName(name:String):void { _name = name; }
		public function get name():String { return _name == null ? getQualifiedClassName(this) : _name; }
		
		public function debug():String
		{
			return "["+name+"] status: " + _status;
		}
		
	}
}
