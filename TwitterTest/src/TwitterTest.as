package
{
	import com.swfjunkie.tweetr.Tweetr;
	import com.swfjunkie.tweetr.events.TweetEvent;
	
	import flash.display.Sprite;
	
	
	public class TwitterTest extends Sprite
	{
		
		public function TwitterTest()
		{
			var tweetr:Tweetr = new Tweetr();			
			tweetr.addEventListener(TweetEvent.COMPLETE, onTweetrSearchComplete);
			tweetr.addEventListener(TweetEvent.FAILED, onTweetrSearchFail);
			
			tweetr.search("hello", null, 20);
		}
		
		private function onTweetrSearchComplete(e:TweetEvent):void
		{
			trace(e.responseArray);
		}
		
		private function onTweetrSearchFail(e:TweetEvent):void
		{
			trace("======> !!!!!! TWEETR search failed !!!!!!", e.info);
		}	
	}
}