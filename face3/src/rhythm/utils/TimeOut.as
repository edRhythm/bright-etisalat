package rhythm.utils
{	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	/**
	 *	TimeOut class
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Adam Palmer
	 *	@since  17.02.2011
	 */
	
	public class TimeOut
	{		
		private var timer:Timer;
		
		public var seconds:Number;
		public var callback:Function;
		
		
		public function TimeOut($seconds:Number, $callback:Function):void
		{
			callback = $callback;
			seconds = $seconds;
		}
		
		public function start():void
		{
			 //trace("==> timeout starting...");
			
			if (timer == null)
			{
				timer = new Timer(seconds*1000, 1);
				timer.addEventListener(TimerEvent.TIMER, onTimeOut);
			}
			
			timer.start();
		}
		
		public function cancel():void
		{
			//trace("==> timeout cancelled");			
			if (timer) timer.reset();
		}
		
		public function reset():void
		{
			cancel();
			start();
		}
		
		private function onTimeOut(e:TimerEvent):void
		{
			//trace("==> timeout timed out at", timer.delay);
			timer.reset();
			callback();
		}
	}
}