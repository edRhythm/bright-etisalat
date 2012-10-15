package rhythm.text
{
	import flash.text.*;	

	public class TFormats
	{
		public function TFormats()
		{
		}
		
		public static function getTFormatToSize(size:int, font:Font, colour:int=0xFFFFFF, tAlign:String="left",  lineSpace:Number=0):TextFormat
		{
			var fFont:Font = Font(font);
			
			var newFormat:TextFormat = new TextFormat();
			newFormat.font = fFont.fontName;
			newFormat.color = colour;
			newFormat.size = size;
			newFormat.align = tAlign;
			newFormat.leading = lineSpace;		
			
			return newFormat;
			
		}
	}
}
