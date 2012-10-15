package rhythm.displayObjects
{
	import com.greensock.loading.VideoLoader;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import rhythm.events.CustomEvent;
	import rhythm.utils.TimeOut;

	public class MovieSaver extends Sprite
	{
		private var saverVideo:VideoLoader;
		private var timeOut:TimeOut;
		private var timeOutDelay:Number;
		
		public function MovieSaver()
		{
		}
		
		public function initWithTime(tDelay:Number):void
		{
			timeOutDelay = tDelay;
			timeOut = new TimeOut(timeOutDelay, stopVideo);
			
			var vidFile:File = File.desktopDirectory.resolvePath("kioskData/images/videos");
			vidFile= vidFile.resolvePath("saver.mp4"); 
			
			saverVideo = new VideoLoader(vidFile.url, {name:"saverVideo", container:this, autoPlay:false, y:100, visible:false});
			saverVideo.load();
			saverVideo.addEventListener(VideoLoader.VIDEO_COMPLETE, vidCompleteHandler);
		}
		
		private function vidCompleteHandler(e:Event):void
		{
			//trace("*********vidCompleteHandler");
			restartVideo(false);
		}
		
		public function stopVideo():void
		{
			//trace( "getCallee",  getCallee());

			//trace("stopVideo");
			saverVideo.gotoVideoTime(0);
			saverVideo.pauseVideo();
			saverVideo.content.visible = false;
			
			timeOut.cancel();
			dispatchEvent(new CustomEvent(CustomEvent.SAVER_STOPPED));
		}
		
		public function restartVideo(resetTimeout:Boolean = true):void
		{

		//	trace( "getCallee",  getCallee());
			
			//trace("restartVideo, resetTimeout", resetTimeout);
			saverVideo.content.visible = true;
			saverVideo.gotoVideoTime(0);
			saverVideo.playVideo();
			
			resetTimeout ? timeOut.reset() : null;
		}
		
		private  function getCallee(calltStackIndex:int=3):String
		{
			var stackLine:String = new Error().getStackTrace().split( "\n" , calltStackIndex + 1 )[calltStackIndex];
			var functionName:String = stackLine.match( /\w+\(\)/ )[0];
			var className:String = stackLine.match( /(?<=\/)\w+?(?=.as:)/ )[0];
			var lineNumber:String = stackLine.match( /(?<=:)\d+/ )[0];
			return className + "." + functionName + ", line " + lineNumber;
		}	}
}