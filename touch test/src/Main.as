package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.text.TextField;
	
	import rhythm.text.TFCreator;
	
	[SWF(width="700", height="1500", frameRate="30", backgroundColor="0x444444")]

	public class Main extends Sprite
	{
		private var outputTF:TextField;
		private var mouseArea:Sprite;
		private var mouseArea1:Sprite;
		public function Main()
		{
			outputTF = TFCreator.createTextField(150,300,true,true,false);	
			outputTF.background = true;
			addChild(outputTF);
			
			mouseArea = new Sprite();
			mouseArea.graphics.beginFill(0xFF6600);
			mouseArea.graphics.drawRect(0,0,100,100);
			mouseArea.x = 500;
			mouseArea.y = 200;
			mouseArea.name = "orange box";
			
			addChild(mouseArea);
			
			mouseArea1 = new Sprite();
			mouseArea1.graphics.beginFill(0xFFFF00);
			mouseArea1.graphics.drawRect(0,0,100,100);
			mouseArea1.x = 500;
			mouseArea1.y = 500;
			
			mouseArea1.name = "yellow box";

			
			addChild(mouseArea1);

	//		mouseArea.addEventListener(MouseEvent.CLICK, doMouseThing, false, 0, true);	
			mouseArea.addEventListener(MouseEvent.MOUSE_DOWN, doMouseThing, false, 0, true);	
			mouseArea.addEventListener(MouseEvent.MOUSE_OVER, doMouseThing, false, 0, true);	
			mouseArea.addEventListener(MouseEvent.MOUSE_UP, doMouseThing, false, 0, true);	
			mouseArea.addEventListener(MouseEvent.MOUSE_OUT, doMouseThing, false, 0, true);	
			mouseArea.addEventListener(MouseEvent.DOUBLE_CLICK, doMouseThing, false, 0, true);	
			mouseArea.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, doMouseThing, false, 0, true);	
			mouseArea.addEventListener(MouseEvent.RIGHT_MOUSE_UP, doMouseThing, false, 0, true);	
			
			mouseArea.addEventListener(TouchEvent.TOUCH_BEGIN, doTouchThing, false, 0, true);	
			
		//	mouseArea1.addEventListener(MouseEvent.CLICK, doMouseThing, false, 0, true);	
			mouseArea1.addEventListener(MouseEvent.MOUSE_DOWN, doMouseThing, false, 0, true);	
			mouseArea1.addEventListener(MouseEvent.MOUSE_OVER, doMouseThing, false, 0, true);	
			mouseArea1.addEventListener(MouseEvent.MOUSE_UP, doMouseThing, false, 0, true);	
			mouseArea1.addEventListener(MouseEvent.MOUSE_OUT, doMouseThing, false, 0, true);	
			mouseArea1.addEventListener(MouseEvent.DOUBLE_CLICK, doMouseThing, false, 0, true);	
			mouseArea1.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, doMouseThing, false, 0, true);	
			mouseArea1.addEventListener(MouseEvent.RIGHT_MOUSE_UP, doMouseThing, false, 0, true);	
			
			mouseArea1.addEventListener(TouchEvent.TOUCH_BEGIN, doTouchThing, false, 0, true);	


		}
		
		private function doMouseThing(event:MouseEvent):void
		{
			
			outputTF.appendText("\nTYPE:"+event.type
				+"\nlocal x:"+event.localX
				+" local y:"+event.localY
				+"\nstage x:"+event.stageX
				+" stage y:"+event.stageY
				+"\nTarget "+event.target.name+"\n");
		}
		
		private function doTouchThing(event:TouchEvent):void
		{
			
			outputTF.appendText("\nTYPE:"+event.type
				+"\nlocal x:"+event.localX
				+" local y:"+event.localY
				+"\nstage x:"+event.stageX
				+" stage y:"+event.stageY
				+"\nTarget "+event.target.name+"\n");
		}
	}
}