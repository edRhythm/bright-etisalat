package tweetcloud.boxes
{
	import com.greensock.TweenMax;
	
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	
	public class TweetBox extends MovieClip
	{
		// timeline
		public var nameField:TextField;
		public var handleField:TextField;
		public var tweetBird:Sprite;
		public var messageField:TextField;
		public var interestsField:TextField;
		
		public var tweetImage:Sprite;
		public var tweetImageMask:Sprite;
		
		public var messageImage:Sprite;
		public var messageImageMask:Sprite;
		
		public var bg:Sprite;
		public var blank:Sprite;
		
		// class
		public var type:String;
		public var frameCurrent:String;
		
		private var realName:String;
		private var twitterName:String;
		private var message:String;
		private var interests:String;
		private var image:Sprite;
		
		private var bgColours:Array = [0xe91385, 0x94bc2b, 0x003edd];
		private var bgColour:uint;
		
		
		public function TweetBox()
		{
			super();
			blendMode = BlendMode.LAYER;
			mouseChildren = false;
		}
		
		public function populateTweet(realName:String, twitterName:String, message:String):void
		{
			setDefaultFrameByLabel('tweet');
			
			this.realName = realName;
			this.twitterName = twitterName;
			this.message = message;
			
			repopulateTweet();
		}
		
		private function repopulateTweet():void
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
		
		public function populateTweetImage(twitterName:String, message:String, image:Sprite=null):void
		{
			setDefaultFrameByLabel('tweetImage');
			
			this.twitterName = twitterName;
			this.message = message;
			this.image = image;
			
			repopulateTweetImage();
		}	
		
		private function repopulateTweetImage():void
		{
			handleField.text = twitterName;
			tweetBird.x = handleField.x + handleField.width - handleField.textWidth - tweetBird.width - 5;
			
			handleField.alpha = tweetBird.alpha = .35;
			messageField.text = message;
			
			bgColour = bgColours[Math.floor(Math.random()*bgColours.length)];
			TweenMax.to(bg, 0, {tint:bgColour});
			if (blank) TweenMax.to(blank, 0, {tint:bgColour});
			
			if (image != null)
			{
				while (tweetImage.numChildren > 0) tweetImage.removeChildAt(0);
				tweetImage.addChild(image);
				tweetImage.mask = tweetImageMask;
				
				// find best image fit
				if (image.width < image.height)
				{
					image.height = tweetImageMask.height;
					image.scaleX = image.scaleY;
					image.x = -(image.width - tweetImageMask.width)/2;
				} 
				else {
					image.width = tweetImageMask.width;
					image.scaleY = image.scaleX;
					image.y = -(image.height - tweetImageMask.height)/2;
				}
			}			
		}
		
		public function populateMessage(realName:String, twitterName:String, interests:String, image:Sprite=null):void
		{
			setDefaultFrameByLabel('message');
			
			this.realName = realName;
			this.twitterName = twitterName;
			this.interests = interests;
			this.image = image;
			
			repopulateMessage();
		}
		
		private function repopulateMessage():void
		{
			nameField.text = realName;			
			handleField.text = twitterName;
			tweetBird.x = handleField.x + handleField.width/2 - handleField.textWidth/2 - tweetBird.width - 1;
			
			handleField.alpha = tweetBird.alpha = .35;
			interestsField.text = interests;
			
			bgColour = bgColours[Math.floor(Math.random()*bgColours.length)];
			TweenMax.to(bg, 0, {tint:bgColour});
			if (blank) TweenMax.to(blank, 0, {tint:bgColour});
			
			// find best image fit
			if (image != null)
			{
				image.width = image.height = messageImageMask.width;
					
				while (messageImage.numChildren > 0) messageImage.removeChildAt(0);
				messageImage.addChild(image);
				
				messageImage.x = messageImageMask.x;
				messageImage.y = messageImageMask.y;
				messageImage.mask = messageImageMask;
			}
		}
		
		private function setDefaultFrameByLabel(label:String):void
		{
			type = label;
			gotoFrame(type);
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
				
				if (type == 'tweet') repopulateTweet();
				if (type == 'tweetImage') repopulateTweetImage();
				
				updateTexture = true;
			}
			
			return updateTexture;
		}
	}
}