package tweetcloud
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.display.ContentDisplay;
	
	import flash.display.Sprite;
	import flash.filesystem.File;
	
	import rhythm.events.CustomEvent;

	public class Banner extends Sprite
	{
		private var imageLoader:ImageLoader;
		private var bannerHarness:Sprite;

		private var fileNames:Array;

		private var queue:LoaderMax;

		private var bannerToShow:ContentDisplay;
		
		public function Banner()
		{
			bannerHarness = new Sprite();
			bannerHarness.y = 1760;
			bannerHarness.x = 145;
			addChild(bannerHarness);
				
			queue = new LoaderMax({name:"mainQueue",  onComplete:imagesLoaded});

			fileNames = ["football", "social", "travel", "music", "entertainment", "business", "sport"];
			
			for (var i:int=0; i<fileNames.length; i++)
			{
				var file:File = File.desktopDirectory.resolvePath("kioskData/images/banners");
				file= file.resolvePath(fileNames[i]+".png"); 
				queue.append( new ImageLoader(file.url, {name:fileNames[i]}));

			}
					
			queue.load();

		}
		
		private function imagesLoaded(e:LoaderEvent):void
		{
			//trace("banners loaded");
			dispatchEvent(new CustomEvent(CustomEvent.DEBUG_MESSAGE,true, false, {message:String('banners loaded')}));

		}	
		
		public function showBanner(name:String):void
		{
			trace("showBanner",name)
			clearBanners();
			
			bannerToShow =  LoaderMax.getContent(name);
			TweenMax.killDelayedCallsTo(clearBanners);

			if(bannerToShow)
			{
				bannerHarness.addChild(bannerToShow);
		
				TweenMax.killTweensOf(bannerToShow);
			
				TweenMax.to(bannerToShow,.5,{delay:1, y:-200, ease:Back.easeOut});
			}

		}
		
		public function closeBanner():void
		{
			if(bannerToShow)TweenMax.to(bannerToShow,.25,{y:0, ease:Back.easeIn});
			
			TweenMax.delayedCall(.25,clearBanners);

		}
		
		private function clearBanners():void
		{
			while(bannerHarness.numChildren>0)	bannerHarness.removeChildAt(0);

		}
		
	}
}