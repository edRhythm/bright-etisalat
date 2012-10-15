package rhythm.utils
{
	public class StringUtils
	{
		public function StringUtils()
		{
		}
		
		public static function toTitleCase( original:String ):String {
			var words:Array = original.split( " " );
			for (var i:int = 0; i < words.length; i++) {
				words[i] = toInitialCap( words[i] );
			}
			return ( words.join( " " ) );
		}
		public static function toInitialCap( original:String ):String {
			return original.charAt( 0 ).toUpperCase(  ) + original.substr( 1 ).toLowerCase(  );
		}    
	}
}