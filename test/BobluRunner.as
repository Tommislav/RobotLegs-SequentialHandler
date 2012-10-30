package  
{
	import com.boblu.lurunner.LUContainer;
	import com.boblu.lurunner.LURunner;
	import flash.display.Sprite;
	import org.flexunit.runner.FlexUnitCore;
	import se.salomonsson.sequence.SequenceHandler;
	
	/**
	 * ...
	 * @author Tommislav
	 */
	public class BobluRunner extends LUContainer 
	{
		protected var _core:FlexUnitCore;
        protected var _runner:LURunner;
        protected var _allSuites:Array;
 
        override protected function setup():void
        {
			Env.stage = stage;
			SequenceHandler.debugStage = stage;
			
            _allSuites     = [ RobotLegsSequentialHandlerTestSuite ];
            _runner     = new LURunner();
            addChild( _runner );
        }
 
        override protected function start():void
        {
            _core = new FlexUnitCore();
            _core.addListener( _runner );
            _core.run( _allSuites );
        }
	}

}