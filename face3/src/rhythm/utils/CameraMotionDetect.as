package rhythm.utils
{
	
	import com.quasimondo.bitmapdata.ThresholdBitmap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.getDefinitionByName;
	import flash.geom.Matrix;
	
	public class CameraMotionDetect extends Sprite
	{	
		// to store previous state
		private var oldData:BitmapData;
		
		// to store actual state
		private var newData:BitmapData;
		
		// stepping blocks
		private var blockSize:Number;
		
		// detection sensitivity
		private var sensitivity:Number;
		
		private var video:Video;
		
		private var thresholdMap:ThresholdBitmap;
		private var shrinkMatrix:Matrix;
		private var scaleFactor:Number;
		
		public function CameraMotionDetect ( argVideo:Video , argBlockSize:Number , argSensitivity:Number ){
		
			video = argVideo;
			blockSize = argBlockSize;
			sensitivity = argSensitivity;
			
			scaleFactor = 1;
					
			oldData = new BitmapData( video.width/scaleFactor , video.height/scaleFactor , false );
			newData = new BitmapData( video.width/scaleFactor , video.height/scaleFactor , false );       
			
			shrinkMatrix = new Matrix( 1/ scaleFactor, 0, 0, 1 / scaleFactor );

		}

	
		public function getDifferences( ):Vector.<Point>
		{			
			// capturing new state
			
			newData.draw( video, shrinkMatrix );
			//trace("newData width",newData.width);
			
			var differences:Vector.<Point> = new Vector.<Point>;
			
			// looping through points with stepping
			
			for ( var px:int = 0 ; px < newData.width ; px += blockSize )
			{
				
				for ( var py:int = 0 ; py < newData.height ; py += blockSize )
				{
					
					//getting previous and actual pixel color data
					
					var oldPixel:uint = oldData.getPixel( px , py );
					var newPixel:uint = newData.getPixel( px , py );
					

					// checking difference threshold			
					
					if ( Math.abs( newPixel - oldPixel ) > sensitivity )
					{						
						// if bigger than sensitivity, storing point	
						differences.push( new Point( px , py ) );				
					}			
				}		
			}
			
			// save previous state
			
			oldData.copyPixels( newData , newData.rect , new Point( 0 , 0 ) );
			
			return differences;
			
		}	
		
		
	}
}



