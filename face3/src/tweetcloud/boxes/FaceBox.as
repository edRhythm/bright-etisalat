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
		public var plane:Mesh;
		public var mat:TextureMaterial;
		public var finalBMD:BitmapData;
		private var faceMatrix:Matrix;
		
		
		public function FaceBox(pointLight:PointLight)
		{
			faceMatrix = new Matrix();
			faceMatrix.rotate( -90 * (Math.PI / 180 ) );
			faceMatrix.translate( 0, 512);

			finalBMD = new BitmapData(512,512);
			
			var bmd:BitmapData = new Face();			
			
			plane = new Mesh(new PlaneGeometry(512, 512));	
			plane.rotationX = -90;
			plane.y = 280;
			plane.scaleX = plane.scaleZ = 1.75;
			
			mat = new TextureMaterial();
			mat.alphaBlending = true;			
			mat.lightPicker = new StaticLightPicker([pointLight]);
			mat.texture = new BitmapTexture(bmd);
			//mat.alpha = .87;
			
			plane.material = mat;
			plane.material.bothSides = true;
		}
		
		public function updateFaceBMD(bmd:BitmapData):void
		{	
			finalBMD.lock();
			finalBMD.fillRect(new Rectangle(0,0,finalBMD.width, finalBMD.height),0);
			finalBMD.draw(bmd,faceMatrix);
			finalBMD.unlock();

			mat.texture = new BitmapTexture(finalBMD);	
		}
	}
}