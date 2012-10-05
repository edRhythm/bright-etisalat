package rhythm.utils
{
	public class Maths
	{
		public function Maths()
		{
		}
		
		public static function randomIntBetween($min:Number, $max:Number):int
		{
			var randomNum:int = Math.floor(Math.random()*($max - $min + 1)) + $min;			
			return randomNum;
		}
		
		
		public static function randomNumberBetween($min:Number, $max:Number, $decimelPlaces:int=2):Number
		{
			var randomNum:Number = Math.random()*($max - $min ) + $min;
			return randomNum//.toFixed($decimelPlaces);
		}
		
		public static function getUniqueName():String
		{
			var d:Date = new Date();
			return d.getMonth() + 1 + '' + d.getDate() + '' + d.getHours() + '' + d.getMinutes() + '' + d.getMilliseconds();
		}
	}
}