package rhythm.text
{
	import flash.text.*;
	
	public class TFCreator
	{
		public function TFCreator()
		{
		}
		
		public static function createTextField($width:Number=100, $height:Number=100, $multiline:Boolean = false, $wordWrap:Boolean = false, $embedFonts:Boolean = true, $autoSize:String = "left", $defaultTextFormat:TextFormat=null,  $selectable:Boolean=false, $gridFitType:String = "pixel"):TextField
			
		{
			var result:TextField = new TextField();
			
			result.embedFonts = $embedFonts;
			result.width = $width;
			result.height = $height;
			result.multiline = $multiline;
			result.autoSize = $autoSize;
			result.wordWrap = $wordWrap;
			result.gridFitType = $gridFitType;
			result.selectable = $selectable;
			if($defaultTextFormat!=null)result.defaultTextFormat = $defaultTextFormat;
			//	result.defaultTextFormat = $defaultTextFormat;
			
			if($embedFonts)
			{
				result.antiAliasType = "advanced";
			};
			
			return result;
		};
	}
}

