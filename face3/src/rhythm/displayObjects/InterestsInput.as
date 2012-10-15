package rhythm.displayObjects
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class InterestsInput extends Sprite
	{
		
	private var interestNames:Array ;
	private var allBoxes:Array;
	private var config:XML;
	
		public function InterestsInput(interests:Array, configXML:XML)
		{
			config = configXML;
			interestNames = interests;
			setUpBoxes();
		}
		
		public function get userInterests():Array
		{
			var interestsArray:Array = [];
			
			for(var i:int = 0; i<allBoxes.length; i++)
			{
				if(allBoxes[i].selectedState==true)	interestsArray.push(allBoxes[i].name);
			}
			
			
			return interestsArray;

		}
		
		private function setUpBoxes():void
		{
			allBoxes = [];
			
			for(var i:int = 0; i<interestNames.length; i++)
			{
				var tickB:GreenTickBox = new GreenTickBox();
				tickB.mouseChildren=false;
				
				tickB.labelTF.text = interestNames[i];
				tickB.name = interestNames[i];

				tickB.y = (i*tickB.height)+i*20;
				tickB.addEventListener(MouseEvent.MOUSE_DOWN, tickClick, false,0,true);
				if(config.touchScreen == "true") tickB.addEventListener(MouseEvent.MOUSE_OVER, tickClick, false,0,true);
				
				allBoxes.push(tickB);
				
				addChild(tickB);
				
			}
			
			TweenMax.allFrom(allBoxes,.5,{transformAroundCenter:{scaleX:0, scaleY:0}, ease:Back.easeOut},.2);

		}
		
		private function tickClick(event:MouseEvent):void
		{			
			var box:GreenTickBox = GreenTickBox(event.target);
			box.toggleSelected();			
		}
	}
}