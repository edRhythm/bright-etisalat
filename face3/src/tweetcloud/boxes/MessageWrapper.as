package tweetcloud.boxes
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.lights.PointLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FogMethod;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Sine;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import rhythm.events.CustomEvent;
	import rhythm.utils.DataIO;
	
	
	public class MessageWrapper extends EventDispatcher
	{
		public var id:int;
		
		public var box:TweetBox;
		public var plane:Mesh;
		public var container:ObjectContainer3D;
		public var material:TextureMaterial;		
		private var pointLight:PointLight;
		private var fog:FogMethod;
		
		private var bmd:BitmapData;
		private var mat:TextureMaterial;
		
		public var spinSpeed:Number;		
		public var doUpdate:Boolean;
		public var stage:Stage;
		
		private var settings:Object;
		private var boxesHolder:Sprite;
		private var dataIO:DataIO;
		
		
		public function MessageWrapper()
		{
			super();
		}
		
		public function init(boxId:int, displayBox:TweetBox, boxesHolder:Sprite, light:PointLight, fogMethod:FogMethod, dataIO:DataIO):void
		{
			this.dataIO = dataIO;
			this.boxesHolder = boxesHolder;
			id = boxId;
			pointLight = light;
			fog = fogMethod;
			
			spinSpeed = .1 + Math.random()*.2;
			doUpdate = true;
			
			createPlane();
			createMaterial();
			updateDisplayBox(displayBox);
		}
		
		private function createMaterial():void
		{
			mat = new TextureMaterial();
			mat.alphaBlending = true;			
			mat.lightPicker = new StaticLightPicker([pointLight]);
			mat.addMethod(fog);
		}
		
		private function createPlane():void
		{
			var planeBounds:XMLList = dataIO.configXML.threeD.plane;
			var holeBounds:XMLList = dataIO.configXML.threeD.hole;
			
			plane = new Mesh(new PlaneGeometry(256, 256));
			plane.x = int(planeBounds.@diameter)/2 + Math.random()*int(planeBounds.@diameter);
			
			plane.y = int(planeBounds.@bot) + Math.random()*(Math.abs(int(planeBounds.@bot))-Math.abs(int(holeBounds.@bot)));
			if (Math.random() > .6) plane.y = int(holeBounds.@top) + Math.random()*(Math.abs(int(planeBounds.@top))-Math.abs(int(holeBounds.@top)));
			
			plane.rotationX = ((plane.y / 30)-90);
			plane.rotationY = -90;
			plane.scale(.8+Math.random()*.3);
			
			plane.mouseEnabled = true;
			plane.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDownPlane, false, 0, true);
			if(dataIO.configXML.touchScreen == "true")  plane.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseDownPlane, false, 0, true);
			
			container = new ObjectContainer3D();
			container.rotationY = Math.random()*360;
			container.addChild(plane);
		}
		
		private function onMouseDownPlane(event:MouseEvent3D):void
		{
			dispatchEvent(new CustomEvent(CustomEvent.DISABLE_ALL_PLANES, true));
			doUpdate = plane.mouseEnabled = false;
			
			settings = {
				matAlpha:mat.alpha,
				plane: { x:plane.x, y:plane.y, z:plane.z, scale:plane.scaleX, rotationX:plane.rotationX },
				container: { rotationY:container.rotationY },
				zoomDuration: .6
			};
			
			if (box.type == 'message') settings.offsets = { box:-185, plane:135 };
			else settings.offsets = { box:-120, plane:80 };
			
			TweenMax.to(container, settings.zoomDuration, {rotationY:90, ease:Quad.easeInOut});
			TweenMax.to(plane, settings.zoomDuration, {x:1300, y:settings.offsets.plane, z:0, scaleX:1.575, scaleZ:1.575, rotationX:-90, ease:Sine.easeOut, onComplete:showTweetBox, onUpdate:switchTextureByZ});
			TweenMax.to(mat, settings.zoomDuration, {alpha:1, ease:Quad.easeInOut});
			
			dispatchEvent(new CustomEvent(CustomEvent.SHOW_BANNER, true, false, {interests:box.getInterests()}));
		}
		
		private function showTweetBox():void
		{						
			box.scaleX = box.scaleY = 1.9;
			box.x = stage.stageWidth/2 - 242;
			box.y = stage.stageHeight/2 - 242 + settings.offsets.box;
			box.alpha = 0;
			stage.addChild(box);
			
			TweenMax.to(box, .14, {alpha:1, ease:Quad.easeOut});
			box.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownBox, false, 0, true);
			if(dataIO.configXML.touchScreen == "true") box.addEventListener(MouseEvent.MOUSE_OVER, onMouseDownBox, false, 0, true);
			
			dispatchEvent(new CustomEvent(CustomEvent.ADD_STAGE_MOUSEDOWN, true));
		}
		
		private function onMouseDownBox(event:MouseEvent):void
		{
			resetPlane();
		}
		
		public function disablePlane():void
		{
			plane.mouseEnabled = false;
		}
		
		public function enablePlane():void
		{
			plane.mouseEnabled = true;
		}
		
		public function resetPlane():void
		{
			if (settings != null)
			{
				box.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownBox);
				if(dataIO.configXML.touchScreen == "true") box.removeEventListener(MouseEvent.MOUSE_OVER, onMouseDownBox);

				box.alpha = box.x = box.y = 0;
				box.scaleX = box.scaleY = 1;
				boxesHolder.addChild(box);
				
				// reset plane etc
				TweenMax.to(container, .7, {rotationY:settings.container.rotationY, ease:Quad.easeOut});
				TweenMax.to(plane, .7, {x:settings.plane.x, y:settings.plane.y, z:settings.plane.z, scaleX:settings.plane.scale, scaleZ:settings.plane.scale, rotationX:settings.plane.rotationX, ease:Sine.easeOut, onComplete:resumeUpdate, onUpdate:switchTextureByZ});
				TweenMax.to(mat, .4, {alpha:settings.matAlpha, ease:Quad.easeInOut});
				
				dispatchEvent(new CustomEvent(CustomEvent.CLOSE_3D_MESSAGE, true));
			}
		}
		
		private function resumeUpdate():void
		{
			dispatchEvent(new CustomEvent(CustomEvent.ENABLE_ALL_PLANES, true));
			
			doUpdate = plane.mouseEnabled = true;
			settings = null;
		}
		
		public function updateDisplayBox(displayBox:TweetBox=null):void
		{
			if (displayBox != null) box = displayBox;
			
			if (bmd == null) bmd = new BitmapData(256, 256, true, 0x000000);			
			bmd.lock()
			bmd.fillRect(bmd.rect, 0);
			bmd.draw(box);
			bmd.unlock();
			
			mat.texture = new BitmapTexture(bmd);
			mat.alpha = .6 + Math.random()*.4;
			
			plane.material = mat;
			plane.material.bothSides = true;
		}
		
		public function switchTextureByZ():void
		{
			var updateTexture:Boolean;			
			
			if (container.rotationY > 160) updateTexture = box.showFrameTexture(box.type + 'Blank');
			else updateTexture = box.showFrameTexture(box.type);
			
			if (updateTexture) updateDisplayBox(box);
		}
		
		public function update():void
		{
			if (doUpdate)
			{
				switchTextureByZ();
				container.rotationY += spinSpeed;
				
				// refresh with new data as it goes round
				if (container.rotationY > 395) 
				{
					container.rotationY -= 360; // keep within 360
					
					if (box.type == 'tweet' || box.type == 'tweetImage') updateTweet(dataIO.getRandomTweets(1).Profile[0]);
					else updateMessage(dataIO.getRandomMessages(1).user[0]);
				}
			}
		}
		
		public function updateTweet(tweet:XML):void
		{
			box.addEventListener(CustomEvent.TWEETBOX_READY, onUpdateBoxReady, false, 0, true);
			
			if (String(tweet.BodyImage).length) box.populateTweetImage(tweet);
			else box.populateTweet(tweet);				
		}
		
		public function updateMessage(message:XML):void
		{
			box.addEventListener(CustomEvent.TWEETBOX_READY, onUpdateBoxReady, false, 0, true);
			box.populateMessage(message);
		}
		
		private function onUpdateBoxReady(event:CustomEvent):void
		{
			box.removeEventListener(CustomEvent.TWEETBOX_READY, onUpdateBoxReady);
			updateDisplayBox(box);
		}
		
	}
}