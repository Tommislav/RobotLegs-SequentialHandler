/**
 * Created with IntelliJ IDEA.
 * User: Tommy
 * 
 * Utility class that listens for a specific signal. Keeps count of the number of dispatches and in the case that
 * the signal passes arguments these are stored as well.
 */
package utils {
	import org.osflash.signals.Signal;

	public class SignalSpyObject {
		
		public static function spyOnSignal(signal:Signal):SignalSpyObject
		{
			var spy:SignalSpyObject = new SignalSpyObject();
			spy._signal = signal;
			signal.add(spy.signalCallbackMethod);
			return spy;
		}
		
		public static function spyOnceOnSignal(signal:Signal):SignalSpyObject
		{
			var spy:SignalSpyObject = spyOnSignal(signal);
			spy._listenOnce = true;
			return spy;
		}
		
		
		
		
		private var _signal:Signal;
		private var _listenOnce:Boolean;
		private var _invokeCount:int;
		private var _invokeArgs:Vector.<Array>;
		
		
		public function get invokeCount():int 					{ return _invokeCount; }
		public function get allInvokedArgs():Vector.<Array> 	{ return _invokeArgs; }
		public function get lastInvokedArgs():Array 			{ return _invokeArgs[_invokeArgs.length-1];	}
		
		public function SignalSpyObject() {
			reset();
		}
		
		public function signalCallbackMethod(...args):void
		{
			_invokeCount++;
			_invokeArgs.push(args);
			
			if (_listenOnce)
				destroy();
		}
		
		public function reset():void
		{
			_invokeArgs = new Vector.<Array>();
			_invokeCount = 0;
		}
		
		public function destroy():void
		{
			_signal.remove(signalCallbackMethod);
			_signal = null;
		}
	}
}
