package  
{
	import se.salomonsson.sequence.TestCompositeTask;
	import se.salomonsson.sequence.TestParallelTask;
	import se.salomonsson.sequence.TestEventBus;
	import se.salomonsson.sequence.TestSequenceHandler;
	import se.salomonsson.sequence.TestTasksWithPreCondition;
	import se.salomonsson.sequence.TestTaskWithEventBus;
	import se.salomonsson.sequence.TestThatTaskIsTestable;
	
	
	/**
	 * This is the main testsuit where you can configure which sub-testsuits you want to run.
	 * @author Tommy Salomonsson
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]	
	public class MainSuite
	{
		
		public var asyncTest:TestSequenceHandler;
		public var testTaskWithRobotlegsDispatcher:TestTaskWithEventBus;
		public var robotlegsDispatchHelperTest:TestEventBus;
		public var testParallelTask:TestParallelTask;
		public var testCompositeTask:TestCompositeTask;
		public var testTaskWithPreCondition:TestTasksWithPreCondition;
		public var testThatTaskIsTestable:TestThatTaskIsTestable;
	}

}