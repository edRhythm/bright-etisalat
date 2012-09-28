package tweetcloud.boxes
{
	import flash.display.MovieClip;
	
	
	public class Blob extends MovieClip
	{
		
		public function Blob()
		{
			super();
			gotoAndStop(1 + Math.floor(Math.random()*totalFrames));
		}
	}
}