package rhythm.utils
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.getDefinitionByName;
	import com.quasimondo.bitmapdata.ThresholdBitmap;
	
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
		
//		public function CameraMotionDetect ( videoBitmapData:BitmapData , argBlockSize:Number , argSensitivity:Number ){
		private var thresholdMap:ThresholdBitmap;
		public function CameraMotionDetect ( argVideo:Video , argBlockSize:Number , argSensitivity:Number ){
		
			//newData = oldData = videoBitmapData;
			video = argVideo;
			blockSize = argBlockSize;
			sensitivity = argSensitivity;
			
			trace("sensitivity",sensitivity);
			
			oldData = new BitmapData( video.width , video.height , false );
			newData = new BitmapData( video.width , video.height , false );            
			
		}

	
		public function getDifferences( ):Vector.<Point>
		{			
			// capturing new state
			
			newData.draw( video );
			
			
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
		
		public function detectPerson():Array
		{
			var rect:Rectangle = new Rectangle(0,0,0,0);
			var minRect:Rectangle = new Rectangle(0,0,20, 20);
			var minGap:int = 3;
			var rects:Array = [];
			
			var points:Vector.<Point> = getDifferences();
			var currentX:int;
			var currentY:int;
			var yPointsFound:int;
			var startY:int;
			
			for(var p:int = 0; p<points.length; p++)
			{
				 currentX = points[p].x;
				 currentY = points[p].y;
				 yPointsFound=1;
				
				for(var q:int = 0; q<points.length; q++)
				{
					if(yPointsFound==1)startY=currentY;
					
					if(points[q].x==currentX && (points[q].y - (minGap*yPointsFound)) <= currentY)
					{
						yPointsFound++;
					}else{
						break;
					}
				}
				
				if(yPointsFound>1 && (blockSize*yPointsFound)>minRect.height) 
				{
					rect = new Rectangle(currentX,startY,blockSize, blockSize*yPointsFound);
					//trace("rect.h", rect.height);
					trace("startY",startY);
					rects.push(rect);
				}
				
			}
			
			return rects;

		}
		
//		public function detectPerson():int//Vector.<int>
//		{
//			var rect:Rectangle;
//
//			var maxW:int = Math.ceil(newData.height/blockSize);
//			var maxH:int = Math.ceil(newData.width/blockSize);
//
//			var areaCols:Vector.<int> = new Vector.<int>(maxW);
//			
//			for(var q:int = 0; q<areaCols.length; q++)areaCols[q]=0;
//			
//			var points:Vector.<Point> = getDifferences();
//			
//			
//			for(var p:int = 0; p<areaCols.length; p+=blockSize)
//			{
//					
//				for (var i:int = 0; i<points.length; i++)
//				{
//					if(points[i].y == p) areaCols[p]++;
//				}
//			}
//			
////			areaCols.sort(16);
////			areaCols.reverse();
//			
//			
//			var busiestColIndex:int = areaCols.indexOf(ArrayUtils.findHighestIntInVector(areaCols));
//				
//			//trace("busiestColIndex",busiestColIndex);
//			//var topPoint:Point = points.indexOf(
//			
//			return busiestColIndex*blockSize;
//		}
	}
	
	
}



