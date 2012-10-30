package  
{
	import se.salomonsson.sequence.TestCompositeTask;
	import se.salomonsson.sequence.TestParallelTask;
	import se.salomonsson.sequence.TestSequenceHandler;
	import se.salomonsson.sequence.TestTasksWithPreCondition;
	
	
	/**
	 * This is the testsuit for all tests for the sequences.
	 * @author Tommy Salomonsson
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]	
	public class RobotLegsSequentialHandlerTestSuite
	{
		
		public var asyncTest:TestSequenceHandler;
		public var testParallelTask:TestParallelTask;
		public var testCompositeTask:TestCompositeTask;
		public var testTaskWithPreCondition:TestTasksWithPreCondition;
	}

}