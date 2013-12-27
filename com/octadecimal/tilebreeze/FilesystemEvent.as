package com.octadecimal.tilebreeze 
{
	import flash.events.Event;
	
	/**
	 * An event associated with a change or update in the Filesystem and it's components.
	 */
	public class FilesystemEvent extends Event 
	{
		public static const COLOR_FOLDER_SELCTED:String = "colorFolderSelected";
		public static const ALPHA_FOLDER_SELCTED:String = "alphaFolderSelected";
		public static const SHADOW_FOLDER_SELCTED:String = "shadowFolderSelected";
		public static const COLOR_FOLDER_DESELCTED:String = "colorFolderDeselected";
		public static const ALPHA_FOLDER_DESELCTED:String = "alphaFolderDeselected";
		public static const SHADOW_FOLDER_DESELCTED:String = "shadowFolderDeselected";
		
		
		
		public function FilesystemEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new FilesystemEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FilesystemEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}