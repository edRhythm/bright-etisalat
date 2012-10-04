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
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import tweetcloud.boxes.Blob;
	import tweetcloud.boxes.BlobBox;
	import tweetcloud.boxes.FaceBox;
	import tweetcloud.boxes.MessageBox;
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
		
		
		public function TweetCloud()
		{	
		}
		
		public function init():void
		{			
			setUpAway3D();			
			
			createFace();
			createInitialBoxes(50);
			createBlobs(40);
			
			pause3d();
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
			
			directonalLight = new DirectionalLight();
			directonalLight.specular = .5;
			view.scene.addChild(directonalLight);
			
			fogMethod = new FogMethod(1000, 5000, 0xffffff);
			
			addChild(view); 
		}
		
		private function createInitialBoxes(amount:int):void
		{			
			boxes = [];
			
			// store boxes on stage so they can be successfully updated as textures - weird...
			boxesHolder = new Sprite();
			boxesHolder.mouseChildren = boxesHolder.mouseEnabled = boxesHolder.visible = false;
			addChild(boxesHolder);
			
			for (var i:int=0; i<amount; ++i)
			{
				var box:MessageBox = new MessageBox();
				var displayBox:TweetBox = new TweetBoxDisplay();
				
				box.init(nextId, displayBox, pointLight, fogMethod);
				boxes.push(box);
				view.scene.addChild(box.container);				
				boxesHolder.addChild(box.box);
				
				box.stage = stage;
				++nextId;
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
		
		public function pause3d():void
		{
			if(!paused)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				paused=true;
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
			if(view)view.stage3DProxy.dispose();
			
		}
	}
}