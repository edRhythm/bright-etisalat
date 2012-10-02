package rhythm.displayObjects
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.display.Sprite;

	public class MotionParticle extends Sprite
	{
		public var shape:ParticleCross;
		
		public function MotionParticle(xDist:int, yDist:int, time:Number)
		{
			var rough:RoughEase = new RoughEase(1.5, 30, true, Strong.easeOut, "none", true, "superRoughEase");

			
			shape = new ParticleCross();
			addChild(shape);
			
			TweenMax.to(shape, Math.random()*time, {x:Math.random()*xDist, y:Math.random()*yDist, ease:rough, onComplete:killParticle});
		}
		
		public function killParticle():void
		{
			removeChild((shape);
			this.parent.removeChild(this);
		//	this=null;

		}
	}
}