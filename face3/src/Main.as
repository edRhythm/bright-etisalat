package
{
	
	import com.adobe.protocols.dict.events.NoMatchEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.ImageLoader;
	import com.greensock.plugins.*;
	import com.quasimondo.bitmapdata.CameraBitmap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import jp.maaash.ObjectDetection.ObjectDetector;
	import jp.maaash.ObjectDetection.ObjectDetectorEvent;
	import jp.maaash.ObjectDetection.ObjectDetectorOptions;
	
	import net.hires.debug.Stats;
	
	import rhythm.displayObjects.MovieSaver;
	import rhythm.events.CustomEvent;
	import rhythm.utils.CameraMotionDetect;
	import rhythm.utils.DataIO;
	import rhythm.utils.Maths;
	import rhythm.utils.TimeOut;
	
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

		private var w:int = 540;
		private var h:int = 960;
		private var dw:int = 1080;
		private var dh:int = 1920;
		private var rectCentre:Point;
		private var dectAreaW:int=400;
		private var dectAreaH:int=650;
		
		private var camOutputMask:Sprite;
		private var _detected:Boolean;
		private var _motionDetector:CameraMotionDetect;
		
		public var debug:Boolean;
		private var _movingShapes:Sprite;
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
		
		private var tempFaceBMP:Bitmap;
		private var doing3dTransition:Boolean;
		
		private var inputMsg:MessageInput;
		private var inputMode:Boolean;
		private var timeOutDelay3d:Number;

		private var addBtn:AddBtn;
		private var dataIO:DataIO;
		private var config:XML;
		private var timeOut3d:TimeOut;
		private var headerFooterHarness:Sprite;
		
		private var faceSearchMessage:SearchingMessage;
		private var noActionSaver:MovieSaver;
		private var timeOutMotion:TimeOut;
		private var timeOutDelayMotion:Number;
		private var motionSSOn:Boolean;
		private var debugPanel:DebugPanel;

		
	
		public function Main() 
		{
			debug = true;
			_faceDetection = true;
			
			_trackMotion = true;
			
			TweenPlugin.activate([ShortRotationPlugin, TransformAroundPointPlugin, TransformAroundCenterPlugin,BezierPlugin]);
			
			stage.align = StageAlign.TOP_LEFT;
			
			var debugOnScreen:Boolean = true;
						
//			stage.nativeWindow.height = stage.fullScreenHeight;
//			stage.nativeWindow.width = stage.fullScreenHeight*0.5625;
			
			//onscreen debug output
			//config.debug.showOutput=="true" || 
			if(debugOnScreen)
			{
				debugPanel = new DebugPanel();
				debugPanel.y = 300;
				debugPanel.x = 50;
				debugPanel.update("Hello from"+this);
				debugPanel.alpha = .8;
				addChild(debugPanel);
			}

			dataIO = new DataIO();
			dataIO.addEventListener(CustomEvent.DEBUG_MESSAGE, showDebugMessage, false, 0, true);
			dataIO.addEventListener(CustomEvent.DATA_READY, onDataReady, false, 0, true);
			dataIO.getData();		
			
		}
		
		private function onDataReady(e:CustomEvent):void
		{
			dataIO.removeEventListener(CustomEvent.DATA_READY, onDataReady);

			config = dataIO.configXML;
			//trace("config",config);
			
			timeOutDelay3d = Number(config.timeOutDelay3d);
			timeOutDelayMotion = Number(config.timeOutDelayMotion);
			
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
			addChild(_camOutput);
					
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
			faceMatrix.translate( -256, 35);

			//face detected mask
			faceRect = new Rectangle(0, 0, 600,600);
			
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
			addChildAt(tweetCloud,0);
			tweetCloud.init(dataIO);
			tweetCloud.addEventListener(CustomEvent.SHOW_BANNER, onShow3dMessage, false, 0, true);
			tweetCloud.addEventListener(CustomEvent.CLOSE_3D_MESSAGE, onClose3dMessage, false, 0, true);

			
			faceFor3d = new BitmapData(1024,1024);
			
			//cam mask
			camOutputMask = new Sprite();
			camOutputMask.graphics.beginFill(0xFFFFFF,0.5);
			camOutputMask.graphics.drawCircle(0,0,h);
			camOutputMask.mouseEnabled=false;
			camOutputMask.x = w;
			camOutputMask.y = h;
			camOutputMask.visible=false;
			addChild(camOutputMask);
			
			//no motion saver
			noActionSaver = new MovieSaver();
			addChild(noActionSaver);
			
			//header footer
			var hf:BitmapData = new HeaderFooter();	
			var headerFooter:Bitmap = new Bitmap(hf);
			headerFooterHarness = new Sprite();
			headerFooterHarness.mouseEnabled = false;
			headerFooterHarness.addChild(headerFooter);
			addChild(headerFooterHarness);
			if(config.debug.showOutput=="true"  && debugPanel)headerFooterHarness.addChild(debugPanel);
			
			//qr code
			var file:File = File.desktopDirectory.resolvePath("kioskData");
			file= file.resolvePath("images/qrCode.png"); 
			dispatchEvent(new CustomEvent(CustomEvent.DEBUG_MESSAGE,true, false, {message:String('loading '+file.url +' does the file exist? ' +file.exists)}));

			var qrLoader:ImageLoader =  new ImageLoader(file.url, {name:"qrCode", container:headerFooterHarness,x:950, y:1800});
			qrLoader.load(true);
			
			//debug 
			faceRectContainer = new Sprite();
			addChild( faceRectContainer );	
			
			//face detection area on screen
			if(config.debug.showFaceDetectArea=="true")
			{
				var dectectionAreaSprite:Sprite = new Sprite();
				dectectionAreaSprite.graphics.lineStyle(1,0xFF0000);
				dectectionAreaSprite.graphics.drawRect(540-dectAreaW, 0, dectAreaW*2, dectAreaH*2);
				addChild(dectectionAreaSprite);
			}

			
			//input overlay
			inputMsg = new MessageInput();
			inputMsg.initWithConfig(config);
			addChildAt(inputMsg, getChildIndex(_camOutput)+1);	
			inputMsg.visible = false;
			
			//timeouts
			timeOut3d = new TimeOut(timeOutDelay3d, timeOutReached3d);
			timeOutMotion = new TimeOut(timeOutDelayMotion, timeOutReachedMotion);
			
			//stats
			if(config.debug.showStats=="true")
			{
				var stats:Stats = new Stats();
				stats.y = 200;
				addChild( stats);
			}
			
			
			
			//search message
			faceSearchMessage = new SearchingMessage();
			faceSearchMessage.searchTF.text = "Searching for people";
			faceSearchMessage.x = w;
			faceSearchMessage.y = 200;
			addChild(faceSearchMessage);
		}
		
		private function showDebugMessage(e:CustomEvent):void
		{
			trace("showDebugMessage");
			if(debugPanel) debugPanel.update(e.params.message);
	
		}		
		
		private function onClose3dMessage(event:Event):void
		{
			addBtn.visible = true;	
		}
		
		private function onShow3dMessage(event:Event):void
		{
			addBtn.visible = false;
		}					

		private function cameraReadyHandler( event:Event ):void
		{			
			//start face detection
			
			if(_faceDetection)
			{
				if(!bdata)
				{
					bdata = new BitmapData(w, h);
					faceBMD = new BitmapData(1024, 1024, true, 0xFF0000);
							
					if(debug)
					{
						var tbm:Bitmap = new Bitmap( detectionMap );
						tbm.scaleX = tbm.scaleY = scaleFactor; 
						tbm.x = 300;
						addChild( tbm );
					}
				}
								
				bdata.draw(cameraDetectionBitmap.bitmapData, dectMatrix);
				faceBMD.draw(_camHarness, faceMatrix);

				detectionMap.copyPixels(bdata, new Rectangle(scaledXOffset,0,scaledDectW,scaledDectH), new Point(0,0));

				detector.detect( detectionMap );	
				
				//send face to tweetcloud
				faceFor3d.lock();
				faceFor3d.fillRect(new Rectangle(0,0,faceFor3d.width, faceFor3d.height),0);

				if(faceRect)faceFor3d.copyPixels(faceBMD,new Rectangle(faceRect.x,40, 2000, 2000), new Point(0,0));
						
				faceFor3d.unlock();
				
				if(! inputMode)
				{
					tweetCloud.updateFace(faceFor3d);
				}else{
					inputMsg.setCameraView(faceFor3d)		
				}

			}else{
				detectMotionMode();
				trackMotion();
			}
		}
		
		
		
		private function show3d():void
		{
			
			faceSearchMessage.searchTF.text = "Face found!";

			detector.removeEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );

			//kill partigen
			while(particleHarness.numChildren>0) 
			{
				var p:ParticleCross = ParticleCross(particleHarness.getChildAt(0));
				TweenMax.killTweensOf(p);
				killParticle(ParticleCross(particleHarness.getChildAt(0)));
			}
			
			
			//mask transition
			_camOutput.mask = camOutputMask;
			TweenMax.to(camOutputMask,.5,{
	//			transformAroundPoint:{point:new Point(w, 340),height:512, width:512},
				transformAroundPoint:{point:new Point(w, 740),height:512, width:512},
				colorTransform:{brightness:2},
				ease:Sine.easeIn,
				onComplete:hideCamOutput});
			
			
			
			TweenMax.to(_camHarness,.5,{transformAroundCenter:{scaleX:.9, scaleY:.9}, ease:Sine.easeIn});	
			
			//start timeOut
			timeOut3d.start();
			stage.addEventListener(MouseEvent.MOUSE_DOWN, doResetTimeOut3d,false, 0,true);
			
			//kill motion timeout & ss
			timeOutMotion.cancel();
			noActionSaver.stopVideo();

		}
		
		private function hideCamOutput():void
		{
			//trace("hideCamOutput");
			
			faceSearchMessage.visible = false;

			if( !inputMode)	tweetCloud.resume3d();		

			
			_camOutput.visible=false;
			_camOutput.mask = null;
			camOutputMask.scaleX = camOutputMask.scaleY=1;	
			
			doing3dTransition = false;	
			
			overlay3d();
		}
		
		private function overlay3d():void
		{
			addBtn = new AddBtn();
			addBtn.x = 800;
			addBtn.y = 695;
			addBtn.alpha = 0;
			addBtn.addEventListener(MouseEvent.MOUSE_DOWN, doAddClick, false, 0, true);
			addChild(addBtn);
		}
		
		private function doAddClick(event:MouseEvent):void
		{
			inputMsg.visible = true;
			inputMsg.resetInput();
					
			addBtn.removeEventListener(MouseEvent.MOUSE_DOWN, doAddClick);
			if(addBtn.parent)removeChild(addBtn);

			tweetCloud.resetAllPlanes();
			
			inputMode = true;
			
			inputMsg.addEventListener(CustomEvent.INPUT_CANCELLED, closeInput,false,0,true);
			inputMsg.addEventListener(CustomEvent.INPUT_COMPLETE, closeInput,false,0,true);

		}
		
		private function closeInput(event:Event):void
		{
			inputMsg.removeEventListener(CustomEvent.INPUT_CANCELLED, closeInput);
			inputMsg.removeEventListener(CustomEvent.INPUT_COMPLETE, closeInput);
			
			inputMsg.visible = false;
			inputMode = false;
			
			overlay3d();
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
				
				
				if(!_detected && !doing3dTransition)
				{
					show3d();	
					doing3dTransition=true;
				}
				
				hideTracker();
				_trackMotion=false;
				_detected=true;
									
				var r:Rectangle = e.rects[0];
				rectCentre = new Point((r.x+(r.width*.5)),(r.y+(r.height*.5)));
					
				//define face rect position			
				if(r.y>12 && r.y<23) TweenMax.to(faceRect,.75,{x: (r.y*-scaleFactor)+350, y:r.x*scaleFactor});
					
				if(debug)
				{
					g.lineStyle( 2, 0xff6600 );	// red 2pix
					g.drawRect( faceRect.x,faceRect.y,faceRect.width,faceRect.height );
				}	
		
			}else{
				
				if(_detected) 
				{
					_detected = false;
					//TweenMax.delayedCall(faceTrackLostDelay,stopFaceTracking);				
				}else if(_trackMotion){
					
					//start motion tracking
					if(!_motionDetector) detectMotionMode();
										
					trackMotion();	
				}
				
				
			}
		}
		
		private function exit3d():void
		{
			trace("exit3d");
			//TweenMax.killDelayedCallsTo(stopFaceTracking);
			
			if(inputMode)
			{
				closeInput(null);
			}else{
				tweetCloud.pause3d();
			}
			
			if(addBtn.parent)
			{
				addBtn.removeEventListener(MouseEvent.MOUSE_DOWN, doAddClick);
				removeChild(addBtn);
				addBtn=null;
			}
			
			_camOutput.visible=true;
			
			_camOutput.mask = camOutputMask;
			camOutputMask.scaleX = camOutputMask.scaleY = 1;
			
			TweenMax.from(camOutputMask,.5,{
				transformAroundPoint:{point:new Point(w, 740),height:512, width:512},
				ease:Sine.easeIn,
				onComplete:quit3d});
			

			TweenMax.to(_camOutput,.5,{x:0 ,y:dh,  ease:Sine.easeIn});
				
			TweenMax.to(_camHarness,.5,{scaleX:1, scaleY:1, x:0, y:0, ease:Sine.easeInOut});	
				//, colorMatrixFilter:{saturation:1, contrast:1, brightness:1},
				
			detector.removeEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );				
		}
		
		private function quit3d():void
		{
			detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );
			_trackMotion=true;
			_camOutput.mask = null;
			
			timeOut3d.cancel();
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, doResetTimeOut3d);
			
			faceSearchMessage.visible = true;
			faceSearchMessage.searchTF.text = "Searching for faces";
			
			//start video saver timeout tracking
			timeOutMotion.reset();
		}
		
		
		private function trackMotion():void
		{
			if(!particleHarness) 
			{
				addChildAt(particleHarness = new Sprite(), this.getChildIndex(_camOutput)+1);
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
				//trace("found a body");
				TweenMax.allTo([trackerShape, bigCross, trackMessage], .75, {y:dh-(blobAreaScaled.x+blobAreaScaled.width-(blobAreaScaled.width*.05)),ease:Sine.easeInOut},0.25,fadeOutTracker);
				
				TweenMax.allTo([trackerShape, bigCross, trackMessage], .25, {x:blobAreaScaled.y+(blobAreaScaled.height/2), autoAlpha:1, ease:Sine.easeInOut},0.25);
			
				//clear saver
				if(motionSSOn)
				{
					motionSSOn=false;
					noActionSaver.stopVideo();
				}else{
					//reset saver timeout
					timeOutMotion.reset();
				}
				
				//change search message
				if(faceSearchMessage.searchTF.text != "Searching for faces") faceSearchMessage.searchTF.text = "Searching for faces";
				TweenMax.killDelayedCallsTo(showPeopleMessage);


			}else{
				
				if(faceSearchMessage.searchTF.text != "Searching for people") TweenMax.delayedCall(2, showPeopleMessage);
			}
		}
		
		private function showTracker():void
		{
			if(!trackerShape)
			{
				trackerShape = new TrackerRing();
			//	addChild(trackerShape);
				
				bigCross = new BigCross();
				addChild(bigCross);
				
				trackMessage = new MessageHarness();
				trackMessage.messageTF.text = config.text.motionTrackMessage;
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
		
		private function doResetTimeOut3d(event:MouseEvent):void
		{
			timeOut3d.reset();
		}
		
		
		private function timeOutReached3d():void
		{
			//trace("timeOut 3d!");
			exit3d();
			
		}
		
		
		private function timeOutReachedMotion():void
		{
			motionSSOn = true;

			noActionSaver.restartVideo();
			
			timeOutMotion.cancel();	
		}	
		
		
		
		private function doCamSelect(e:MouseEvent):void
		{		
			cameraDetectionBitmap.setCamera(e.target.id, h, w, 15, true);
			_camHarness = new Sprite();
			_camHarness.addChild(new Bitmap( cameraDetectionBitmap.bitmapData));
			_camOutput.addChild(_camHarness );
			removeChild(_infoPanel);			
		}	
		
		private function showPeopleMessage():void
		{
			if(faceSearchMessage.searchTF.text != "Searching for people") faceSearchMessage.searchTF.text = "Searching for people";

		}
	}
}

