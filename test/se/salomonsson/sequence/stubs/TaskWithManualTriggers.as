package se.salomonsson.sequence.stubs 
{
	import se.salomonsson.sequence.SequentialTask;
	
	/**
	 * ...
	 * @author Tommislav
	 */
	public class TaskWithManualTriggers extends SequentialTask 
	{
		public var exeStartInvoked:Boolean;
		public var exeAbortInvoked:Boolean;
		public var exeCleanUpInvoked:Boolean;
		
		public var taskAutoStart:Boolean = true;
		
		public function callComplete():void
		{
			onCompleted();
		}
		
		public function callError(errorMessage:String, errorId:int=0):void
		{
			onError(errorMessage, errorId);
		}
		
		public function callAbortRestOfSequence():void
		{
			abortThisTaskAndRestOfSequence();
		}
		
		override public function wantsToStart():Boolean 
		{
			return taskAutoStart;
		}
		
		
		
		override protected function exeStart():void 
		{
			exeStartInvoked = true;
			super.exeStart();
		}
		
		override protected function exeAbort():void 
		{
			exeAbortInvoked = true;
			super.exeAbort();
		}
		
		override protected function exeCleanUp():void 
		{
			exeCleanUpInvoked = true;
			super.exeCleanUp();
		}
	}

}