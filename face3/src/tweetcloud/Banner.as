package tweetcloud
{
	import com.greensock.loading.ImageLoader;
	
	import flash.display.Sprite;
	import com.greensock.loading.LoaderMax;
	import flash.filesystem.File;
	import com.greensock.events.LoaderEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.display.ContentDisplay;

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
				var file:File = File.desktopDirectory.resolvePath("kioskData/bannerImages");
				file= file.resolvePath(fileNames[i]+".png"); 
				trace("file url",file.url);
				queue.append( new ImageLoader(file.url, {name:fileNames[i]}));

			}
					
			queue.load();

		}
		
		private function imagesLoaded(e:LoaderEvent):void
		{
			//trace("banners loaded");
		}	
		
		public function showBanner(name:String):void
		{
			//trace("showBanner",name)
			clearBanners();
			
			bannerToShow =  LoaderMax.getContent(name);
			bannerHarness.addChild(bannerToShow);
			
			TweenMax.killDelayedCallsTo(clearBanners);
			TweenMax.killTweensOf(bannerToShow);
			
			TweenMax.to(bannerToShow,.5,{delay:1, y:-200, ease:Back.easeOut});

		}
		
		public function closeBanner():void
		{
			TweenMax.to(bannerToShow,.25,{y:0, ease:Back.easeIn});
			TweenMax.delayedCall(.25,clearBanners);

		}
		
		private function clearBanners():void
		{
			while(bannerHarness.numChildren>0)	bannerHarness.removeChildAt(0);

		}
		
	}
}