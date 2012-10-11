package rhythm.utils
{
	import flash.display.Sprite;


	
	public class OnScreenDebugger extends Sprite
	{
		
		
		public function OnScreenDebugger()
		{	
			update("hello from"+this);
			
		}
		
		public function update(message:String):void
		{
			debugTF.text+="\n * "+message;
			
		}
	}
}