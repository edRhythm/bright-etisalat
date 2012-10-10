package tweetcloud.boxes
{
	import com.greensock.TweenMax;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import rhythm.events.CustomEvent;
	
	
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
		public var profileImageHolder:Sprite;
		
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
		
		private var messageImagePath:String;
		
		private var profilePath:String;
		private var profileImage:Sprite;
		
		private var bodyImagePath:String;
		private var bodyImage:Sprite;
		
		private var bgColours:Array = [0xe91385, 0x94bc2b, 0x003edd];
		private var bgColour:uint;
		private var moderated:String;

		private var messageImageLoader:ImageLoader;
		private var bodyImageLoader:ImageLoader;
		private var profileImageLoader:ImageLoader;
		
		
		public function TweetBox()
		{
			super();
			blendMode = BlendMode.LAYER;
			mouseChildren = false;
		}
		
		
		/// TWEET SETUP		
		
		public function populateTweet(tweet:XML):void
		{
			setDefaultFrameByLabel('tweet');
			
			realName = 'Dave';
			twitterName = tweet.User;
			message = tweet.Message;
			profilePath = tweet.ProfileImage;
			
			interests = '';			
			for (var j:int=0; j<tweet.Tags.Tag.length(); ++j)
			{
				interests += tweet.Tags.Tag[j].toString();
				if (j < tweet.Tags.Tag.length()-1) interests += ', '; 
			}
			
			repopulateTweet();
		}
		
		private function repopulateTweet():void
		{
			nameField.text = realName;
			
			handleField.text = twitterName;
			handleField.y = nameField.y + nameField.textHeight + 5;
			tweetBird.y = handleField.y + 3.5;
			
			handleField.alpha = tweetBird.alpha = .5;
			messageField.text = message;
			
			interestsField.text = interests;
			interestsField.alpha = .7;
			
			bgColour = bgColours[Math.floor(Math.random()*bgColours.length)];
			TweenMax.to(bg, 0, {tint:bgColour});
			if (blank) TweenMax.to(blank, 0, {tint:bgColour});
			
			killImageLoaders();
			
			var filePath:String = String(File.desktopDirectory.url) + '/kioskData/images/' + profilePath;
			var defaultPath:String = String(File.desktopDirectory.url) + '/kioskData/images/default/twitter.png';			
			profileImageLoader = new ImageLoader(filePath, {alternateURL:defaultPath, onComplete:onProfileImageLoaderComplete});
			profileImageLoader.load(true);
		}
		
		private function killImageLoaders():void
		{
			if (profileImageLoader) killImageLoader(profileImageLoader);
			if (bodyImageLoader) killImageLoader(messageImageLoader);
			if (messageImageLoader) killImageLoader(messageImageLoader);
		}
		
		private function killImageLoader(loader:ImageLoader):void
		{
			loader.cancel();
			loader.dispose();
			loader = null;
		}
		
		private function onProfileImageLoaderComplete(e:LoaderEvent):void
		{
			profileImage = e.target.content;
			profileImage.width = profileImageHolder.width;
			profileImage.height = profileImageHolder.height;			
			profileImageHolder.addChild(profileImage);
			
			dispatchEvent(new CustomEvent(CustomEvent.TWEETBOX_READY, false, false, { displayBox:this }));
		}
		
		
		
		/// TWEET IMAGE SETUP		
		
		public function populateTweetImage(tweet:XML):void
		{
			setDefaultFrameByLabel('tweetImage');
			
			twitterName = tweet.User;
			message = tweet.Message;
			bodyImagePath = tweet.BodyImage;
			
			repopulateTweetImage();
		}	
		
		private function repopulateTweetImage():void
		{
			handleField.text = twitterName;
			tweetBird.x = handleField.x + handleField.width - handleField.textWidth - tweetBird.width - 5;
			
			handleField.alpha = tweetBird.alpha = .5;
			messageField.text = message;
			
			bgColour = bgColours[Math.floor(Math.random()*bgColours.length)];
			TweenMax.to(bg, 0, {tint:bgColour});
			if (blank) TweenMax.to(blank, 0, {tint:bgColour});
			
			killImageLoaders();
			
			var filePath:String = String(File.desktopDirectory.url) + '/kioskData/images/body_images/' + bodyImagePath;
			var defaultPath:String = String(File.desktopDirectory.url) + '/kioskData/images/default/twitter.png';			
			bodyImageLoader = new ImageLoader(filePath, {alternateURL:defaultPath, onComplete:onBodyImageLoaderComplete});
			bodyImageLoader.load(true);
		}
		
		private function onBodyImageLoaderComplete(e:LoaderEvent):void
		{
			image = e.target.content;
			
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
			
			dispatchEvent(new CustomEvent(CustomEvent.TWEETBOX_READY, false, false, { displayBox:this }));
		}
		
		
		
		/// MESSAGE SETUP		
		
		public function populateMessage(message:XML):void
		{			
			setDefaultFrameByLabel('message');
			
			moderated = message.@moderated;
			realName = message.username;
			twitterName = message.twitter;
			messageImagePath = message.photo;
			
			interests = '';			
			for (var j:int=0; j<message.interests.interest.length(); ++j)
			{
				interests += message.interests.interest[j].toString();
				if (j < message.interests.interest.length()-1) interests += ', '; 
			}
			
			repopulateMessage();
		}
		
		private function repopulateMessage():void
		{
			nameField.text = handleField.text = '';
			tweetBird.visible = false;
			
			if (moderated == 'true')
			{
				nameField.text = realName;
				handleField.text = twitterName;
				tweetBird.visible = true;
			}
			
			tweetBird.x = handleField.x + handleField.width/2 - handleField.textWidth/2 - tweetBird.width - 1;
			
			handleField.alpha = tweetBird.alpha = .5;
			interestsField.text = interests;
			
			bgColour = bgColours[Math.floor(Math.random()*bgColours.length)];
			TweenMax.to(bg, 0, {tint:bgColour});
			if (blank) TweenMax.to(blank, 0, {tint:bgColour});
			
			killImageLoaders();
			
			var filePath:String = String(File.desktopDirectory.url) + '/kioskData/images/' + messageImagePath;
			var defaultPath:String = String(File.desktopDirectory.url) + '/kioskData/images/default/twitter.png';			
			messageImageLoader = new ImageLoader(filePath, {alternateURL:defaultPath, onComplete:onMessageImageLoaderComplete});
			messageImageLoader.load(true);
		}
		
		private function onMessageImageLoaderComplete(e:LoaderEvent):void
		{
			image = e.target.content;
			image.width = image.height = messageImageMask.width;
			
			while (messageImage.numChildren > 0) messageImage.removeChildAt(0);
			messageImage.addChild(image);
			
			messageImage.x = messageImageMask.x;
			messageImage.y = messageImageMask.y;
			messageImage.mask = messageImageMask;
			
			dispatchEvent(new CustomEvent(CustomEvent.TWEETBOX_READY, false, false, { displayBox:this }));
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