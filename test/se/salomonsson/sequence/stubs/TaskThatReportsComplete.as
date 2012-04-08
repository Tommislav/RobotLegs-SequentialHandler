package se.salomonsson.sequence.stubs 
{
	import se.salomonsson.sequence.SequentialTask;
	
	/**
	 * ...
	 * @author Tommislav
	 */
	public class TaskThatReportsComplete extends SequentialTask 
	{
		override protected function exeStart():void 
		{
			onCompleted();
		}
	}

}