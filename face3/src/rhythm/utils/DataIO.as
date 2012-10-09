package rhythm.utils
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class DataIO extends EventDispatcher
	{
		public function DataIO(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}