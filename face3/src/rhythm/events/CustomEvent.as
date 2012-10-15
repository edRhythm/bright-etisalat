package rhythm.events
{
		
		import flash.events.Event;
		
		
		/**
		 *	Custom Event Class.
		 *
		 *	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *
		 *	@author Ed Baldry
		 *	@since  11.01.2010
		 */
		
		public class CustomEvent extends Event
		{
			//--------------------------------------
			// CLASS CONSTANTS
			//--------------------------------------
			public static const CAMERA_FOUND:String="CAMERA_FOUND";			
			public static const INPUT_CANCELLED:String="INPUT_CANCELLED";	
			public static const INPUT_COMPLETE:String="INPUT_COMPLETE";			
			public static const KEY_PRESSED:String = "KEY_PRESSED";
			public static const DATA_READY:String = "DATA_READY";
			public static const TWEETBOX_READY:String = "TWEETBOX_READY";
			public static const SHOW_BANNER:String = "SHOW_BANNER";
			public static const CLOSE_3D_MESSAGE:String = "CLOSE_3D_MESSAGE";
			public static const DEBUG_MESSAGE:String = "DEBUG_MESSAGE";
			public static const SAVER_STOPPED:String = "SAVER_TIMED_OUT";
			
			public static const RESET_ALL_PLANES:String = "RESET_ALL_PLANES";
			public static const DISABLE_ALL_PLANES:String = "DISABLE_ALL_PLANES";
			public static const ENABLE_ALL_PLANES:String = "ENABLE_ALL_PLANES";
			public static const ADD_STAGE_MOUSEDOWN:String = "ADD_STAGE_MOUSEDOWN";

			/**
			 * A text message that can be passed to an event handler
			 * with this event object.
			 */
			
			public var params:Object;
			public var id:int;
			
			//--------------------------------------
			//  CONSTRUCTOR
			//--------------------------------------
			
			
			/**
			 *	@Constructor
			 */
			public function CustomEvent($type:String, $bubbles:Boolean = false, $cancelable:Boolean = false, $params:Object = null, $id:int = undefined)
			{
				super($type, $bubbles, $cancelable);
				params =  $params;
				id = $id;
			};
			
			public override function clone():Event
			{
				return new CustomEvent(type, bubbles, cancelable, params, id);
			};
			
			/**
			 * Returns a String containing all the properties of the current instance.
			 * @return A string representation of the current instance.
			 */
			public override function toString():String
			{
				return formatToString("CustomEvent", "type", "bubbles", "cancelable", "eventPhase", "params", "id");
			};
		};
	};
