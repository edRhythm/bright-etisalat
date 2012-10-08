package rhythm.displayObjects
{
	import flash.display.MovieClip;

	public class SelectableButton extends MovieClip
	{
		private var isSelected:Boolean = false;
		
		public function SelectableButton()
		{
		}
		
		public function set selectedState($selected:Boolean):void
		{			
			isSelected = $selected;
		}
			
		
		public function toggleSelected():void
		{
			switch (isSelected)
			{
				case true:
					gotoAndStop("deselected");
					isSelected = false;
				break;
				case false:
					gotoAndStop("selected");
					isSelected = true;
				break;
			}
		}
		
		public function get selectedState():Boolean
		{
			return isSelected;
		}
	}
}