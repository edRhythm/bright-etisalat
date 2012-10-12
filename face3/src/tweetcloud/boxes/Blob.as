package tweetcloud.boxes
{
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import rhythm.utils.DataIO;
	
	
	public class Blob extends MovieClip
	{
		public var thing:Sprite;
		
		
		public function Blob()
		{
			super();
		}
		
		public function init(dataIO:DataIO):void
		{
			gotoAndStop(1 + Math.floor(Math.random()*totalFrames));
			
			var colours:XMLList = dataIO.configXML.threeD.blobs.colours.colour;
			var colour:uint = uint(colours[Math.floor(Math.random()*colours.length())]);			
			TweenMax.to(thing, 0, {tint:colour});
		}		
	}
}