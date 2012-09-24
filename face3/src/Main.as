package
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.quasimondo.bitmapdata.CameraBitmap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import jp.maaash.ObjectDetection.ObjectDetector;
	import jp.maaash.ObjectDetection.ObjectDetectorEvent;
	import jp.maaash.ObjectDetection.ObjectDetectorOptions;
	
	[SWF(width="607", height="1080", frameRate="60", backgroundColor="#FFFFFF")]
	
	public class Main extends Sprite
	{
		
		private var detector    :ObjectDetector;
		private var options     :ObjectDetectorOptions;
		
		private var _camOutput :Sprite;
		private var faceRectContainer :Sprite;
		private var tf :TextField;
		
		private var cameraDetectionBitmap:CameraBitmap;
		private var detectionMap:BitmapData;
		private var drawMatrix:Matrix;
		private var scaleFactor:int = 8;
		private var w:int = 607;
		private var h:int = 1080;
		private var rectCentre:Point;
		
		private var _hud:HUD = new HUD();
		private var eyesRect:Sprite;
		private var _faceMask:Sprite;
		private var _faceRim:Sprite;
		
		public var debug:Boolean;
		
		
		public function Main() 
		{
			debug = false;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			setUpCam();
			initDetector();			
		}
		

		private function setUpCam():void
		{
			//cam harness
			_camOutput = new Sprite();
			_camOutput.y = 1080;
			_camOutput.rotation = -90;	
			
			TweenMax.to(_camOutput, 1, {colorMatrixFilter:{saturation:0, contrast:1.6}});
			
			addChild(_camOutput);
			
			//camera bitmap
			cameraDetectionBitmap = new CameraBitmap( h, w, 30, true );
			cameraDetectionBitmap.addEventListener( Event.RENDER, cameraReadyHandler );
			_camOutput.addChild( new Bitmap( cameraDetectionBitmap.bitmapData  ) );
			
			//detection bitmap
			detectionMap = new BitmapData( w / scaleFactor, h / scaleFactor, false, 0 );
			drawMatrix = new Matrix( 1/ scaleFactor, 0, 0, 1 / scaleFactor );
			drawMatrix.rotate( -90 * (Math.PI / 180 ) );
			drawMatrix.translate( 0, detectionMap.height );
				
			eyesRect = new Sprite();
			addChild( eyesRect );
			
			//mask
			_faceMask = new Sprite();
			var faceCircleShape:Sprite = new Sprite();
			faceCircleShape.graphics.beginFill(0x000000);
			faceCircleShape.graphics.drawEllipse(0,0,200,200);
			faceCircleShape.graphics.endFill();
			faceCircleShape.x = faceCircleShape.y = -100;
			_faceMask.addChild(faceCircleShape);
			
			_camOutput.mask = _faceMask;
			
			//facerim
			_faceRim = new Sprite();
			var faceRimShape:Sprite = new Sprite();
			faceRimShape.graphics.lineStyle(5,0xC6CE2C,1,true);
			faceRimShape.graphics.drawEllipse(0,0,200,200);
			faceRimShape.x = faceRimShape.y = -100;
			_faceRim.addChild(faceRimShape);
			
			addChild(_faceRim);
			
			//debug 
			if(debug)
			{
				faceRectContainer = new Sprite();
				addChild( faceRectContainer );			
			}
	
			
		}
		

		
		private function cameraReadyHandler( event:Event ):void
		{
			detectionMap.draw(cameraDetectionBitmap.bitmapData,drawMatrix,null,"normal",null,true);
			detector.detect( detectionMap );			
		}
		
		private function initDetector():void
		{
			detector = new ObjectDetector();
			
			var options:ObjectDetectorOptions = new ObjectDetectorOptions();
			options.min_size  = 30;

			detector.options = options;
			detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );
		}
		
		
		private function detectionHandler( e :ObjectDetectorEvent ):void
		{
			if(debug) 
			{
				var g :Graphics = faceRectContainer.graphics;
				g.clear();
			}

			
			if( e.rects.length>0 )
			{
				if(debug)  g.lineStyle( 2 );	// black 2pix

				e.rects.forEach( function( r :Rectangle, idx :int, arr :Array ) :void {
					
					rectCentre = new Point(r.x+(r.width*.5),r.y+(r.height*.5));
					

					
					TweenMax.allTo([_faceMask, _faceRim], .5, {x:rectCentre.x*scaleFactor, y:(rectCentre.y*scaleFactor)*.9,  ease:Sine.easeInOut});		
					TweenMax.to(_faceMask, .75, {width:(r.width* scaleFactor)+200, height:(r.width* scaleFactor)+200, ease:Sine.easeInOut});
					TweenMax.to( _faceRim, .75, {width:(r.width* scaleFactor)+205, height:(r.width* scaleFactor)+205, ease:Sine.easeInOut});
					
					TweenMax.to(_faceRim,.25,{removeTint:true});


					if(debug) 	g.drawRect( r.x * scaleFactor, r.y * scaleFactor, r.width * scaleFactor, r.height * scaleFactor );
		
				});	
			}else{
				TweenMax.to(_faceRim,.25,{tint:0x000000, scaleX:1, scaleY:1,ease:Sine.easeInOut});
				TweenMax.to(_faceMask,.25,{scaleX:1,scaleY:1, ease:Sine.easeInOut});

			}
		}
	}
}

