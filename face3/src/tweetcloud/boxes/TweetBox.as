package tweetcloud.boxes
{
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	
	public class TweetBox extends MovieClip
	{
		// timeline
		public var nameField:TextField;
		public var handleField:TextField;
		public var tweetBird:Sprite;
		public var messageField:TextField;
		
		public var bg:Sprite;
		public var blank:Sprite;
		
		// class
		public var frameDefault:String;
		public var frameCurrent:String;
		
		private var realName:String;
		private var twitterName:String;
		private var message:String;
		
		private var bgColours:Array = [0xe91385, 0x94bc2b, 0x003edd];
		private var bgColour:uint;
		
		
		public function TweetBox()
		{
			super();
			setDefaultFrameByLabel('tweet');
		}
		
		public function populate(realName:String, twitterName:String, message:String):void
		{
			this.realName = realName;
			this.twitterName = twitterName;
			this.message = message;
			
			repopulate();
		}
		
		private function repopulate():void
		{
			nameField.text = realName;
			
			handleField.text = twitterName;
			handleField.y = nameField.y + nameField.textHeight + 5;
			tweetBird.y = handleField.y + 3.5;
			
			handleField.alpha = tweetBird.alpha = .35;
			messageField.text = message;
			
			bgColour = bgColours[Math.floor(Math.random()*bgColours.length)];
			TweenMax.to(bg, 0, {tint:bgColour});
			if (blank) TweenMax.to(blank, 0, {tint:bgColour});
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
				repopulate();
				updateTexture = true;
			}
			
			return updateTexture;
		}
	}
}