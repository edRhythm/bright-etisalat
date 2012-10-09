package rhythm.displayObjects
{
	import com.adobe.images.JPGEncoder;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	import rhythm.events.CustomEvent;
	import rhythm.text.TFCreator;
	import rhythm.text.TFormats;
	import rhythm.utils.Maths;
	import flash.geom.Point;

	public class MessageInputScreens extends MovieClip 
	{
		//timeline
		public var cancelBtn:SimpleButton;
		public var nextBtn:SimpleButton;
		public var retakeBtn:SimpleButton;
		public var cameraBtn:SimpleButton;
		public var messageBox:MovieClip;
		public var titleTF:TextField;
		public var finishBtn:SimpleButton;
		public var progressDisplay:MovieClip;
		
		private var faceBitmap:Bitmap;
		private var camBMD:BitmapData;
		private var faceMatrix:Matrix;
		private var photoScale:Number;
		private var greenRim:GreenPhotoRim;
		private var neoTechFont:NeoTechFont;
		private var countdownTF:TextField;
		private var faceHarness:Sprite;
		private var encoder:JPGEncoder;	
		private var photoBytes:ByteArray;
		private var countDownNum:int;
		private var photoTaken:Boolean;
		private var countdownBG:Sprite;
		private var stageNum:int;
		private var tFormat:TextFormat;
		private var interestsInput:InterestsInput;
		private var userXML:XML;
		private var keyboard:PopUpKeyboard;
		private var currentNameString:String;
		private var nameInput:String;
		private var twitterInput:String;
		private var namesInput:NamesInput;
		private var currentNameTF:TextField;
		private var config:XML;
		private var rimMask:BitmapData;

		
		
		public function MessageInputScreens()
		{			
			
		}
		
		public function initWithConfig(configXML:XML):void
		{
			config = configXML;
			
			neoTechFont = new NeoTechFont();
			tFormat = TFormats.getTFormatToSize(50, neoTechFont,0x293C44, "center");	
							
			//photo stuff
			photoScale = 0.8;
			rimMask = new RimMaskSmall();

			
			faceMatrix = new Matrix();
			faceMatrix.rotate( -90 * (Math.PI / 180 ) );
			faceMatrix.translate( 0, 512);
			faceMatrix.scale(photoScale,photoScale);
			
			camBMD = new BitmapData(512*photoScale,512*photoScale,true,0x000000);
			
			
			faceBitmap = new Bitmap(camBMD,"never",true);
			faceHarness = new Sprite();
			faceHarness.addChild(faceBitmap);
			
			messageBox.addChild(faceHarness);
			
			//rim
			greenRim = new GreenPhotoRim();
			messageBox.addChild(greenRim);
			
			countdownTF = TFCreator.createTextField(60,60,false,false,true,"center",tFormat);
			countdownTF.text = "0";

			countdownBG = new Sprite();
			countdownBG.graphics.lineStyle(10,0xADEA49);
			countdownBG.graphics.beginFill(0xFFFFFF);
			countdownBG.graphics.drawCircle(0,0,40);
			countdownBG.visible = false;
			greenRim.addChild(countdownBG);
			greenRim.addChild(countdownTF);			

			
			countdownTF.x =  (countdownTF.width*-.5);
			countdownTF.y =  -255;
			countdownBG.y = -220;

			
			resetInput();
		}
		
		public function resetInput():void
		{
			userXML = <user moderated="false"><username></username><twitter></twitter><photo></photo><interests></interests></user>

			photoTaken=false;
			
			progressDisplay.gotoAndStop(1);	
			
			gotoAndStop("photo");
			
			finishBtn.visible = false;
			
			if(interestsInput && interestsInput.parent)messageBox.removeChild(interestsInput);
			if(keyboard && keyboard.parent) removeChild(keyboard);

			if(namesInput && namesInput.parent)messageBox.removeChild(namesInput);

			TweenMax.allTo([greenRim, faceHarness], 0,{x:0});

			
			stageNum=1;
			setUpStage1();
		}
		
		
		private function setUpStage1():void
		{
			titleTF.text = "Your Photo";	
			
			cameraBtn.visible = true;
		
			countdownTF.alpha=.1;			
			countdownTF.text = "";
					
			faceBitmap.x = faceBitmap.y =  faceBitmap.width*-.5;
			
			//buttons
			nextBtn.visible = false;
			retakeBtn.visible = false;
			
			cancelBtn.addEventListener(MouseEvent.MOUSE_DOWN, doCancelClick,false,0,true);
			cameraBtn.addEventListener(MouseEvent.MOUSE_DOWN, shutterClicked,false,0,true);
			
			this.y=0;
			TweenMax.from(this,.5,{y:-1920,ease:Sine.easeOut});

		}
		
		
		
		public function setCameraView(bmd:BitmapData):void
		{
			//if(!photoTaken) camBMD.draw(bmd, faceMatrix);
			if(!photoTaken) camBMD.copyPixels(bmd,new Rectangle(0,0, bmd.width, bmd.height), new Point(0,0), rimMask);

		}
		
		private function shutterClicked(e:Event):void
		{
			countDownNum = 3;
			countdownTF.text=String(countDownNum);
			countdownTF.alpha=0;
			TweenMax.to(countdownTF,.75,{alpha:1,ease:Sine.easeOut, repeat:3, onRepeat:updateCountdown});
			countdownBG.visible = true;

			cameraBtn.removeEventListener(MouseEvent.MOUSE_DOWN, shutterClicked);

		}
		
		private function updateCountdown():void
		{
			
			countDownNum --;
			countdownTF.alpha = 0;
			
			if(countDownNum == 0 )
			{
				countdownTF.text="";

				takePhoto();
			}else{
				countdownTF.text = String(countDownNum);
			}
				
		}
		
		private function takePhoto():void
		{
			photoTaken = true;
			countdownBG.visible = false;
			
			
				TweenMax.to(faceHarness,.25,{delay:1, alpha:0, repeat:1, yoyo:true, repeatDelay:.5});
				TweenMax.to(greenRim,.25,{delay:1,scaleX:0.2, scaleY:.2, ease:Sine.easeIn, repeat:1, yoyo:true, onComplete:showLastPhoto});

		}
		
		private function showLastPhoto():void
		{
			TweenMax.to(cameraBtn,.5,{colorTransform:{tint:0x7F7F7F, tintAmount:0.5}});

			nextBtn.visible = true;
			retakeBtn.visible = true;
			
			nextBtn.addEventListener(MouseEvent.MOUSE_DOWN, doNextClick,false,0,true);
			finishBtn.addEventListener(MouseEvent.MOUSE_DOWN, doNextClick,false,0,true);
			retakeBtn.addEventListener(MouseEvent.MOUSE_DOWN, retakePhoto,false,0,true);
			
			TweenMax.allFrom([nextBtn, retakeBtn],.5,{scaleX:0,scaleY:0, ease:Bounce.easeOut},0.25);
			// TODO Auto Generated method stub
		}
		
		private function doNextClick(e:MouseEvent):void
		{			
			progressDisplay.gotoAndStop(stageNum+1);


			switch(stageNum)
			{
				case 1:					
										
					stage2();
	
				break;
				case 2:
					
					//save interests to XML
					for each (var int:String in interestsInput.userInterests)
					{
						userXML.interests.appendChild(XML("<interest>"+int+"</interest>"));
					}

					finishBtn.visible = true;
					nextBtn.visible = false;
					

					stage3();

				break;
				case 3:
					nameInput = namesInput.nameTF.text;
					twitterInput = namesInput.twitterTF.text;
					
					messageBox.removeChild(namesInput);
					removeChild(keyboard);
					finish();
					break;
			}
			
			stageNum ++;

		}
		
		
		private function stage2():void
		{
			titleTF.text = "Your Interests";
			
			interestsInput = new InterestsInput(["Sport","Travel","Entertainment","Social", "Music","Business"]);
			messageBox.addChild(interestsInput);
			interestsInput.x = 85;
			interestsInput.y = (interestsInput.height*-.6)
			TweenMax.allTo([greenRim, faceHarness], 1,{x:"-220",ease:Sine.easeInOut});
			
			//hide buttons
			TweenMax.to(cameraBtn,0,{colorTransform:{tint:0x7F7F7F, tintAmount:0}, visible:false});
			retakeBtn.visible = false;
			
		}
		
		private function stage3():void
		{
			titleTF.text = "Your Name";
			
			//interestsInput.visible = false;
			messageBox.removeChild(interestsInput);
			
			currentNameString = nameInput;
			
			keyboard = new PopUpKeyboard();
			keyboard.y = 1150;
			keyboard.x = 50;
			addChild(keyboard);
			keyboard.addEventListener(CustomEvent.KEY_PRESSED,keyPressed, false, 0, true);
			
			namesInput = new NamesInput();
			namesInput.x = 40;
			messageBox.addChild(namesInput);
			
			currentNameTF =namesInput.nameTF;
			stage.focus = currentNameTF;
	
			namesInput.nameTF.addEventListener(FocusEvent.FOCUS_IN, setNameTF,false,0,true);
			namesInput.twitterTF.addEventListener(FocusEvent.FOCUS_IN, setNameTF,false,0,true);
	
		}
		
		private function setNameTF(event:FocusEvent):void
		{

			currentNameTF = TextField(event.target);
		}
		
		private function finish():void
		{			
			gotoAndStop("added");
			titleTF.text = "Complete";
			
			TweenMax.allTo([faceHarness, greenRim],.5,{x:0,ease:Sine.easeInOut});
						
			//save final photo
			var photoName:String = Maths.getUniqueName();			
			
			var fileRef:FileReference = new FileReference();
			
			encoder = new JPGEncoder(90);
			photoBytes = encoder.encode(camBMD);
			
			//insert path from config
			var picDirectoryName:String = "kiosk"+String(config.kiosk.@id);
			var file:File = File.desktopDirectory.resolvePath("kioskData/images/"+picDirectoryName);
			file= file.resolvePath(photoName+".jpg"); 
	
			var picPath:String = picDirectoryName+"/"+photoName+".jpg";
			var fs:FileStream = new FileStream();
			
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(photoBytes);
			fs.close();	
			
			//add to xml
			userXML.photo = picPath;
			userXML.username = nameInput;
			userXML.twitter = twitterInput
			
			//save xml
			var xmlFile:File = File.desktopDirectory.resolvePath("kioskData/localXML");
			xmlFile= xmlFile.resolvePath("kiosk"+String(config.kiosk.@id)+".xml"); 
		//	trace("xmlFile",xmlFile.url);
			
			fs.open(xmlFile,FileMode.READ);
			var loadedXML:XML = XML(fs.readUTFBytes(fs.bytesAvailable));
			fs.close();	
			
			loadedXML.users+=userXML;
			
			//trace("loadedXML",loadedXML);
			
			
			fs.open(xmlFile,FileMode.WRITE);
			fs.writeUTFBytes(loadedXML);
			fs.close();	
			
			trace("saved xml",userXML);
			
			//tween offstage
			TweenMax.to(this,.5,{delay:4,y:-1920,ease:Sine.easeIn, onComplete:finished});

		}
		
		private function finished():void
		{
			trace("finished");
			dispatchEvent(new CustomEvent(CustomEvent.INPUT_COMPLETE));			
		}		
		
		
		private function keyPressed(event:CustomEvent):void
		{
			//	trace("keyPressed up there",event.params.keyPressed);	
			var pressed:String = event.params.keyPressed;
			
			switch(pressed)
			{
				case "shift":
					keyboard.currentCase == "lower"	? keyboard.setUppercase() : keyboard.setLowercase();
					break;
				case "del":
					var currentStr:String = currentNameTF.text 
					currentNameTF.text = currentStr.substring(-1,currentStr.length-1);
					break;
				case "space":
					currentNameTF.appendText(" ");
					break;
				default:
					currentNameTF.appendText(pressed);
					break;
			}			
		}
		
		private function retakePhoto(e:MouseEvent):void
		{
			photoTaken=false;
			countdownBG.visible=true;
			retakeBtn.visible = false;
			cameraBtn.addEventListener(MouseEvent.MOUSE_DOWN, shutterClicked,false,0,true);
			TweenMax.to(cameraBtn,.5,{colorTransform:{tint:0x7F7F7F, tintAmount:0}});
			countdownBG.visible = false;

		}
		
		private function doCancelClick(event:MouseEvent):void
		{
			photoTaken=false;
			
			TweenMax.killTweensOf(countdownTF);
			dispatchEvent(new CustomEvent(CustomEvent.INPUT_CANCELLED));
			
		}
	}
}