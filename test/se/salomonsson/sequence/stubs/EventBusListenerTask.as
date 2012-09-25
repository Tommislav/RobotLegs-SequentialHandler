/**
 *
 * @author Tommislav
 */
package se.salomonsson.sequence.stubs {
	import flash.events.Event;

	import se.salomonsson.sequence.SequentialTask;

	public class EventBusListenerTask extends SequentialTask {

		private var _invokeCount:int;

		public function listenForEventFromEventBus(eventType:String):void {
			addListener(eventType, internalListener);
		}


		public function removeListenerFromEventBus(eventType:String):void {
			removeListener(eventType, internalListener);
		}


		private function internalListener(e:Event):void {
			_invokeCount++;
		}

		public function getNumberOfEventInvokes():int {
			return _invokeCount;
		}

		public function reportComplete():void {
			onCompleted();
		}

	}
}
