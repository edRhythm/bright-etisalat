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
		
		
		public function MessageWrapper()
		{
			super();
		}
		
		public function init(boxId:int, displayBox:TweetBox, boxesHolder:Sprite, light:PointLight, fogMethod:FogMethod):void
		{
			this.boxesHolder = boxesHolder;
			id = boxId;
			pointLight = light;
			fog = fogMethod;
			
			spinSpeed = .1 + Math.random()*.2;
			doUpdate = true;
			
			createPlane(displayBox);
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
		
		private function createPlane(displayBox:TweetBox):void
		{
			var targetY:Number = -1000 + Math.random()*780;
			if (Math.random() < .5) targetY = 400 + Math.random()*600;
			
			var targetScale:Number = .8+Math.random()*.3;
			
			// plane = new Mesh(new PlaneGeometry(displayBox.width, displayBox.height));
			plane = new Mesh(new PlaneGeometry(256, 256));
			plane.rotationX = ((targetY / 30)-90);
			plane.rotationY = -90;
			plane.scale(.01);
			
			plane.mouseEnabled = true;
			plane.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDownPlane);
			
			TweenMax.to(plane, 2 + Math.random()*10, {x:800 + Math.random()*1000, y:targetY, scaleX:targetScale, scaleZ:targetScale, ease:Elastic.easeOut, delay:.5 + Math.random()*2});
			
			container = new ObjectContainer3D();
			container.rotationY = Math.random()*360;
			container.addChild(plane);
		}
		
		private function onMouseDownPlane(event:MouseEvent3D):void
		{
			dispatchEvent(new Event('reset all planes', true));
			doUpdate = plane.mouseEnabled = false;
			
			settings = {
				matAlpha:mat.alpha,
				plane: { x:plane.x, y:plane.y, z:plane.z, scale:plane.scaleX, rotationX:plane.rotationX },
				container: { rotationY:container.rotationY },
				zoomDuration: .6
			};
			
			if (box.type == 'message') settings.offsets = { box:-185, plane:135 }
			else settings.offsets = { box:-120, plane:80 };
			
			TweenMax.to(container, settings.zoomDuration, {rotationY:90, ease:Quad.easeInOut});
			TweenMax.to(plane, settings.zoomDuration, {x:1300, y:settings.offsets.plane, z:0, scaleX:1.575, scaleZ:1.575, rotationX:-90, ease:Sine.easeOut, onComplete:showTweetBox, onUpdate:switchTextureByZ});
			TweenMax.to(mat, settings.zoomDuration, {alpha:1, ease:Quad.easeInOut});
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
		}
		
		private function onMouseDownBox(event:MouseEvent):void
		{
			resetPlane();
		}
		
		public function resetPlane():void
		{
			if (settings != null)
			{
				box.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownBox);
				box.alpha = box.x = box.y = 0;
				box.scaleX = box.scaleY = 1;
				boxesHolder.addChild(box);
				
				// reset plane etc
				TweenMax.to(container, .7, {rotationY:settings.container.rotationY, ease:Quad.easeOut});
				TweenMax.to(plane, .7, {x:settings.plane.x, y:settings.plane.y, z:settings.plane.z, scaleX:settings.plane.scale, scaleZ:settings.plane.scale, rotationX:settings.plane.rotationX, ease:Sine.easeOut, onComplete:resumeUpdate, onUpdate:switchTextureByZ});
				TweenMax.to(mat, .4, {alpha:settings.matAlpha, ease:Quad.easeInOut});
			}			
		}
		
		private function resumeUpdate():void
		{
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
				if (container.rotationY > 360) 
				{
					container.rotationY -= 360; // keep within 360
					
//					var displayBox:TweetBox = new TweetBoxDisplay();
//					displayBox.populateTweet('Edmund Baldry', '@edbaldry', 'I am a twat. I am. I don\'t care what any fucker says. I am and will always be a twat. Thank you for listening. Now cock off.');
//					
					// updateDisplayBox(); // refresh with new message
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