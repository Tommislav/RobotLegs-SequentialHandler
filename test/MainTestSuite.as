package  
{
	import se.salomonsson.sequence.TestParallelTask;
	import se.salomonsson.sequence.TestSequenceHandler;
	
	
	/**
	 * This is the main testsuit where you can configure which sub-testsuits you want to run.
	 * @author Tommy Salomonsson
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]	
	public class MainTestSuite
	{
		
		public var asyncTest:TestSequenceHandler;
		public var testParallelTask:TestParallelTask;
		
		/* Examples!
		
		[Test]
		public function doTest():void
		{
			//org.flexunit.Assert;
			Assert.assertTrue(true);
		}
		
		[Test(sequence,timeout="900")]
		public function testEvent():void
		{
			// org.flexunit.sequence.Async
			Async.handleEvent( testCase(this), targetDispatcher, "eventName", eventHandler, timeout, passThroughObject, timeoutHandler );
		}
		
		private function eventHandler( e:Event, passthrough:Object ):void 
		{
			
		}
		
		
		
		
		*/
		
		
	}

}