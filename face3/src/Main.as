package
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.quasimondo.bitmapdata.CameraBitmap;
	import com.quasimondo.bitmapdata.ThresholdBitmap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
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
	
	import rhythm.utils.CameraMotionDetect;
	
	[SWF(width="607", height="1080", frameRate="60", backgroundColor="0xFF6600")]
	
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
		private var _detected:Boolean;
		private var _motionDetector:CameraMotionDetect;
		
		public var debug:Boolean;
		private var _movingShapes:Sprite;
		private var thresholdMap:ThresholdBitmap;
		private var motionAreas:BitmapData;

		private var blobAreaRect:Sprite;
		private var trackerShape:Sprite;

		
		
		public function Main() 
		{
			debug = false;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			setUpCam();
			//initDetector();	
		
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
			//_camOutput.addChild( new Bitmap( cameraDetectionBitmap.bitmapData  ) );
			
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
			
			//_camOutput.mask = _faceMask;
			
			//facerim
			_faceRim = new Sprite();
			var faceRimShape:Sprite = new Sprite();
			faceRimShape.graphics.lineStyle(5,0xC6CE2C,1,true);
			faceRimShape.graphics.drawEllipse(0,0,200,200);
			faceRimShape.x = faceRimShape.y = -100;
			_faceRim.addChild(faceRimShape);
			_faceRim.visible=false;
			
			
			addChild(_faceRim);
			
			//temp face centering
			_faceRim.x = _faceMask.x=300;
			_faceRim.y = _faceMask.y=500;
			
			//debug 
			if(debug)
			{
				faceRectContainer = new Sprite();
				addChild( faceRectContainer );			
			}	
		}
		
		
		
		private function cameraReadyHandler( event:Event ):void
		{
			//detectionMap.draw(cameraDetectionBitmap.bitmapData,drawMatrix,null,"normal",null,true);
			//detector.detect( detectionMap );	
			
			detectMotionMode();
			trackMotion();

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
				if(!_detected)
				{
					//turn off motion tracking
					_faceMask.visible = _faceRim.visible = true;
					_camOutput.mask = _faceMask;
					TweenMax.allTo([_faceRim, _faceMask],.5,{scaleX:3,scaleY:3,ease:Sine.easeIn});
				}
				
				
				_detected=true;
				
				if(debug)  g.lineStyle( 2 );	// black 2pix

				e.rects.forEach( function( r :Rectangle, idx :int, arr :Array ) :void {
					
					rectCentre = new Point(r.x+(r.width*.5),r.y+(r.height*.5));
					
					TweenMax.to(_camOutput,.75,{x:-((r.x)*scaleFactor)+150, y:-((r.y)*scaleFactor)+1500, ease:Sine.easeInOut});

					
				//	TweenMax.allTo([_faceMask, _faceRim], .5, {x:rectCentre.x*scaleFactor, y:(rectCentre.y*scaleFactor)*.9,  ease:Sine.easeInOut});		
					TweenMax.to(_faceMask, .75, {width:(r.width* scaleFactor)+200, height:(r.width* scaleFactor)+200, ease:Sine.easeInOut});
					TweenMax.to( _faceRim, .75, {width:(r.width* scaleFactor)+205, height:(r.width* scaleFactor)+205, ease:Sine.easeInOut});
					
					TweenMax.to(_faceRim,.25,{removeTint:true});

					if(debug) 	g.drawRect( r.x * scaleFactor, r.y * scaleFactor, r.width * scaleFactor, r.height * scaleFactor );
		
				});	
			}else{

				if(_detected)
				{
					TweenMax.allTo([_faceRim,_faceMask],.75,{tint:0x000000, scaleX:3, scaleY:3, ease:Back.easeIn, onComplete:eyeShrunk});	
					TweenMax.to(_camOutput,.75,{x:0 ,y:1080, ease:Sine.easeIn});
					
					detector.removeEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );

				}
				_detected = false;
				//trackMotion();

				//TweenMax.to(_faceMask,.25,{scaleX:.25,scaleY:.25, ease:Sine.easeInOut});
			}
		}
		
		private function eyeShrunk():void
		{
			trace("eyeShrunk");
			_faceRim.visible = _faceMask.visible = false;
			_camOutput.x=0;
			_camOutput.y = 1080;
			_camOutput.mask=null;
			
			detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );

		}
		
		private function trackMotionThreshold():void
		{

		}
		
		private function trackMotion():void
		{
			motionAreas.fillRect(motionAreas.rect, 0);
			motionAreas.draw(_movingShapes);


//			var detectedRects:Array = _motionDetector.detectPerson();
//			
//			if(detectedRects.length>0)
//			{
//				trace("detectedRects",detectedRects.length);
//				
//				_movingShapes.graphics.clear();
//				_movingShapes.graphics.lineStyle(1,0xFFFFFF);	
//
//				for each (var r:Rectangle in detectedRects)
//				{
//					trace("rect",r);
//					_movingShapes.graphics.drawRect(r.x,r.y,r.height,r.width);
//				}
//			}
			
			var movementAreas:Vector.<Point> = _motionDetector.getDifferences();
			_movingShapes.graphics.clear();

			for(var i:int = 0; i<movementAreas.length; i++)
			{
				var p:Point = movementAreas[i];
				_movingShapes.graphics.beginFill(0xFFFFFF);
				_movingShapes.graphics.drawRect(p.x,p.y,10,10);
			}
			
			thresholdMap.render();
			 
			var blobArea:Rectangle = thresholdMap.getColorBoundsRect(0xFFFFFF, 0xFFFFFF, true);

			trackShape(blobArea);
		}
		
		private function trackShape(blobArea:Rectangle):void
		{
			//trace("blobArea",blobArea);
			var blobMaxW:int = 800;
			var blobMinW:int = 100;
			var blobMaxH:int = 700;
			var blobMinH:int = 200;
			
			if(! blobAreaRect) 
			{
				blobAreaRect = new Sprite();
				blobAreaRect.scaleY = -1;
				blobAreaRect.y=1080;
				addChild(blobAreaRect);
				
				trackerShape = new Sprite();
				trackerShape.graphics.beginFill(0xFF0000);
				trackerShape.graphics.drawRect(0,0,100,100);
				addChild(trackerShape);

			}
			
			blobAreaRect.graphics.clear();
			blobAreaRect.graphics.lineStyle(1,0xFF0000);
			blobAreaRect.graphics.drawRect(blobArea.y,blobArea.x,blobArea.height, blobArea.width);
			
			if(blobArea.width>blobMinW && blobArea.width<blobMaxW && blobArea.height>blobMinH && blobArea.height<blobMaxH)
			{
				trackerShape.visible = true;
				trackerShape.y = 1080-(blobArea.x+blobArea.width+trackerShape.height);
				trackerShape.x = blobArea.y+(blobArea.height/2)-(trackerShape.height*.5);
			}else{
				trackerShape.visible = false;
			}
		}
		
//		private function trackMotion():void
//		{
//			var movementAreas:Vector.<Point>= new Vector.<Point>;
//			_motionDetector ?  movementAreas = _motionDetector.getDifferences() : detectMotionMode();
//			
////			var activeCols:Vector.<int> = new Vector.<int>;
////			_motionDetector ?  activeCols = _motionDetector.detectPerson() : detectMotionMode();
//
////			var busiestCol:int;
////			_motionDetector ?  busiestCol = _motionDetector.detectPerson() : detectMotionMode();
////			trace("busiestCol",busiestCol);
////			
//			_movingShapes.graphics.clear();
////			_movingShapes.graphics.lineStyle(5,0xFFFFFF,1,true,"normal","square");	
////			_movingShapes.graphics.moveTo(busiestCol, 0);
////			_movingShapes.graphics.lineTo(busiestCol,_camOutput.height);
////			
//			for(var i:int =0; i<movementAreas.length; i++)
//			{
//				var p:Point = movementAreas[i];
//				_movingShapes.graphics.beginFill(0xFFFFFF);
//				_movingShapes.graphics.drawRect(p.x,p.y,5,5);
//	//			_movingShapes.graphics.lineStyle(4000/i,0xFFFFFF,1,true,"normal","square");
////				_movingShapes.graphics.lineTo(p.x,p.y);
//			}
//			
//		}
		
		private function detectMotionMode():void
		{
			if(!_motionDetector){
				_motionDetector = new CameraMotionDetect(cameraDetectionBitmap.camVideo, 5, 2000000);
				
				_movingShapes = new Sprite();
//				_movingShapes.y = _camOutput.y;
//				_movingShapes.rotation = _camOutput.rotation;
//				_movingShapes.scaleY = -1;
//				_movingShapes.x = 608;
				//addChild(_movingShapes);
				
				motionAreas = new BitmapData(1080, 607, false, 0x000000);
				motionAreas.draw(_movingShapes);
				
				thresholdMap = new ThresholdBitmap( motionAreas);
				
				thresholdMap.smooth = 16;
				
				thresholdMap.adaptiveTolerance = 50;
				thresholdMap.thresholdValue = 100;
				thresholdMap.adaptiveRadius = 200;
				
				var tbm:Bitmap = new Bitmap( thresholdMap );
				_camOutput.addChild( tbm );
			}			
		}
	}
}

