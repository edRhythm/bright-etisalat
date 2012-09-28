package tweetcloud.boxes
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	
	public class TweetBox extends MovieClip
	{
		public var readout:TextField;
		
		public var frameDefault:String;
		public var frameCurrent:String;
		
		
		public function TweetBox()
		{
			super();
			
			var chance:Number = Math.random();
			
			if (chance > -1 && chance <= .33) setDefaultFrameByLabel('green');
			if (chance > .33 && chance <= .66) setDefaultFrameByLabel('pink');
			
			if (chance > .66)
			{
				setDefaultFrameByLabel('blue');
				readout.text = String(int(Math.random()*100));
			}
		}
		
		private function setDefaultFrameByLabel(label:String):void
		{
			frameDefault = label;
			gotoFrame(frameDefault);
		}
		
		private function gotoFrame(frame:String):void
		{
			frameCurrent = frame;
			gotoAndStop(frame);
		}
		
		public function showFrameTexture(frame:String):Boolean
		{
			var updateTexture:Boolean = false;
			
			if (frameCurrent != frame) 
			{
				gotoFrame(frame);
				updateTexture = true;
			}
			
			return updateTexture;
		}
	}
}