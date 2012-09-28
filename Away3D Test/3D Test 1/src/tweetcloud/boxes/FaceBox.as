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
	

	public class FaceBox
	{
		public var plane:Mesh;
		public var mat:TextureMaterial;
		
		
		public function FaceBox(pointLight:PointLight)
		{
			var bmd:BitmapData = new Face();			
			
			plane = new Mesh(new PlaneGeometry(bmd.width, bmd.height));	
			plane.rotationX = -90;
			plane.scaleX = plane.scaleZ = 1.75;
			
			mat = new TextureMaterial();
			mat.alphaBlending = true;			
			mat.lightPicker = new StaticLightPicker([pointLight]);
			mat.texture = new BitmapTexture(bmd);
			mat.alpha = .87;
			
			plane.material = mat;
			plane.material.bothSides = true;
		}
	}
}