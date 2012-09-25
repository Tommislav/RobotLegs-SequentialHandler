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
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	import org.robotlegs.base.EventMap;
	import org.robotlegs.core.IEventMap;
	import se.salomonsson.sequence.IEventBus;
	/**
	 * Helper class for dispatching and manage listeners in the robotlegs framework
	 * @author Tommislav
	 */
	public class EventBus implements IEventBus
	{
		private var _sharedEventDispatcher:IEventDispatcher;
		private var _eventMap:IEventMap;
		private var _queuedListeners:Array = [];
		
		
		public function EventBus(sharedEventDispatcher:IEventDispatcher=null) 
		{
			setSharedEventDispatcher(sharedEventDispatcher);
		}

		public function setSharedEventDispatcher(sharedEventDispatcher:IEventDispatcher):void {
			if (sharedEventDispatcher != null) {
				_sharedEventDispatcher = sharedEventDispatcher;
				_eventMap = new EventMap(_sharedEventDispatcher);

				if (_queuedListeners.length > 0)
				{
					for each(var o:Object in _queuedListeners)
						addListener(o.type, o.listener, o.eventClass);
				}
				_queuedListeners = [];
			}
		}
		
		public function addListener(type:String, listener:Function, eventClass:Class = null):void 
		{
			if (_eventMap == null) 
			{
				_queuedListeners.push({type:type, listener:listener, eventClass:eventClass});
				return;
			}
			
			_eventMap.mapListener(_sharedEventDispatcher, type, listener, eventClass);
		}
		
		public function removeListener(type:String, listener:Function, eventClass:Class = null):void 
		{
			if (_eventMap != null)
				_eventMap.unmapListener(_sharedEventDispatcher, type, listener, eventClass);
		}
		
		public function removeAllListeners():void
		{
			if (_eventMap != null)
				_eventMap.unmapListeners();
		}
		
		public function dispatch(e:Event):void
		{
			validateOrThrow();
			_sharedEventDispatcher.dispatchEvent(e);
		}
		
		private function validateOrThrow():void 
		{
			if (_sharedEventDispatcher == null) {
				throw new Error("No shared eventdispatcher was configured, or not ready yet");
			}
		}
		
		public function destroy():void 
		{
			removeAllListeners();
			_queuedListeners = [];
		}
		
		
	}

}