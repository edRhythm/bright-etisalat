package tweetcloud.boxes
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	

	public class FaceBox
	{
		public var cameraPlane:Mesh;
		public var ringPlane:Mesh;
		public var mat:TextureMaterial;
		public var finalBMD:BitmapData;
		private var faceMatrix:Matrix;
		private var faceRing:FaceRim3d;
		private var light:PointLight;
		
		
		public function FaceBox(pointLight:PointLight)
		{
			light = pointLight
			
			faceMatrix = new Matrix();
			faceMatrix.rotate( -90 * (Math.PI / 180 ) );
			faceMatrix.translate( 0, 512);

			finalBMD = new BitmapData(512,512);
					
			cameraPlane = new Mesh(new PlaneGeometry(512, 512));	
			cameraPlane.rotationX = -90;
			cameraPlane.y = 280;
			cameraPlane.scaleX = cameraPlane.scaleZ = 1.75;
			
			
			mat = new TextureMaterial();
			mat.alphaBlending = true;			
			mat.lightPicker = new StaticLightPicker([light]);
		//	mat.alpha = .87;
			
			cameraPlane.material = mat;
			
			addRing()
		}
		
		private function addRing():void
		{
			faceRing = new FaceRim3d();
			
			ringPlane = new Mesh(new PlaneGeometry(1024, 1024));	
			ringPlane.rotationX = -90;
			ringPlane.y = 50;
			ringPlane.z = -1;
			ringPlane.x = 360;
			ringPlane.scaleX = ringPlane.scaleZ = 1.75;
			
			var mat:TextureMaterial = new TextureMaterial();
			var matBMD:BitmapData = new BitmapData(1024,1024,true, 0x000000);
			matBMD.draw(faceRing);
			mat.alphaBlending = true;			
			mat.lightPicker = new StaticLightPicker([light]);
			mat.texture = new BitmapTexture(matBMD);
			
			ringPlane.material = mat;

		}
		
		public function updateFaceBMD(bmd:BitmapData):void
		{	
			finalBMD.lock();
			finalBMD.fillRect(new Rectangle(0,0,finalBMD.width, finalBMD.height),0xFFFFFF);
			finalBMD.draw(bmd,faceMatrix);
			finalBMD.unlock();

			mat.texture = new BitmapTexture(finalBMD);	
		}
	}
}