package rhythm.utils
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import rhythm.events.CustomEvent;

	public class OnScreenKeyboard extends Sprite	{
		//keys
		public var qKey:KeyboardKey;
		public var wKey:KeyboardKey;
		public var eKey:KeyboardKey;
		public var rKey:KeyboardKey;
		public var tKey:KeyboardKey;
		public var yKey:KeyboardKey;
		public var uKey:KeyboardKey;
		public var iKey:KeyboardKey;
		public var oKey:KeyboardKey;
		public var pKey:KeyboardKey;
		public var aKey:KeyboardKey;
		public var sKey:KeyboardKey;
		public var dKey:KeyboardKey;
		public var fKey:KeyboardKey;
		public var gKey:KeyboardKey;
		public var hKey:KeyboardKey;
		public var jKey:KeyboardKey;
		public var kKey:KeyboardKey;
		public var lKey:KeyboardKey;
		public var zKey:KeyboardKey;
		public var xKey:KeyboardKey;
		public var cKey:KeyboardKey;
		public var vKey:KeyboardKey;
		public var bKey:KeyboardKey;
		public var nKey:KeyboardKey;
		public var mKey:KeyboardKey;
		
		public var num0:KeyboardKey;
		public var num1:KeyboardKey;
		public var num2:KeyboardKey;
		public var num3:KeyboardKey;
		public var num4:KeyboardKey;
		public var num5:KeyboardKey;
		public var num6:KeyboardKey;
		public var num7:KeyboardKey;
		public var num8:KeyboardKey;
		public var num9:KeyboardKey;
		
		public var underscoreKey:KeyboardKey;
		public var shiftKey:KeyboardKey;
		public var spaceKey:KeyboardKey;
		public var delKey:KeyboardKey;
		
		private var allLetterKeys:Array;
		private var LcKeyNames:Array;
		private var allNumberKeys:Array;
		private var numberNames:Array;
		
		public var currentCase:String
		
		
		public function OnScreenKeyboard()
		{
			numberNames = ["1","2","3","4","5","6","7","8","9","0"]
			allNumberKeys = [ num1, num2, num3, num4, num5, num6, num7, num8, num9, num0];
			allLetterKeys = [qKey,wKey,eKey,rKey,tKey,yKey,uKey,iKey,oKey,pKey,aKey,sKey,dKey,fKey,gKey,hKey,jKey,kKey,lKey,zKey,xKey,cKey,vKey,bKey,nKey,mKey];
			LcKeyNames = ["q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m"];
			
			setLowercase();
			setNumbers();
			setOtherKeys();
		}

		private function setOtherKeys():void
		{
			underscoreKey.KeyName = "_";
			shiftKey.KeyName = "shift";
			spaceKey.KeyName="space";
			delKey.KeyName="del";

		}

		
		private function setNumbers():void
		{
			for(var i:int = 0; i<numberNames.length; i++)
			{
				allNumberKeys[i].KeyName = numberNames[i];
			}
		}
		
		public function setLowercase():void
		{			
			for(var i:int = 0; i<allLetterKeys.length; i++)
			{
				allLetterKeys[i].KeyName = LcKeyNames[i];
			}
			
			currentCase = "lower";
			TweenMax.to(shiftKey.keyBG,.25,{removeTint:true});


		}
		
		public function setUppercase():void
		{			
			for(var i:int = 0; i<allLetterKeys.length; i++)
			{
				allLetterKeys[i].KeyName = LcKeyNames[i].toUpperCase();
			}
			
			currentCase = "upper";
			
			TweenMax.to(shiftKey.keyBG,.25,{tint:0xa7cf57});

			
		}
	}
}