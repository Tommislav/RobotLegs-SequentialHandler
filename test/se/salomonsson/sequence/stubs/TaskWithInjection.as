package se.salomonsson.sequence.stubs 
{
	import se.salomonsson.sequence.SequentialTask;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TaskWithInjection extends SequentialTask 
	{
		[Inject]
		public var injectedString:String;
		
		public function callComplete():void
		{
			onCompleted();
		}
	}

}