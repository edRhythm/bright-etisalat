package rhythm.displayObjects
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;

	public class MessageInputScreens extends MovieClip 
	{
		private var faceBitmap:Bitmap;
		private var camBMD:BitmapData;
		private var faceMatrix:Matrix;
		private var photoScale:Number;
		
		//timeline
		public var messageBox:MovieClip;

		
		public function MessageInputScreens()
		{
			photoScale = 0.8;
			
			faceMatrix = new Matrix();
			faceMatrix.rotate( -90 * (Math.PI / 180 ) );
			faceMatrix.translate( 0, 512);
			faceMatrix.scale(photoScale,photoScale);
			
			camBMD = new BitmapData(512*photoScale,512*photoScale,true,0x000000);
			
			faceBitmap = new Bitmap(camBMD,"never",true);
			
			messageBox.addChild(faceBitmap);
			
			faceBitmap.x = faceBitmap.y = faceBitmap.width*-.5;
		}
		
		
		
		public function setCameraView(bmd:BitmapData):void
		{
			//trace("setCameraView");
			camBMD.draw(bmd, faceMatrix);
		}
		
		private function takePhoto():void
		{
			
		}
	}
}