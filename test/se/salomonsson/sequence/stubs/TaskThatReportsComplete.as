package se.salomonsson.sequence.stubs 
{
	import se.salomonsson.sequence.SequentialTask;
	
	/**
	 * ...
	 * @author Tommislav
	 */
	public class TaskThatReportsComplete extends SequentialTask 
	{
		public var exeCleanupWasInvoked:Boolean;
		
		override protected function exeStart():void 
		{
			onCompleted();
		}
		
		override protected function exeCleanUp():void 
		{
			exeCleanupWasInvoked = true;
		}
	}

}