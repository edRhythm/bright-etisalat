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
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.text.TextField;
	
	import jp.maaash.ObjectDetection.ObjectDetector;
	import jp.maaash.ObjectDetection.ObjectDetectorEvent;
	import jp.maaash.ObjectDetection.ObjectDetectorOptions;
	
	import net.hires.debug.Stats;
	
	import rhythm.utils.CameraMotionDetect;
	import rhythm.utils.events.CustomEvent;
	
	[SWF(width="1080", height="1920", frameRate="30", backgroundColor="0x444444")]

	public class Main extends Sprite
	{
		
		private var detector    :ObjectDetector;
		private var options     :ObjectDetectorOptions;
		
		private var _camOutput :Sprite;
		private var faceRectContainer :Sprite;
		private var tf :TextField;
		
		private var cameraDetectionBitmap:CameraBitmap;
		private var detectionMap:BitmapData;
		private var scaleFactor:int = 14;
		private var dScaleFactor:int = 56//32;

		private var w:int = 520;
		private var h:int = 960;
		private var dw:int = 1080;
		private var dh:int = 1920;
		private var rectCentre:Point;
		private var dectAreaW:int=400;
		private var dectAreaH:int=600;
		
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
		private var _infoPanel:Sprite;
		private var minMaxRect:Sprite;
		private var _faceDetection:Boolean;

		private var bdata:BitmapData;

		private var dectMatrix:Matrix;

		
		
		public function Main() 
		{
			debug = true;
			_faceDetection = true;
			
			stage.align = StageAlign.TOP_LEFT;
						
			stage.nativeWindow.height = stage.fullScreenHeight;
			stage.nativeWindow.width = stage.fullScreenHeight*0.5625;
			
			var stats:Stats = new Stats() 
			stats.scaleX = stats.scaleY = 2;
			addChild( stats);
			
			setUpCam();
			initDetector();		
		}
		
		
		private function setUpCam():void
		{
			//cam harness
			_camOutput = new Sprite();
			_camOutput.y = dh;
			_camOutput.rotation = -90;
			_camOutput.scaleX = _camOutput.scaleY = 2;
			TweenMax.to(_camOutput,0,{colorMatrixFilter:{saturation:0}});
		
			addChildAt(_camOutput,0);
			
			//camera bitmap
			cameraDetectionBitmap = new CameraBitmap();
			
			//bw filter (might speed things up doing it this way rather than tweenmax, but who knows?
			//cameraDetectionBitmap.colorMatrix = [0.37, 0.615, 0.08, 0, 0,0.37, 0.615, 0.08, 0, 0,0.37, 0.615, 0.08, 0, 0,0,    0,    0,    1, 0];
		
			
			showCameraInfo();
			cameraDetectionBitmap.addEventListener( Event.RENDER, cameraReadyHandler );
			
			//detection bitmap
			detectionMap = new BitmapData( dectAreaW/scaleFactor , dectAreaH/scaleFactor , false, 0 );
		
			dectMatrix = new Matrix( 1/scaleFactor, 0, 0, 1/scaleFactor  );
			dectMatrix.rotate( -90 * (Math.PI / 180 ) );
			dectMatrix.translate( 0, h/scaleFactor);

			
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
			_faceRim.x = _faceMask.x=w;
			_faceRim.y = _faceMask.y=h;
			
			//debug 
			faceRectContainer = new Sprite();
			addChild( faceRectContainer );			
			
		}
		
		private function showCameraInfo():void
		{
			
			var cams:Array = cameraDetectionBitmap.getCameras();
			
			_infoPanel = new Sprite();
			addChild(_infoPanel);
			
			var title:InfoPanel = new InfoPanel();
			title.infoTF.text = "Choose a camera";
			_infoPanel.addChild(title);
			
			for (var i:int =0; i< cams.length; i++)
			{
				var camButton:InfoPanel = new InfoPanel();
				camButton.id=i;
				camButton.infoTF.text= "Camera "+i+": "+cams[i];
				camButton.y = (i+1)*camButton.height+((i+1)*10);
				camButton.mouseChildren=false;
				camButton.addEventListener(MouseEvent.MOUSE_DOWN,doCamSelect);
				camButton.buttonMode=true;
				TweenMax.to(camButton.infoBG,0,{tint:0xBAED5D});
				
				_infoPanel.addChild(camButton);
			}		
			
			_infoPanel.x = stage.stageWidth*.5;
			_infoPanel.y = stage.stageHeight*.5;
			
			addChild(_infoPanel);
			
		}
		
		private function doCamSelect(e:MouseEvent):void
		{		
			cameraDetectionBitmap.setCamera(e.target.id, h, w, 30, true);
			_camOutput.addChild( new Bitmap( cameraDetectionBitmap.bitmapData));
			removeChild(_infoPanel);			
		}		

		
		
		
		private function cameraReadyHandler( event:Event ):void
		{			
			//start face detection
			
			if(_faceDetection)
			{
				if(!bdata)
				{
					bdata = new BitmapData(w, h);
				//	thresholdMap = new ThresholdBitmap( bdata);
					//thresholdMap.smooth = 2;
				}
								
				bdata.draw(cameraDetectionBitmap.bitmapData, dectMatrix);
//				thresholdMap.render();

			detectionMap.copyPixels(bdata, new Rectangle(75/scaleFactor,0,w/scaleFactor,h/scaleFactor), new Point(0,0));
			//	detectionMap.copyPixels(thresholdMap, new Rectangle(75/scaleFactor,0,w/scaleFactor,h/scaleFactor), new Point(0,0));

			
				if(debug)
				{
					var tbm:Bitmap = new Bitmap( detectionMap );
					tbm.scaleX = tbm.scaleY = scaleFactor; 
					tbm.x = 300;
					addChild( tbm );
				}

				detector.detect( detectionMap );	
			}else{
				detectMotionMode();
				trackMotion();
			}
		}
		
		private function initDetector():void
		{
			detector = new ObjectDetector();
			
			var options:ObjectDetectorOptions = new ObjectDetectorOptions();
			options.min_size  = 15;
			//options.scale_factor = .5;

			detector.options = options;
			
			detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );
		}
		
		
		private function detectionHandler( e :ObjectDetectorEvent ):void
		{
			faceRectContainer.visible = debug;

			var g :Graphics = faceRectContainer.graphics;
			g.clear();		
			
			if(e.rects.length>0)
			{
				if(!_detected)
				{
					//turn off motion tracking
					_faceMask.visible = _faceRim.visible = true;
					//_camOutput.mask = _faceMask;
					TweenMax.allTo([_faceRim, _faceMask],.5,{scaleX:3,scaleY:3,ease:Sine.easeIn});
					
					if(trackerShape)trackerShape.visible=false;
				}
				
				
				_detected=true;
				
				g.lineStyle( 2, 0xFF0000 );	// red 2pix

				e.rects.forEach( function( r :Rectangle, idx :int, arr :Array ) :void {
					
					rectCentre = new Point((r.x+(r.width*.5)),(r.y+(r.height*.5)));
					
					if(!debug)
					{
						TweenMax.to(_camOutput,.75,{x:(-(r.x*dScaleFactor)+300), ease:Sine.easeInOut});
						TweenMax.to(_camOutput,1.25,{ y:(-(r.y*dScaleFactor)+2700), ease:Sine.easeInOut});	
					}
					

					
				//	TweenMax.allTo([_faceMask, _faceRim], .5, {x:rectCentre.x*scaleFactor, y:(rectCentre.y*scaleFactor)*.9,  ease:Sine.easeInOut});		
					TweenMax.to(_faceMask, .75, {width:(r.width* scaleFactor)+400, height:(r.width* scaleFactor)+400, ease:Sine.easeInOut});
					TweenMax.to( _faceRim, .75, {width:(r.width* scaleFactor)+405, height:(r.width* scaleFactor)+405, ease:Sine.easeInOut});
					
					TweenMax.to(_faceRim,.25,{removeTint:true});

					g.drawRect( r.x * dScaleFactor, r.y * dScaleFactor, r.width * dScaleFactor, r.height * dScaleFactor );
		
				});	
			}else{

				if(_detected)
				{
					TweenMax.allTo([_faceRim,_faceMask],.75,{tint:0x000000, scaleX:3, scaleY:3, ease:Back.easeIn});	
					TweenMax.to(_camOutput,1,{x:0 ,y:dh, ease:Sine.easeIn, onComplete:eyeShrunk});
					
					detector.removeEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );
					
					_detected = false;

				}
				
				//start motion tracking

				if(!_motionDetector) detectMotionMode();
			
				if(trackerShape)trackerShape.visible=true;
				
				trackMotion();			
			}
		}
		
		private function eyeShrunk():void
		{
			trace("eyeShrunk");
			_faceRim.visible = _faceMask.visible = false;
			_camOutput.x = 0;
			_camOutput.y = dh;
			_camOutput.mask=null;
			
			detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );

		}
		
		
		private function trackMotion():void
		{
			var movementAreas:Vector.<Point> = _motionDetector.getDifferences();
				
			motionAreas.fillRect(motionAreas.rect, 0);

			for(var i:int = 0; i<movementAreas.length; i++)
			{
				var p:Point = movementAreas[i];
				motionAreas.fillRect(new Rectangle(p.x,w-p.y,10,10),0xFFFFFF);

			}		
			
		//	thresholdMap.render();
			 
//			var blobArea:Rectangle = thresholdMap.getColorBoundsRect(0xFFFFFF, 0xFFFFFF, true);
			var blobArea:Rectangle = motionAreas.getColorBoundsRect(0xFFFFFF, 0xFFFFFF, true);

			trackShape(blobArea);
		}
		
		private function trackShape(blobArea:Rectangle):void
		{			
			var blobMaxW:int = dh*.8;
			var blobMinW:int = dh*.5;
			var blobMaxH:int = dw*.65;
			var blobMinH:int = dw*.4;
			var blobAreaScaled:Rectangle = new Rectangle(blobArea.x*2, blobArea.y*2, blobArea.width*2, blobArea.height*2);
			
			if(debug){
				
				if(! minMaxRect){
					minMaxRect = new Sprite();
					addChild(minMaxRect);
				}
				
				minMaxRect.graphics.clear();
				minMaxRect.graphics.lineStyle(1,0xBAED5D);
				minMaxRect.graphics.drawRect(100,dh-blobMaxW-20,blobMaxH, blobMaxW);
				minMaxRect.graphics.drawRect(100,dh-blobMaxW-20,blobMinH, blobMinW);

				
				if(! blobAreaRect) 
				{
					blobAreaRect = new Sprite();
					blobAreaRect.scaleY = -1;
					blobAreaRect.y=dh;
					addChild(blobAreaRect);
				}
				blobAreaRect.graphics.clear();
				blobAreaRect.graphics.lineStyle(1,0xFF0000);
				blobAreaRect.graphics.drawRect(blobAreaScaled.y,blobAreaScaled.x,blobAreaScaled.height, blobAreaScaled.width);
			}
			
			if(blobAreaScaled.width>blobMinW && blobAreaScaled.width<blobMaxW && blobAreaScaled.height>blobMinH && blobAreaScaled.height<blobMaxH && blobAreaScaled.height<blobAreaScaled.width)
			{
				if(! trackerShape) 
				{
					trackerShape = new TrackerCross();
					addChild(trackerShape);
				}
				
				trackerShape.visible = true;
				trackerShape.alpha = 1;
				
				TweenMax.to(trackerShape, .5, {y:dh-(blobAreaScaled.x+blobAreaScaled.width-(blobAreaScaled.width*.12)),
					ease:Sine.easeInOut,
					onComplete:fadeOutTracker});
				
				TweenMax.to(trackerShape, .1, {x:blobAreaScaled.y+(blobAreaScaled.height/2), autoAlpha:1, ease:Sine.easeInOut});
				
			}
		}
		
		private function fadeOutTracker():void
		{
			TweenMax.to(trackerShape,.25,{delay:1,autoAlpha:0});
		}
		

		
		private function detectMotionMode():void
		{
			if(!_motionDetector){
				_motionDetector = new CameraMotionDetect(cameraDetectionBitmap.camVideo, 5, 3000000);

				motionAreas = new BitmapData(h, w, false, 0x000000);	
				
				//motionAreas.draw(motionAreas);
				

				if(debug)
				{
					var tbm:Bitmap = new Bitmap( motionAreas );

//					var tbm:Bitmap = new Bitmap( thresholdMap );
					tbm.alpha=.5;
					_camOutput.addChild( tbm );
				}
				
			}			
		}
	}
}

