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
	import flash.net.FileReference;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	import rhythm.events.CustomEvent;
	import rhythm.text.TFCreator;
	import rhythm.text.TFormats;
	import rhythm.utils.Maths;

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

		
		
		public function MessageInputScreens()
		{
			trace("FUCK");
			neoTechFont = new NeoTechFont();
			tFormat = TFormats.getTFormatToSize(50, neoTechFont,0x293C44, "center");	
			
			userXML = <user><username></username><twitter></twitter><photo></photo><interests></interests></user>
					
			stageNum=1;
			setUpStage1();
			progressDisplay.gotoAndStop(1);	
		}
		
		
		
		private function setUpStage1():void
		{
			titleTF.text = "Your Photo";
			
			finishBtn.visible = false;		
			
			photoScale = 0.8;
			
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
			countdownTF.alpha=.1;
			
			countdownBG = new Sprite();
			countdownBG.graphics.beginFill(0xFFFFFF);
			countdownBG.graphics.drawCircle(0,0,40);
			countdownBG.visible = false;
			greenRim.addChild(countdownBG);
			
			
			countdownTF.x =  (countdownTF.width*-.5);
			countdownTF.y =  440// messageBox.height*.45//(countdownTF.height*-.5);
			countdownBG.y = 470// messageBox.height*.50
			countdownTF.text = "";
			
			greenRim.addChild(countdownTF);
			
			
			faceBitmap.x = faceBitmap.y =  faceBitmap.width*-.5;
			
			//buttons
			nextBtn.visible = false;
			retakeBtn.visible = false;
			
			cancelBtn.addEventListener(MouseEvent.MOUSE_DOWN, doCancelClick,false,0,true);
			cameraBtn.addEventListener(MouseEvent.MOUSE_DOWN, shutterClicked,false,0,true);
			
			TweenMax.from(this,.5,{y:-1920,ease:Sine.easeOut});

		}
		
		
		
		public function setCameraView(bmd:BitmapData):void
		{
			if(!photoTaken) camBMD.draw(bmd, faceMatrix);

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
			
			trace("next click, stageNum:",stageNum);

			switch(stageNum)
			{
				case 1:
					//save final photo
					var photoName:String = Maths.getUniqueName();
					
					
					var fileRef:FileReference = new FileReference();
					
					encoder = new JPGEncoder(90);
					photoBytes = encoder.encode(camBMD);
					
					var file:File = File.desktopDirectory.resolvePath("kioskData");
					file= file.resolvePath(photoName+".jpg"); 
					var fs:FileStream = new FileStream();
					
					//open file in write mode
					fs.open(file,FileMode.WRITE);
					//write bytes from the byte array
					fs.writeBytes(photoBytes);
					//close the file
					fs.close();	
					
					userXML.photo = photoName+".jpg";
					
					progressDisplay.gotoAndStop(2);
										
					stage2();
	
				break;
				case 2:
					
					for each (var int:String in interestsInput.userInterests)
					{
						userXML.interests.appendChild(XML("<interest>"+int+"</interest>"));
					}

					//trace("userXML",userXML);

					finishBtn.visible = true;
					nextBtn.visible = false;
					
					progressDisplay.gotoAndStop(3);

					stage3();

				break;
				case 3:
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
			TweenMax.to(this,.5,{delay:4,y:-1920,ease:Sine.easeIn, onComplete:finished});

		}
		
		private function finished():void
		{
			trace("finished");
			dispatchEvent(new CustomEvent(CustomEvent.INPUT_CANCELLED));

				// save xml and dispatch finished event
			
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
					//currentNameString.slice( 0, -1 );
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
			
			//currentNameTF.text = currentNameString;
			
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