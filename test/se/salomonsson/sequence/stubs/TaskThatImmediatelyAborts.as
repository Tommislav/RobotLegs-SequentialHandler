package se.salomonsson.sequence.stubs 
{
	import se.salomonsson.sequence.SequentialTask;
	
	/**
	 * ...
	 * @author Tommy Salomonsson
	 */
	public class TaskThatImmediatelyAborts extends SequentialTask 
	{
		public var exeStartInvoked:Boolean;
		public var exeCleanUpInvoked:Boolean;
		
		override protected function exeStart():void 
		{
			exeStartInvoked = true;
			abortThisTaskAndRestOfSequence();
		}
		
		override protected function exeCleanUp():void 
		{
			exeCleanUpInvoked = true;
		}
		
	}

}