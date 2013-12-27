// TileBreeze, a tilesheet generator.
// Copyright (C) 2010 Dylan Heyes <dylan@octadecimal.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


package com.octadecimal.tilebreeze 
{
	import flash.events.Event;
	import mx.controls.Button;
	import mx.controls.ProgressBar;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.core.WindowedApplication;
	import mx.events.FlexEvent;
	
	/**
	 * Directly associated with the MXML form, responsible for drawing and updating
	 * form controls.
	 */
	public class View
	{
		private var _main:Main;
		private var _filesystem:Filesystem;
		
		/**
		 * An array of all controls embedded in the MXML form.
		 */
		public static var controls:WindowedApplication;
		
		/**
		 * View constructor.
		 * @param	main	Reference to the <code>Main</code> object.
		 * @param	form	Reference to the MXML form.
		 */
		public function View(main:Main, form:WindowedApplication) 
		{
			_main = main;
			_filesystem = main.filesystem;
			View.controls = form as WindowedApplication;
			
			// Listen for events
			_filesystem.addEventListener(FilesystemEvent.COLOR_FOLDER_SELCTED, onColorFolderSelected);
			_filesystem.addEventListener(FilesystemEvent.ALPHA_FOLDER_SELCTED, onAlphaFolderSelected);
			_filesystem.addEventListener(FilesystemEvent.SHADOW_FOLDER_SELCTED, onShadowFolderSelected);
			_filesystem.addEventListener(FilesystemEvent.COLOR_FOLDER_DESELCTED, onColorFolderDeselected);
			_filesystem.addEventListener(FilesystemEvent.ALPHA_FOLDER_DESELCTED, onAlphaFolderDeselected);
			_filesystem.addEventListener(FilesystemEvent.SHADOW_FOLDER_DESELCTED, onShadowFolderDeselected);
		}
		
		
		/**
		 * Writes output to the log console text.
		 * @param	caller	Object writing to the log.
		 * @param	msg		String to be output.
		 */
		public static function log(caller:Object, msg:String):void
		{
			var output:String = caller + " > " + msg;
			var txt:TextArea = controls["txtLog"] as TextArea;
			txt.text = " > " + msg + "\n" + txt.text;
			//trace(output);
		}
		
		
		/**
		 * Updates the progress bar value on the Generate form.
		 * @param	value	Value to be displayed <code>(0->1.0)</code>.
		 */
		public static function progress(value:Number):void
		{
			ProgressBar(controls["progressBar"]).setProgress(value, 1.0);
		}
		
		
		/**
		 * Dispatched when the Color folder has been selected. Draws and updates form elements.
		 * @param	e Event object.
		 */
		private function onColorFolderSelected(e:Event):void 
		{
			// Enable unload button.
			controls["btnColorFolderUnload"].enabled = true;
			
			// Write folder name to button label.
			controls["btnColorFolder"].label = _filesystem.getFolderName(_filesystem.colorFolder);
			
			// Save last opened folder.
			_filesystem.lastOpenedFolder = _main.filesystem.colorFolder.nativePath;
			
			// Show generate form if all Folder fields are filled.
			//if (_main.filesystem.colorFolder && _main.filesystem.alphaFolder && _main.filesystem.shadowFolder)
				//View.controls["tabOptions"].selectedIndex = 1;
			
			// Log output
			log(this, "Color source folder: " + _filesystem.colorFolder.nativePath);
		}
		
		/**
		 * Dispatched when the Alpha folder has been selected. Draws and updates form elements.
		 * @param	e Event object.
		 */
		private function onAlphaFolderSelected(e:Event):void 
		{
			// Enable unload button.
			controls["btnAlphaFolderUnload"].enabled = true;
			
			// Write folder name to button label.
			controls["btnAlphaFolder"].label = _filesystem.getFolderName(_filesystem.alphaFolder);
			
			// Save last opened folder.
			_filesystem.lastOpenedFolder = _main.filesystem.alphaFolder.nativePath;
			
			// Show generate form if all Folder fields are filled.
			//if (_main.filesystem.colorFolder && _main.filesystem.alphaFolder && _main.filesystem.shadowFolder)
				//View.controls["tabOptions"].selectedIndex = 1;
				
			// Log output
			log(this, "Alpha source folder: " + _filesystem.alphaFolder.nativePath);
		}
		
		/**
		 * Dispatched when the Shadow folder has been selected. Draws and updates form elements.
		 * @param	e Event object.
		 */
		private function onShadowFolderSelected(e:Event):void 
		{
			// Enable unload button.
			controls["btnShadowFolderUnload"].enabled = true;
			
			// Write folder name to button label.
			controls["btnShadowFolder"].label = _filesystem.getFolderName(_filesystem.shadowFolder);
			
			// Save last opened folder.
			_filesystem.lastOpenedFolder = _main.filesystem.shadowFolder.nativePath;
			
			// Show generate form if all Folder fields are filled.
			if (_main.filesystem.colorFolder && _main.filesystem.alphaFolder && _main.filesystem.shadowFolder)
				View.controls["tabOptions"].selectedIndex = 1;
				
			// Log output
			log(this, "Shadow source folder: " + _filesystem.shadowFolder.nativePath);
		}
		
		
		private function onColorFolderDeselected(e:FilesystemEvent):void 
		{
			// Disable button
			View.controls["btnColorFolderUnload"].enabled = false;
			
			// Reset button label
			View.controls["btnColorFolder"].label = "(none)";
		}
		
		private function onAlphaFolderDeselected(e:FilesystemEvent):void 
		{
			// Disable button
			View.controls["btnAlphaFolderUnload"].enabled = false;
			
			// Reset button label
			View.controls["btnAlphaFolder"].label = "(none)";
		}
		
		private function onShadowFolderDeselected(e:FilesystemEvent):void 
		{
			// Disable button
			View.controls["btnShadowFolderUnload"].enabled = false;
			
			// Reset button label
			View.controls["btnShadowFolder"].label = "(none)";
		}
	}

}