package
{
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.events.Event;
	
	import tweetcloud.TweetCloud;
	import tweetcloud.WindowsManager;
	
	
	[SWF(frameRate="60", backgroundColor="#000000", width="1080", height="1920")]
	public class Main extends Sprite
	{		
		
		public function Main()
		{	
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			var windowsManager:WindowsManager = new WindowsManager();
			windowsManager.setUpMainWindow(stage.nativeWindow);
			
			var tweetCloud:TweetCloud = new TweetCloud();
			addChild(tweetCloud);
			tweetCloud.init();
		}
	}
}