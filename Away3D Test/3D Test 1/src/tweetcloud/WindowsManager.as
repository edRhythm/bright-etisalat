package tweetcloud
{
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	

	public class WindowsManager
	{
		private var mainWindow:NativeWindow;
		
		
		public function WindowsManager()
		{
		}
		
		public function setUpMainWindow(window:NativeWindow):void
		{
			mainWindow = window;
			mainWindow.title = "3D";
			mainWindow.width = 1080;
			mainWindow.height = 1920;
			mainWindow.stage.align = StageAlign.TOP_LEFT;
			mainWindow.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			mainWindow.x = 500;
			mainWindow.y = -(1920 - Screen.mainScreen.visibleBounds.height)/2;
			
			// fitMainWindowToScreen();
		}
		
		public function fitMainWindowToScreen():void
		{
			 mainWindow.height = Screen.mainScreen.visibleBounds.height;
			 mainWindow.width = (mainWindow.height/16)*9;
		}
	}
}