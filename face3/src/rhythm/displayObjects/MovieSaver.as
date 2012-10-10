package rhythm.displayObjects
{
	import com.greensock.loading.VideoLoader;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;

	public class MovieSaver extends Sprite
	{
		private var saverVideo:VideoLoader;
		
		public function MovieSaver()
		{
			var vidFile:File = File.desktopDirectory.resolvePath("kioskData/videos");
			vidFile= vidFile.resolvePath("saver.mp4"); 
			
			saverVideo = new VideoLoader(vidFile.url, {name:"saverVideo", container:this, autoPlay:false, y:100, visible:false});
			saverVideo.load();
			saverVideo.addEventListener(VideoLoader.VIDEO_COMPLETE, vidCompleteHandler);

		}
		
		private function vidCompleteHandler(e:Event):void
		{
			//trace("*********vidCompleteHandler");
			restartVideo();
		}
		
		public function stopVideo():void
		{
			//trace("stopVideo");
			saverVideo.gotoVideoTime(0);
			saverVideo.pauseVideo();
			saverVideo.content.visible = false;

		}
		
		public function restartVideo():void
		{
			//trace("restartVideo");
			saverVideo.content.visible = true;
			saverVideo.gotoVideoTime(0);
			saverVideo.playVideo();
		}
	}
}