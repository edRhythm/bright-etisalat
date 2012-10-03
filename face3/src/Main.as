package
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
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
	
	import rhythm.events.CustomEvent;
	import rhythm.utils.CameraMotionDetect;
	import rhythm.utils.Maths;
	
	import tweetcloud.TweetCloud;
	
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
		private var dScaleFactor:int = scaleFactor*2//32;

		private var w:int = 520;
		private var h:int = 960;
		private var dw:int = 1080;
		private var dh:int = 1920;
		private var rectCentre:Point;
		private var dectAreaW:int=400;
		private var dectAreaH:int=650;
		
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
		private var bigCross:BigCross;
		private var _infoPanel:Sprite;
		private var minMaxRect:Sprite;
		private var _faceDetection:Boolean;

		private var bdata:BitmapData;
		private var dectMatrix:Matrix;
		private var scaledXOffset:Number;
		private var scaledDectW:Number;

		private var scaledDectH:Number;
		private var _camHarness:Sprite;
		private var _trackMotion:Boolean;

		private var blobMaxW:int;
		private var blobMinW:int;
		private var blobMaxH:int;
		private var blobMinH:int;
		private var blobAreaScaled:Rectangle;

		private var roughEase:RoughEase;
		private var particleHarness:Sprite;

		private var particleTints:Array;
		private var trackMessage:MessageHarness;

		private var tweetCloud:TweetCloud;

		private var faceFor3d:BitmapData;
		private var faceRect:Rectangle;

		private var faceBMD:BitmapData;
		private var faceMatrix:Matrix;

		
		
		public function Main() 
		{
			//debug = true;
			_faceDetection = true;
			
			_trackMotion = true;
			
			TweenPlugin.activate([ShortRotationPlugin, TransformAroundPointPlugin, TransformAroundCenterPlugin,BezierPlugin]);
			
			stage.align = StageAlign.TOP_LEFT;
						
			stage.nativeWindow.height = stage.fullScreenHeight;
			stage.nativeWindow.width = stage.fullScreenHeight*0.5625;
			
			var stats:Stats = new Stats();
			stats.y = 50;
			//stats.scaleX = stats.scaleY = 2;
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
			//_camOutput.alpha = .2;
			addChildAt(_camOutput,0);
			
			//camera bitmap
			cameraDetectionBitmap = new CameraBitmap();
			
			//select camera			
			showCameraInfo();
			cameraDetectionBitmap.addEventListener( Event.RENDER, cameraReadyHandler );
			
			//detection bitmap
			detectionMap = new BitmapData( dectAreaW/scaleFactor , dectAreaH/scaleFactor , false, 0 );
		
			scaledXOffset = 75/scaleFactor;
			scaledDectW = w/scaleFactor;
			scaledDectH = h/scaleFactor;
			
			dectMatrix = new Matrix( 1/scaleFactor, 0, 0, 1/scaleFactor  );
			dectMatrix.rotate( -90 * (Math.PI / 180 ) );
			dectMatrix.translate( 0, h/scaleFactor);
			
			faceMatrix= new Matrix( 1, 0, 0, 1  );
		//	faceMatrix.rotate( -90 * (Math.PI / 180 ) );
			faceMatrix.translate( -256, 0);


//			//face detected mask
			faceRect = new Rectangle(0, 0, 512,512);


			//motion tracking area
			blobMaxW = dh*.8;
			blobMinW = dh*.5;
			blobMaxH = dw*.65;
			blobMinH = dw*.3;
			
			showTracker();
			hideTracker();
			
			//particle ease
			roughEase = new RoughEase(3, 10, false, Sine.easeIn, "none", true, "superRoughEase");
			particleTints = [0x9dc880, 0x81c1e0, 0x2b3c46,0xec82ba,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF];

			//3d
			tweetCloud = new TweetCloud();
			tweetCloud.init();
			faceFor3d = new BitmapData(512,512);

			
			//debug 
			faceRectContainer = new Sprite();
			addChild( faceRectContainer );	
						
		}
		

		private function cameraReadyHandler( event:Event ):void
		{			
			//start face detection
			
			if(_faceDetection)
			{
				if(!bdata)
				{
					bdata = new BitmapData(w, h);
					faceBMD = new BitmapData(h, h, true, 0xFF0000);
							
					if(debug)
					{
						var tbm:Bitmap = new Bitmap( detectionMap );
						tbm.scaleX = tbm.scaleY = scaleFactor; 
						tbm.x = 300;
						addChild( tbm );
						
						//face detection area on screen
						var dectectionAreaSprite:Sprite = new Sprite();
						dectectionAreaSprite.graphics.lineStyle(1,0xFFFFFF);
						dectectionAreaSprite.graphics.drawRect(540-dectAreaW, 0, dectAreaW*2, dectAreaH*2);
						addChild(dectectionAreaSprite);
					}
				}
								
				bdata.draw(cameraDetectionBitmap.bitmapData, dectMatrix);
				faceBMD.draw(_camHarness, faceMatrix);

				detectionMap.copyPixels(bdata, new Rectangle(scaledXOffset,0,scaledDectW,scaledDectH), new Point(0,0));

				detector.detect( detectionMap );	
				
				//send face to tweetcloud
				faceFor3d.lock();
				faceFor3d.fillRect(new Rectangle(0,0,faceFor3d.width, faceFor3d.height),0);

				if(faceRect)faceFor3d.copyPixels(faceBMD,faceRect, new Point(0,0));
				faceFor3d.unlock();
				
				tweetCloud.updateFace(faceFor3d);

			}else{
				detectMotionMode();
				trackMotion();
			}
		}
		
		private function initDetector():void
		{
			detector = new ObjectDetector();
			
			var options:ObjectDetectorOptions = new ObjectDetectorOptions();
			options.min_size  = 10;

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
					//start 3d 
					tweetCloud.resume3d();			
					if(tweetCloud.parent == null)addChild(tweetCloud);
					_camOutput.visible=false;
					
					//stop calls to stopTracking
					TweenMax.killDelayedCallsTo(stopFaceTracking);
					
					//turn off motion tracking
				//	_faceMask.visible = _faceRim.visible = true;
				//	_camOutput.mask = _faceMask;
					//TweenMax.to(_faceRim,.5,{scaleX:3,scaleY:3,ease:Sine.easeIn});
					
					//shrink video and make b&w
					//TweenMax.to(_camHarness,.1,{transformAroundCenter:{scaleX:0.7, scaleY:0.7}});
					
					TweenMax.to(_camHarness,3,{colorMatrixFilter:{saturation:0.3, contrast:1.6, brightness:1.2}, ease:Sine.easeInOut});
					
				//	TweenMax.to( _faceRim, .75, {width:605, height:605, ease:Sine.easeInOut});
				}
				
				hideTracker();
				_trackMotion=false;
				_detected=true;
				
				g.lineStyle( 2, 0xff6600 );	// red 2pix

				e.rects.forEach( function( r :Rectangle, idx :int, arr :Array ) :void {
					
					rectCentre = new Point((r.x+(r.width*.5)),(r.y+(r.height*.5)));
					
//					faceRect = new Rectangle((r.y*-scaleFactor)+256, (r.x*scaleFactor), 512,512);

					TweenMax.to(faceRect,.75,{x: (r.y*-scaleFactor)+256, y:r.x*scaleFactor});
					
					//TweenMax.to(_camOutput,.75,{ y:(dh-(r.y*dScaleFactor))+(_faceRim.y*.7), ease:Sine.easeInOut});	
					
					if(debug)
					{
//						g.drawRect( r.x * dScaleFactor, dh-(r.y*dScaleFactor), r.width * dScaleFactor, r.height * dScaleFactor );
						g.drawRect( faceRect.x,faceRect.y,faceRect.width,faceRect.height );

					}	
					
				//	TweenMax.to(_faceRim,.25,{removeTint:true});
					

				});	
			}else{
				
				if(_detected) 
				{
					_detected = false;
					TweenMax.delayedCall(5,stopFaceTracking);				
				}else if(_trackMotion){
					
					//start motion tracking
					if(!_motionDetector) detectMotionMode();
										
					trackMotion();	
				}
				
				
			}
		}
		
		private function stopFaceTracking():void
		{
			tweetCloud.pause3d();
			_camOutput.visible=true;
			//tweetCloud.remove3d();

			//TweenMax.to(_faceRim,.5,{tint:0x000000, scaleX:3, scaleY:3, ease:Back.easeIn});	
			TweenMax.to(_camOutput,.5,{x:0 ,y:dh,  ease:Sine.easeIn, onComplete:eyeShrunk});
				
			TweenMax.to(_camHarness,.5,{scaleX:1, scaleY:1, x:0, y:0, 
				colorMatrixFilter:{saturation:1, contrast:1, brightness:1}, ease:Sine.easeInOut});	
				
				
			detector.removeEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );
			
			_trackMotion=true;
				
		}
		
		private function eyeShrunk():void
		{
			//_faceRim.visible = _faceMask.visible = false;
			//_camOutput.x = 0;
			//_camOutput.y = dh;
			//_camOutput.mask=null;
			
			detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );
		}
		
		
		private function trackMotion():void
		{
			if(!particleHarness) 
			{
				addChild(particleHarness = new Sprite());
				particleHarness.rotation=90;
				particleHarness.y =  dh;
				particleHarness.scaleX=-1;
				particleHarness.scaleY=-1;
			}
			
			var movementAreas:Vector.<Point> = _motionDetector.getDifferences();
				
			//clear bitmapdata
			motionAreas.lock();
			motionAreas.fillRect(motionAreas.rect, 0);

			for(var i:int = 0; i<movementAreas.length; i++)
			{
				var p:Point = movementAreas[i];
				motionAreas.fillRect(new Rectangle(p.x,w-p.y,10,10),0xFFFFFF);

				//partigen
				var pXPos:int = p.x*2
				var pYPos:int = dw-(p.y)*2;

				if(particleHarness.numChildren < 200)
				{
					var particle:ParticleCross = new ParticleCross();

					particle.scaleX = particle.scaleY=Maths.randomIntBetween(5,20)/10;
					particle.alpha=0;
					TweenMax.to(particle,0,{x:pXPos, y:pYPos, tint:particleTints[Maths.randomIntBetween(0,particleTints.length-1)]});
					
					var xTo:int = Maths.randomIntBetween(-250,250);
					var yTo:int = Maths.randomIntBetween(-250,250);
					particleHarness.addChild(particle);

					TweenMax.to(particle,Maths.randomIntBetween(10,100)*.01,{x:String(xTo),y:String(yTo),alpha:1,  ease:roughEase, onComplete:killParticle, onCompleteParams:[particle]});
				}

			}	
			
			motionAreas.unlock();
			
			var blobArea:Rectangle = motionAreas.getColorBoundsRect(0xFFFFFF, 0xFFFFFF, true);

			trackShape(blobArea);
		}
			
		private function killParticle(particle:ParticleCross):void
		{
			particleHarness.removeChild(particle);
			particle = null;
			
		}
		
		
			
		private function trackShape(blobArea:Rectangle):void
		{			
			blobAreaScaled = new Rectangle(blobArea.x*2, blobArea.y*2, blobArea.width*2, blobArea.height*2);
			
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
				TweenMax.allTo([trackerShape, bigCross, trackMessage], .75, {y:dh-(blobAreaScaled.x+blobAreaScaled.width-(blobAreaScaled.width*.05)),ease:Sine.easeInOut},0.25,fadeOutTracker);
				
				TweenMax.allTo([trackerShape, bigCross, trackMessage], .25, {x:blobAreaScaled.y+(blobAreaScaled.height/2), autoAlpha:1, ease:Sine.easeInOut},0.25);
			}
		}
		
		private function showTracker():void
		{
			if(!trackerShape)
			{
				trackerShape = new TrackerCross();
				addChild(trackerShape);
				
				bigCross = new BigCross();
				addChild(bigCross);
				
				trackMessage = new MessageHarness();
				addChild(trackMessage);

			}
			
			trackerShape.visible = bigCross.visible = trackMessage.visible = true;

		}
		
		private function fadeOutTracker():void
		{
			//trace("fadeOutTracker");
			TweenMax.allTo([trackerShape, bigCross, trackMessage],.25,{delay:1,alpha:0},0.12,hideTracker);
		}
		
		private function hideTracker():void
		{
			trackerShape.visible = bigCross.visible = trackMessage.visible = false;
		}
		

		
		private function detectMotionMode():void
		{
			if(!_motionDetector){
				_motionDetector = new CameraMotionDetect(cameraDetectionBitmap.camVideo, 5, 1000000);

				motionAreas = new BitmapData(h, w, false, 0x000000);	
								

				if(debug)
				{
					var tbm:Bitmap = new Bitmap( motionAreas );
					tbm.alpha=.5;
					_camOutput.addChild( tbm );
				}
				
			}			
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
			cameraDetectionBitmap.setCamera(e.target.id, h, w, 15, true);
			_camHarness = new Sprite();
			_camHarness.addChild(new Bitmap( cameraDetectionBitmap.bitmapData));
			_camOutput.addChild(_camHarness );
			removeChild(_infoPanel);			
		}		
	}
}

