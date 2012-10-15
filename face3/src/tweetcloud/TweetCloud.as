package tweetcloud
{
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FogMethod;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import rhythm.events.CustomEvent;
	import rhythm.utils.DataIO;
	import rhythm.utils.Maths;
	
	import tweetcloud.boxes.Blob;
	import tweetcloud.boxes.BlobBox;
	import tweetcloud.boxes.FaceBox;
	import tweetcloud.boxes.MessageWrapper;
	import tweetcloud.boxes.TweetBox;
	
	
	public class TweetCloud extends Sprite
	{		
		private var view:View3D;
		private var boxes:Array;
		private var blobs:Array;
		private var boxesHolder:Sprite;
		
		public var spinMultiplier:Number = .2;
		
		private var pointLight:PointLight;	
		private var directonalLight:DirectionalLight;
		private var fogMethod:FogMethod;
		
		private var nextId:int = 0;

		private var faceBox:FaceBox;
		private var paused:Boolean;
		
		private var dataIO:DataIO;
		private var banners:Banner;
		private var blobsHolder:Sprite;
		
		
		public function TweetCloud()
		{	
		}
		
		public function init(dataIO:DataIO):void
		{		
			this.dataIO = dataIO;
			setUpAway3D();			
			
			createFace();
			createInitialBoxes();
			createBlobs(35);
			
			banners = new Banner();
			banners.initWithConfig(dataIO.configXML);
			addChild(banners);
			
			
			pause3d(false);
		}
		
		private function createFace():void
		{	
			faceBox = new FaceBox(pointLight,dataIO.configXML );

			view.scene.addChild(faceBox.cameraPlane);
			view.scene.addChild(faceBox.ringPlane);
		}
		
		public function updateFace(faceBMD:BitmapData):void
		{
			faceBox.updateFaceBMD(faceBMD);
		}

		
		private function setUpAway3D():void
		{
			view = new View3D();
			view.antiAlias = 2;
			view.height = 1675;
			view.y = 100;
			
			var bg:BitmapData = new GreenBG();			
			var bgTexture:BitmapTexture = new BitmapTexture(bg);
			view.background = bgTexture;
			
			view.camera.lens = new PerspectiveLens(60);			
			view.camera.lens.far = 6000;
			view.camera.z -= 1500;
			
			pointLight = new PointLight();
			pointLight.specular = .5;
			pointLight.ambient = 1;
			view.scene.addChild(pointLight);
			
			fogMethod = new FogMethod(1000, 5000, 0xffffff);
			
			addChild(view); 
		}
		
		private function createInitialBoxes():void
		{			
			boxes = [];
			
			// store boxes on stage so they can be successfully updated as textures - weird...
			boxesHolder = new Sprite();
			boxesHolder.mouseChildren = boxesHolder.mouseEnabled = boxesHolder.visible = false;
			addChild(boxesHolder);
			
			createTweetBoxes();
			createMessageBoxes();
		}
		
		private function createBox(displayBox:TweetBox):void
		{
			var box:MessageWrapper = new MessageWrapper();
			box.init(nextId, displayBox, boxesHolder, pointLight, fogMethod, dataIO);
			// box.addEventListener(CustomEvent.RESET_ALL_PLANES, onResetAllPlanes, false, 0, true);
			box.addEventListener(CustomEvent.ENABLE_ALL_PLANES, onEnableAllPlanes, false, 0, true);
			box.addEventListener(CustomEvent.DISABLE_ALL_PLANES, onDisableAllPlanes, false, 0, true);
			box.addEventListener(CustomEvent.SHOW_BANNER, onShowBanner, false, 0, true);
			box.addEventListener(CustomEvent.CLOSE_3D_MESSAGE, onCloseMessage, false, 0, true);
			box.addEventListener(CustomEvent.ADD_STAGE_MOUSEDOWN, onAddStageMouseDown, false, 0, true);
			
			boxes.push(box);
			view.scene.addChild(box.container);				
			boxesHolder.addChild(box.box);
			
			box.stage = stage;
			++nextId;
		}
		
		private function onShowBanner(event:CustomEvent):void
		{
			//trace(event.params.interests);
			TweenMax.allTo([faceBox.cameraPlane, faceBox.ringPlane],.5,{z:5000, ease:Sine.easeIn});
			if(event.params.interests.length>0)	banners.showBanner(event.params.interests);

		}
		
		private function onCloseMessage(e:CustomEvent):void
		{
			TweenMax.to(faceBox.cameraPlane,.5,{z:0, ease:Expo.easeOut});
			TweenMax.to(faceBox.ringPlane,.5,{z:-1, ease:Expo.easeOut});
			banners.closeBanner();
		}
		
		private function createTweetBoxes():void
		{
			var tweets:XML = dataIO.getRandomTweets(Number(dataIO.configXML.threeD.@tweets));
			
			for (var i:int=0; i<tweets.Profile.length(); ++i)
			{				
				var displayBox:TweetBox = new TweetBoxDisplay();
				displayBox.bgColours = dataIO.configXML.threeD.plane.colours.colour;				
				displayBox.addEventListener(CustomEvent.TWEETBOX_READY, onTweetBoxReady, false, 0, true);
				
				if (String(tweets.Profile[i].BodyImage).length) displayBox.populateTweetImage(tweets.Profile[i]);
				else displayBox.populateTweet(tweets.Profile[i]);				
			}
		}
		
		private function onTweetBoxReady(event:CustomEvent):void
		{
			var displayBox:TweetBox = event.params.displayBox;
			displayBox.removeEventListener(CustomEvent.TWEETBOX_READY, onTweetBoxReady);
			createBox(displayBox);
		}
		
		private function createMessageBoxes():void
		{
			var messages:XML = dataIO.getRandomMessages(Number(dataIO.configXML.threeD.@messages));
			
			for (var i:int=0; i<messages.user.length(); ++i)
			{					
				var displayBox:TweetBox = new TweetBoxDisplay();
				displayBox.bgColours = dataIO.configXML.threeD.plane.colours.colour;
				displayBox.populateMessage(messages.user[i]);
				displayBox.addEventListener(CustomEvent.TWEETBOX_READY, onMessageBoxReady, false, 0, true);
			}
		}
		
		private function onMessageBoxReady(event:CustomEvent):void
		{
			var displayBox:TweetBox = event.params.displayBox;
			displayBox.removeEventListener(CustomEvent.TWEETBOX_READY, onMessageBoxReady);
			createBox(displayBox);
		}
		
		public function resetAllPlanes():void
		{
			onResetAllPlanes(null);

		}
		
		private function onResetAllPlanes(event:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onResetAllPlanes);
			stage.removeEventListener(MouseEvent.MOUSE_OVER, onResetAllPlanes);
			
			//trace("onResetAllPlanes");
			for each (var box:MessageWrapper in boxes)
			{
				box.resetPlane();
			}
		}
		
		private function onEnableAllPlanes(event:CustomEvent):void
		{
			for each (var box:MessageWrapper in boxes)
			{
				box.enablePlane();
			}
		}
		
		private function onDisableAllPlanes(event:Event):void
		{
			for each (var box:MessageWrapper in boxes)
			{
				box.disablePlane();
			}
		}
		
		private function onAddStageMouseDown(event:CustomEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onResetAllPlanes, false, 0, true);
			if(dataIO.configXML.touchScreen == "true") stage.addEventListener(MouseEvent.MOUSE_OVER, onResetAllPlanes, false, 0, true);
		}
		
		private function createBlobs(amount:int):void
		{
			blobs = [];
			blobsHolder = new Sprite();
			blobsHolder.mouseChildren = blobsHolder.mouseEnabled = blobsHolder.visible = false;
			addChild(blobsHolder);
			
			for (var i:int=0; i<amount; ++i)
			{
				var blobBox:BlobBox = new BlobBox();
				var blob:Blob = new BlobDisplay();
				blobsHolder.addChild(blob);
				
				blob.init(dataIO);				
				blobBox.init(blob, pointLight, fogMethod, dataIO);
				
				blobs.push(blobBox);
				view.scene.addChild(blobBox.container);
			}
		}
		
		
		private function onEnterFrame(event:Event):void
		{			
			for (var i:int=0; i<boxes.length; ++i) { boxes[i].update(); }			
			for (i=0; i<blobs.length; ++i) { blobs[i].container.rotationY += blobs[i].spinSpeed; }			
			view.render();
		}
		
		public function pause3d(updateData:Boolean=true):void
		{
			if(!paused)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				paused=true;
				resetAllPlanes();
				
				if (updateData)
				{
					dataIO.addEventListener(CustomEvent.DATA_READY, onFreshDataReady, false, 0, true);
					dataIO.update();
				}				
			}
		}
		
		private function onFreshDataReady(event:Event):void
		{
			dataIO.removeEventListener(CustomEvent.DATA_READY, onFreshDataReady);	
			
			var tweets:XML = dataIO.getRandomTweets(Number(dataIO.configXML.threeD.@tweets));
			var messages:XML = dataIO.getRandomMessages(Number(dataIO.configXML.threeD.@messages));
			
			for (var i:int=0; i<boxes.length; ++i)
			{
				if (i < tweets.Profile.length()) boxes[i].updateTweet(tweets.Profile[i]);
				else boxes[i-tweets.Profile.length()].updateMessage(messages.user[i-tweets.Profile.length()]);
			}
		}
		
		public function resume3d():void
		{
			if(paused)
			{
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
				paused=false;	
			}		
		}
		
		public function remove3d():void
		{
			if (view) view.stage3DProxy.dispose();
		}
	}
}