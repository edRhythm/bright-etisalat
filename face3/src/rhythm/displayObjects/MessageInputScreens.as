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
	import flash.events.Event;
	import flash.events.MouseEvent;
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
		private var faceBitmap:Bitmap;
		private var camBMD:BitmapData;
		private var faceMatrix:Matrix;
		private var photoScale:Number;
		private var greenRim:GreenPhotoRim;
		private var neoTechFont:NeoTechFont;
		private var countdownTF:TextField;
		
		//timeline
		public var cancelBtn:SimpleButton;
		public var nextBtn:SimpleButton;
		public var cameraBtn:SimpleButton;
		public var messageBox:MovieClip;

		private var encoder:JPGEncoder;

		private var photoBytes:ByteArray;

		private var countDownNum:int;
		
		public function MessageInputScreens()
		{
			photoScale = 0.8;
			
			neoTechFont = new NeoTechFont();
			
			faceMatrix = new Matrix();
			faceMatrix.rotate( -90 * (Math.PI / 180 ) );
			faceMatrix.translate( 0, 512);
			faceMatrix.scale(photoScale,photoScale);
			
			camBMD = new BitmapData(512*photoScale,512*photoScale,true,0x000000);
			
			faceBitmap = new Bitmap(camBMD,"never",true);
			
			messageBox.addChild(faceBitmap);
						
			//rim
			greenRim = new GreenPhotoRim();
			messageBox.addChild(greenRim);

			var tFormat:TextFormat = TFormats.getTFormatToSize(127, neoTechFont,0xFFFFFF, "center");
			countdownTF = TFCreator.createTextField(400,400,false,false,true,"center",tFormat);
			countdownTF.text = "0";
			countdownTF.alpha=.1;
			greenRim.addChild(countdownTF);

			countdownTF.scaleX = countdownTF.scaleY = 2;
			
			countdownTF.x =  (countdownTF.width*-.5);
			countdownTF.y =  (countdownTF.height*-.5);
			countdownTF.text = "";
			
			faceBitmap.x = faceBitmap.y =  faceBitmap.width*-.5;
			
			//buttons
			cancelBtn.addEventListener(MouseEvent.MOUSE_DOWN, doCancelClick);
			cameraBtn.addEventListener(MouseEvent.MOUSE_DOWN, shutterClicked);
		
		}
		
		
		
		public function setCameraView(bmd:BitmapData):void
		{
			//trace("setCameraView");
			camBMD.draw(bmd, faceMatrix);
		}
		
		private function shutterClicked(e:Event):void
		{
			trace("shutterClicked");
			countDownNum = 3;
			countdownTF.text=String(countDownNum);
			countdownTF.alpha=0
			TweenMax.to(countdownTF,1,{alpha:.3,ease:Sine.easeOut, repeat:4, onRepeat:updateCountdown});
		}
		
		private function updateCountdown():void
		{
			trace("updateCountdown",countDownNum);
			
			countDownNum --;
			countdownTF.alpha = 0;
			
			if(countDownNum < 0 )
			{
				countdownTF.text="";
				takePhoto();
			}else{
				countdownTF.text = String(countDownNum);
			}
				
		}
		
		private function takePhoto():void
		{
			var photoName:String = Maths.getUniqueName();
			
			TweenMax.to(greenRim,1,{scaleX:0.2, scaleY:.2, ease:Sine.easeOut, repeat:1, yoyo:1, reverse:true});
			
			var fileRef:FileReference = new FileReference();
			
				encoder = new JPGEncoder(80);
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
		}
		
		private function doCancelClick(event:MouseEvent):void
		{
			dispatchEvent(new CustomEvent(CustomEvent.INPUT_CANCELLED));
			
		}
	}
}