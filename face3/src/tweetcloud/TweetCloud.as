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
	
	import com.greensock.loading.ImageLoader;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import rhythm.events.CustomEvent;
	import rhythm.utils.DataIO;
	
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
		
		private var testMessage:String = 'I am a twat. I am. I don\'t care what any fucker says. I am and will always be a twat. Thank you for listening. Now cock off.';
		private var dataIO:DataIO;
		
		
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
			
			pause3d(false);
			
			// stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage);
		}
		
		private function onMouseDownStage(event:Event):void
		{
			dataIO.addEventListener(CustomEvent.DATA_READY, onDataReady, false, 0, true);
			dataIO.update();
		}
		
		private function createFace():void
		{
			faceBox = new FaceBox(pointLight);
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
			
//			directonalLight = new DirectionalLight();
//			directonalLight.specular = .5;
//			view.scene.addChild(directonalLight);
			
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
			box.init(nextId, displayBox, boxesHolder, pointLight, fogMethod);
			box.addEventListener('reset all planes', onResetAllPlanes, false, 0, true);	
			
			boxes.push(box);
			view.scene.addChild(box.container);				
			boxesHolder.addChild(box.box);
			
			box.stage = stage;
			++nextId;
		}
		
		private function createTweetBoxes():void
		{
			var tweets:XML = dataIO.getRandomTweets(Number(dataIO.configXML.threeD.@tweets));
			
			for (var i:int=0; i<tweets.Profile.length(); ++i)
			{				
				var displayBox:TweetBox = new TweetBoxDisplay();
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
			for each (var box:MessageWrapper in boxes)
			{
				box.resetPlane();
			}
		}
		
		private function createBlobs(amount:int):void
		{
			blobs = [];
			
			for (var i:int=0; i<amount; ++i)
			{
				var blobBox:BlobBox = new BlobBox();
				var blob:Blob = new BlobDisplay();
				
				blobBox.init(blob, pointLight, fogMethod);
				
				blobs.push(blobBox);
				view.scene.addChild(blobBox.container);
			}
		}
		
		
		private function onEnterFrame(event:Event):void
		{			
			for (var i:int=0; i<boxes.length; ++i)
			{
				boxes[i].update();
			}
			
			for (i=0; i<blobs.length; ++i)
			{
				blobs[i].container.rotationY += blobs[i].spinSpeed;
			}
			
			view.render();
		}
		
		public function pause3d(updateData:Boolean=true):void
		{
			if(!paused)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				paused=true;
				
				if (updateData)
				{
					dataIO.addEventListener(CustomEvent.DATA_READY, onDataReady, false, 0, true);
					dataIO.update();
				}				
			}
		}
		
		private function onDataReady(event:Event):void
		{
			dataIO.removeEventListener(CustomEvent.DATA_READY, onDataReady);	
			
			var tweets:XML = dataIO.getRandomTweets(Number(dataIO.configXML.threeD.@tweets));
			var messages:XML = dataIO.getRandomMessages(Number(dataIO.configXML.threeD.@messages));
			
			trace(boxes.length, tweets.Profile.length(), messages.user.length());
			
			for (var i:int=0; i<boxes.length; ++i)
			{
				if (i < tweets.Profile.length()) boxes[i].updateTweet(tweets.Profile[i]);
				else boxes[i-tweets.Profile.length()].updateMessage(messages.user[i-tweets.Profile.length()]);
				
				if (i < tweets.Profile.length()) trace('\n', i, boxes[i], tweets.Profile[i]);
				else trace('\n', i-tweets.Profile.length(), boxes[i-tweets.Profile.length()], messages.user[i-tweets.Profile.length()]); 
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