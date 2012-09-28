package tweetcloud.boxes
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FogMethod;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Elastic;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	
	public class BlobBox
	{
		public var blob:Blob;
		public var plane:Mesh;
		public var container:ObjectContainer3D;
		public var material:TextureMaterial;
		
		private var pointLight:PointLight;
		private var fog:FogMethod;
		
		public var spinSpeed:Number;
		private var bmd:BitmapData;
		
		private var mat:TextureMaterial;
		
		
		public function BlobBox()
		{
		}
		
		public function init(blob:Blob, light:PointLight, fogMethod:FogMethod):void
		{
			pointLight = light;
			fog = fogMethod;
			
			spinSpeed = .1+Math.random()*.2;
			
			createPlane(blob);
			createMaterial();
			updateDisplayBox(blob);
		}
		
		private function createPlane(blob:Blob):void
		{
			var targetY:Number = 1000 - Math.random()*2000;
			var targetScale:Number = .4+Math.random()*.5;
			
			plane = new Mesh(new PlaneGeometry(blob.width, blob.height));
			plane.rotationX = ((targetY / 30)-90);
			plane.rotationY = -90;
			plane.scale(.01);
				
			TweenMax.to(plane, 2 + Math.random()*7, {x:800 + Math.random()*1000, y:targetY, scaleX:targetScale, scaleZ:targetScale, ease:Elastic.easeOut, delay:1+Math.random()});
			
			container = new ObjectContainer3D();
			container.rotationY = Math.random()*360;
			container.addChild(plane);
		}
		
		private function createMaterial():void
		{
			mat = new TextureMaterial();
			mat.alphaBlending = true;			
			mat.lightPicker = new StaticLightPicker([pointLight]);
			mat.addMethod(fog);
		}
		
		public function updateDisplayBox(blob:Blob):void
		{
			if (bmd == null) bmd = new BitmapData(blob.width, blob.height, true, 0x000000);			
			bmd.lock();
			bmd.fillRect(bmd.rect, 0);
			bmd.draw(blob);
			bmd.unlock();
			
			mat.texture = new BitmapTexture(bmd);
			mat.alpha = .6 + Math.random()*.4;
			
			plane.material = mat;
			plane.material.bothSides = true;
		}
	}
}