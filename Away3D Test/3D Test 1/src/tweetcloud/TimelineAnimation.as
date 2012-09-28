package tweetcloud  {
	
	import away3d.textures.BitmapTexture;
	import away3d.materials.TextureMaterial;
	import flash.display.*;
	import flash.geom.*;
	import away3d.tools.utils.TextureUtils;
	
		
	public class TimelineAnimation {

		public var material:TextureMaterial;
		private var mc:MovieClip;
		private var lastFrame:int = 1;
		
		public function TimelineAnimation(movie:MovieClip)
		{			
			mc = movie;
			var bmpData:BitmapData = getBitmapData( mc );
			material = new TextureMaterial(new BitmapTexture(bmpData));
			material.alphaBlending = true ;
		}
		
		public function playOn(aMeshes:Array):void
		{	
			if(lastFrame != mc.totalFrames)mc.gotoAndStop(mc.currentFrame + 1);
			else mc.gotoAndStop(1);
			lastFrame = mc.currentFrame;
			
			var bmpData:BitmapData = getBitmapData( mc );
			
			material.texture = new BitmapTexture(bmpData);
			material.alphaBlending = true ;
			
			for(var i:int = 0; i < aMeshes.length; i++){
					
				aMeshes[i].material = material;
			}
		}
		
		private function getBitmapData( clip:DisplayObject ):BitmapData
		{
			var bounds:Rectangle = clip.getBounds( clip );
			var bitmap:BitmapData = new BitmapData( int( bounds.width + 0.5 ), int( bounds.height + 0.5 ), true, 0);
			bitmap.draw( clip, new Matrix(1,0,0,1,-bounds.x,-bounds.y) );
			return autoResizeBitmapData(bitmap);
		}
		
		private function autoResizeBitmapData(bmData:BitmapData,smoothing:Boolean = true):BitmapData 
		{
			if (TextureUtils.isBitmapDataValid(bmData))
			return bmData;
			 
			var max:Number = Math.max(bmData.width, bmData.height);
			max = TextureUtils.getBestPowerOf2(max);
			var mat:Matrix = new Matrix();
			mat.scale(max/bmData.width, max/bmData.height);
			var bmd:BitmapData = new BitmapData(max, max, true, 0);
			bmd.draw(bmData, mat, null, null, null, smoothing);
			return bmd;
		}

	}
	
}
