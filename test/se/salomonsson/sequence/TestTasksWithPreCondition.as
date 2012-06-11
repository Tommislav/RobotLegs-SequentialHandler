package se.salomonsson.sequence 
{
	import flexunit.framework.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.text.containsString;
	import se.salomonsson.sequence.stubs.TaskThatReportsComplete;
	/**
	 * ...
	 * @author Tommy Salomonsson
	 */
	public class TestTasksWithPreCondition 
	{
		private function setupAndRunTask(task:SequentialTask):SequentialTask
		{
			var seq:SequenceHandler = new SequenceHandler();
			seq.addSequentialTask(task);
			seq.start();
			return task;
		}
		
		
		[Test]
		public function testTaskWithOnePreCondition():void
		{
			var task:SequentialTask = setupAndRunTask(new TaskThatReportsComplete().addPreCondition(returnTrue));
			assertThat(task.status, equalTo(Status.COMPLETED));
		}
		
		[Test]
		public function testTaskWithOneFalsePreCondition():void
		{
			var task:SequentialTask = setupAndRunTask(new TaskThatReportsComplete().addPreCondition(returnFalse));
			assertThat(task.status, equalTo(Status.SKIPPED));
		}
		
		[Test]
		public function testTaskWithSeveralPreConditions():void
		{
			var task:SequentialTask = setupAndRunTask(new TaskThatReportsComplete().addPreCondition(returnTrue).addPreCondition(returnTrue).addPreCondition(returnTrue));
			assertThat(task.status, equalTo(Status.COMPLETED));
		}
		
		[Test]
		public function testInvalidPreConditions_void():void
		{
			// if precondition is "void" then we skip
			
			var task:SequentialTask = setupAndRunTask(new TaskThatReportsComplete().addPreCondition(returnVoid));
			assertThat(task.status, equalTo(Status.SKIPPED));
		}
		
		[Test]
		public function testInvalidPreCondition_Object():void
		{
			var task:SequentialTask = setupAndRunTask(new TaskThatReportsComplete().addPreCondition(returnObject));
			assertThat(task.status, equalTo(Status.COMPLETED));
		}
		
		[Test]
		public function testInvalidPreCondition_String():void
		{
			var task:SequentialTask = setupAndRunTask(new TaskThatReportsComplete().addPreCondition(returnString));
			assertThat(task.status, equalTo(Status.COMPLETED));
		}
		
		[Test]
		public function testInvalidPreCondition_EmptyString():void
		{
			var task:SequentialTask = setupAndRunTask(new TaskThatReportsComplete().addPreCondition(returnEmptyString));
			assertThat(task.status, equalTo(Status.SKIPPED));
		}
		
		[Test]
		public function testInvalidPreCondition_Null():void
		{
			var task:SequentialTask = setupAndRunTask(new TaskThatReportsComplete().addPreCondition(returnNull));
			assertThat(task.status, equalTo(Status.SKIPPED));
		}
		
		public function returnFalse():Boolean { return false; }
		public function returnTrue():Boolean { return true; }
		public function returnVoid():void { }
		public function returnObject():Object { return new Object(); }
		public function returnString():String { return "hej"; }
		public function returnEmptyString():String { return ""; }
		public function returnNull():Object { return null; }
	}

}