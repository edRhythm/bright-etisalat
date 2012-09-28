package rhythm.utils
{
	public class ArrayUtils
	{
		public function ArrayUtils()
		{
		}
		
		public static function findHighestIntInVector(a:Vector.<int>) : int 
		{
			var z:int;
			var highestInt:int;
			var vectorLength:int = a.length-1;
			
			for (var i:int = vectorLength; i >= 0; i--) 
			{
				z = a[i];
				if (z > highestInt) highestInt = z;
			}
			
			return highestInt;
		}
	}
}