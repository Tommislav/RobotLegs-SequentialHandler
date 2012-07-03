package se.salomonsson.sequence.stubs 
{
	import se.salomonsson.sequence.SequentialTask;
	/**
	 * ...
	 * @author ...
	 */
	public class TaskWithAutoStartOption extends SequentialTask
	{
		public var autoStart:Boolean = true;
		
		
		override public function wantsToStart():Boolean 
		{
			return autoStart;
		}
		
		override protected function exeStart():void 
		{
			onCompleted();
		}
	}

}