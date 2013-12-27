// TileBreeze, a Tilesheet generator.
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
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import mx.events.ItemClickEvent;
	
	/**
	 * Receives and handles user input.
	 */
	public class Controller
	{
		private var _main:Main;
		
		/**
		 * Controller constructor.
		 * @param	main	Reference to the <code>Main</code> object.
		 */
		public function Controller(main:Main) 
		{
			_main = main;
		}
		
		// INPUT: Folder buttons
		/**
		 * btnColorFolder click event.
		 * @param	e	Mouse event.
		 */
		public function onBtnColorFolderClick(e:MouseEvent):void 
		{
			_main.filesystem.colorFolder = _main.filesystem.selectFolder();
			_main.filesystem.colorFolder.addEventListener(Event.SELECT, onColorFolderSelected);
		}
		/**
		 * btnAlphaFolder click event.
		 * @param	e	Mouse event.
		 */
		public function onBtnAlphaFolderClick(e:MouseEvent):void 
		{
			_main.filesystem.alphaFolder = _main.filesystem.selectFolder();
			_main.filesystem.alphaFolder.addEventListener(Event.SELECT, onAlphaFolderSelected);
		}
		/**
		 * btnShadowFolder click event.
		 * @param	e	Mouse event.
		 */
		public function onBtnShadowFolderClick(e:MouseEvent):void 
		{
			_main.filesystem.shadowFolder = _main.filesystem.selectFolder();
			_main.filesystem.shadowFolder.addEventListener(Event.SELECT, onShadowFolderSelected);
		}
		
		public function onBtnColorFolderUnload(e:MouseEvent):void
		{
			// Remove file reference
			if (_main.filesystem.colorFolder) {
				_main.filesystem.colorFolder = null;
				View.log(this, "Color removed.");
			}
			
			_main.filesystem.dispatchEvent(new FilesystemEvent(FilesystemEvent.COLOR_FOLDER_DESELCTED));
		}
		
		public function onBtnAlphaFolderUnload(e:MouseEvent):void
		{
			if (_main.filesystem.alphaFolder) {
				_main.filesystem.alphaFolder = null;
				View.log(this, "Alpha removed.");
			}
			_main.filesystem.dispatchEvent(new FilesystemEvent(FilesystemEvent.ALPHA_FOLDER_DESELCTED));
		}
		
		public function onBtnShadowFolderUnload(e:MouseEvent):void
		{
			if (_main.filesystem.shadowFolder) {
				_main.filesystem.shadowFolder = null;
				View.log(this, "Shadow removed.");
			}
			_main.filesystem.dispatchEvent(new FilesystemEvent(FilesystemEvent.SHADOW_FOLDER_DESELCTED));
		}
		
		/**
		 * Loads a fixed set of files for debugging purposes.
		 * @param	e	Mouse event.
		 */
		public function debugLoadFiles(e:Event):void
		{
			_main.filesystem.colorFolder = new File("C:\\Users\\User\\Desktop\\tilebreeze\\Exampletiles\\MasterBeauty");
			_main.filesystem.dispatchEvent(new FilesystemEvent(FilesystemEvent.COLOR_FOLDER_SELCTED));
			
			_main.filesystem.alphaFolder = new File("C:\\Users\\User\\Desktop\\tilebreeze\\Exampletiles\\matte");
			_main.filesystem.dispatchEvent(new FilesystemEvent(FilesystemEvent.ALPHA_FOLDER_SELCTED));
			
			_main.filesystem.shadowFolder = new File("C:\\Users\\User\\Desktop\\tilebreeze\\Exampletiles\\shadowRaw");
			_main.filesystem.dispatchEvent(new FilesystemEvent(FilesystemEvent.SHADOW_FOLDER_SELCTED));
		}
		
		
		// HANDLERS: Folder select
		/**
		 * Color folder selected event.
		 * @param	e Mouse event.
		 */
		private function onColorFolderSelected(e:Event):void 
		{
			_main.filesystem.dispatchEvent(new FilesystemEvent(FilesystemEvent.COLOR_FOLDER_SELCTED));
		}
		/**
		 * Alpha folder selected event.
		 * @param	e Mouse event.
		 */
		private function onAlphaFolderSelected(e:Event):void 
		{
			_main.filesystem.dispatchEvent(new FilesystemEvent(FilesystemEvent.ALPHA_FOLDER_SELCTED));
		}
		/**
		 * Shadow folder selected event.
		 * @param	e Mouse event.
		 */
		private function onShadowFolderSelected(e:Event):void 
		{
			_main.filesystem.dispatchEvent(new FilesystemEvent(FilesystemEvent.SHADOW_FOLDER_SELCTED));
		}
		
		
		// GENERATE: Controls
		/**
		 * btnGenerate click event.
		 * @param	e Mouse event.
		 */
		public function onBtnGenerateClick(e:MouseEvent):void
		{
			_main.generator.generate();
		}
		
		
		// SAVE: Button
		/**
		 * btnSave click event.
		 * @param	e Mouse event.
		 */
		public function onBtnSaveClick(e:MouseEvent):void
		{
			_main.filesystem.selectDataDestination();
		}
		
		
		// PREVIEW: Tab
		/**
		 * Dispatched when a tab on the preview pane has been clicked.
		 * @param	e Mouse event.
		 */
		public function onTabPreviewClick(e:ItemClickEvent):void
		{
			var p:Preview = _main.preview;
			p.activeTilesheet = e.index;
			
			switch(e.index)
			{
				// Full
				case 0:
					p.showTilesheet(p.output);
					View.controls["cnvFull"].addChild(View.controls["imgHolder"]);
					break;
				
				// Animated
				case 1:
					p.showTilesheet(p.animated);
					View.controls["cnvAnimated"].addChild(View.controls["imgHolder"]);
					break;
				
				// Color
				case 2:
					p.showTilesheet(p.color);
					View.controls["cnvColor"].addChild(View.controls["imgHolder"]);
					break;
				
				// Alpha + Shadow
				case 3:
					p.showTilesheet(p.alphaShadow);
					View.controls["cnvAlphaShadow"].addChild(View.controls["imgHolder"]);
					break;
				
				// Alpha
				case 4:
					p.showTilesheet(p.matte);
					View.controls["cnvAlpha"].addChild(View.controls["imgHolder"]);
					break;
				
				// Shadow
				case 5:
					p.showTilesheet(p.shadow);
					View.controls["cnvShadow"].addChild(View.controls["imgHolder"]);
					break;
			}
		}
	}

}