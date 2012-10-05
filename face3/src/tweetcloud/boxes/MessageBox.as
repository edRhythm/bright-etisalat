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
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	
	public class MessageBox extends EventDispatcher
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
		
		
		public function MessageBox()
		{
			super();
		}
		
		public function init(boxId:int, displayBox:TweetBox, light:PointLight, fogMethod:FogMethod):void
		{
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
			
			plane = new Mesh(new PlaneGeometry(displayBox.width, displayBox.height));
			plane.rotationX = ((targetY / 30)-90);
			plane.rotationY = -90;
			plane.scale(.01);
			
			plane.mouseEnabled = true;
			plane.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDownPlane);
			plane.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseOverPlane);
			plane.addEventListener(MouseEvent3D.MOUSE_OUT, onMouseOutPlane);
			
			TweenMax.to(plane, 2 + Math.random()*10, {x:800 + Math.random()*1000, y:targetY, scaleX:targetScale, scaleZ:targetScale, ease:Elastic.easeOut, delay:.5 + Math.random()*2});
			
			container = new ObjectContainer3D();
			container.rotationY = Math.random()*360;
			container.addChild(plane);
		}
		
		private function onMouseDownPlane(event:MouseEvent3D):void
		{
			doUpdate = false;
			
			trace('plane.y:', plane.y);
			
			// TweenMax.to(container, 1, {rotationY:90, ease:Quad.easeInOut});
			// TweenMax.to(plane, 1, {x:1300, y:0, z:0, scaleX:1, scaleZ:1, rotationX:-90, ease:Sine.easeOut, onComplete:showTweetBox});
		}
		
		private function showTweetBox():void
		{						
			box.scaleX = box.scaleY = 1.38;
			box.x = stage.stageWidth/2 - box.width/2;
			box.y = stage.stageHeight/2 - box.height/2;
			box.alpha = 0;
			stage.addChild(box);
			
			TweenMax.to(box, .6, {alpha:mat.alpha, ease:Quad.easeOut});
			TweenMax.to(mat, .6, {alpha:0, ease:Quad.easeIn});
		}
		
		private function onMouseOverPlane(event:MouseEvent3D):void
		{
			Mouse.cursor = MouseCursor.BUTTON;
		}
		
		private function onMouseOutPlane(event:MouseEvent3D):void
		{
			Mouse.cursor = MouseCursor.AUTO;	
		}
		
		public function updateDisplayBox(displayBox:TweetBox):void
		{
			box = displayBox;
			
			if (bmd == null) bmd = new BitmapData(box.width, box.height, true, 0x000000);			
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
			
			if (container.rotationY > 160) updateTexture = box.showFrameTexture(box.frameDefault + 'Blank');
			else updateTexture = box.showFrameTexture(box.frameDefault);	
			
			if (updateTexture) updateDisplayBox(box);
		}
		
		public function update():void
		{
			if (doUpdate)
			{
				switchTextureByZ();
				container.rotationY += spinSpeed;
				
				if (container.rotationY > 360) 
				{
					container.rotationY -= 360; // keep within 360
					
					var displayBox:TweetBox = new TweetBoxDisplay();
					displayBox.populate('Edmund Baldry', '@edbaldry', 'I am a twat. I am. I don\'t care what any fucker says. I am and will always be a twat. Thank you for listening. Now cock off.');
					updateDisplayBox(displayBox); // refresh with new message
				}
			}
		}
	}
}