package rhythm.utils
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import rhythm.events.CustomEvent;
	import flash.display.MovieClip;

	public class KeyboardKey extends Sprite
	{
		
		public var keyTF:TextField;
		public var keyBG:MovieClip;
		public var keyName:String;
		
		public function KeyboardKey()
		{
			mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_DOWN, doKeyClick, false,0,true);
			//addEventListener(MouseEvent.MOUSE_OVER, doKeyClick, false,0,true);

		}
		
		private function doKeyClick(event:MouseEvent):void
		{
			dispatchEvent(new CustomEvent(CustomEvent.KEY_PRESSED,true,false,{keyPressed:keyName}));
			if(keyName!="shift") TweenMax.to(keyBG,.1,{tint:0xa7cf57, repeat:1, yoyo:true});
		}
		
		public function set KeyName(keyID:String):void
		{
			keyName = keyID;
			if(keyTF)keyTF.text = keyName;
		}
		
		public function get KeyName():String
		{
			return keyName;
		}
	}
}