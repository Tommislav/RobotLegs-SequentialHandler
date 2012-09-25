package se.salomonsson.sequence.stubs 
{
	import flash.events.Event;
	import se.salomonsson.sequence.SequentialTask;
	
	/**
	 * stub task that exposes the internal shared dispatch method
	 * @author Tommy
	 */
	public class DispatchTask extends SequentialTask 
	{
		
		public function dispatchThroughSharedDispatcher(e:Event):void
		{
			dispatch(e);
		}
		
		public function reportComplete():void 
		{
			onCompleted();
		}
		
	}

}