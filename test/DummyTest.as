package  
{
	import org.flexunit.Assert;
	/**
	 * ...
	 * @author Tommislav
	 */
	public class DummyTest 
	{
		
		public function DummyTest() 
		{
			
		}
		
		[Test]
		public function testDummy():void
		{
			Assert.assertEquals( "hej", "hej" );
		}
	}

}