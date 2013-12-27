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
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import mx.controls.Button;
	
	/**
	 * FileSystem model, handles all file system reading and writing.
	 */
	public class Filesystem extends EventDispatcher
	{
		/**
		 * The selected Color folder; <code>null</code> if none selected.
		 */
		public var colorFolder:File;
		
		/**
		 * The selected Alpha folder; <code>null</code> if none selected.
		 */
		public var alphaFolder:File;
		
		/**
		 * The selected Shadow folder; <code>null</code> if none selected.
		 */
		public var shadowFolder:File;
		
		/**
		 * List of <code>File</code> objects inside of <code>colorFolder</code>.
		 */
		public var colorFiles:Array;
		
		/**
		 * List of <code>File</code> objects inside of <code>alphaFolder</code>.
		 */
		public var alphaFiles:Array; 
		
		/**
		 * List of <code>File</code> objects inside of <code>shadowFolder</code>.
		 */
		public var shadowFiles:Array;
		
		/**
		 * Reference to the last opened folder, used for subsequent folder open dialogs.
		 */
		public var lastOpenedFolder:String;
		
		/**
		 * Reference to Main.
		 */
		private var _main:Main;
		
		
		/**
		 * Filesystem constructor.
		 * @param	main	Reference to the <code>Main</code> object.
		 */
		public function Filesystem(main:Main) 
		{
			_main = main;
		}
		
		/**
		 * Selects a folder and returns the the folder directory as a <code>File<code> object.
		 * @return	The folder as a File object.
		 */
		public function selectFolder():File
		{
			var folder:File = new File();
			if(lastOpenedFolder) folder.nativePath = lastOpenedFolder;
			folder.browseForDirectory("Choose input folder.");
			return folder;
		}
		
		/**
		 * Retrieves a list of <code>*.bmp</code> filtered <code>File</code> objects 
		 * inside of the passed folder.
		 * @param	folder	The folder to load files from.
		 * @return			List of filtered <code>File</code> objects.
		 */
		public function getFiles(folder:File):Array
		{
			return filterByExtension("bmp", folder.getDirectoryListing());
		}
		
		/**
		 * Returns an array of <code>File</code> objects that matches the passed file extension.
		 * @param	extension	File extension to be filtered by.
		 * @param	files		Input array of Files.
		 * @return				An array of File objects with the matching file extension.
		 */
		public function filterByExtension(extension:String, files:Array):Array
		{
			for (var i:uint = 0, c:uint = files.length, output:Array = new Array(); i < c; i++)
				if (getFileExtension(files[i] as File) == extension)
					output.push(files[i]);
				else View.log(this, "Skipped: " + File(files[i]).nativePath);
			return output;
		}
		
		/**
		 * Returns the file extension for the passed File object.
		 * @param	file
		 * @return
		 */
		public function getFileExtension(file:File):String
		{
			var words:Array = file.nativePath.split(".");
			return words[words.length - 1];
		}
		
		/**
		 * Returns the selected folder name from an input <code>File</code> object.
		 * @param	file	Input <code>File</code> object from which to read the folder name from.
		 * @return	The selected folder name.
		 */
		public function getFolderName(file:File):String
		{
			var words:Array = file.url.split("/");
			return words[words.length - 1];
		}
		
		/**
		 * Presents the user with a dialog that selects the file save location.
		 */
		public function selectDataDestination():void
		{
			var desktop:File = File.desktopDirectory;
			
			try {
				desktop.browseForSave("Save As");
				desktop.addEventListener(Event.SELECT, save);
			}
			catch (e:Error) {
				View.log(this, "Error saving file: "+e.message);
			}
		}
		
		/**
		 * Saves the bitmap buffer contained in <code>com.octadecimal.tilebreeze.preview.output</code>
		 * to a file on the user's filesystem. Called after a successful call to <code>selectDataDestination()</code>.
		 * @param	e
		 */
		private function save(e:Event):void
		{
			
			var file:File = e.target as File;
			
			var extension:String = "png";
			var len:int = (getFileExtension(file) != null) ? getFileExtension(file).length : 0;
			
			// Handle file extension
			if (len)
				file.nativePath = file.nativePath.substr(0, file.nativePath.length - len) + extension;
			else
				file.nativePath += "." + extension;
			
			// Ensure buffer exists
			if (_main.preview.output.buffer == null) {
				View.log(this, "Attempted to write to null output buffer.");
				return;
			}
			
			// Write png
			View.log(this, "Writing tilesheet: "+file.nativePath);
			var bytes:ByteArray = PNGEncoder.encode(_main.preview.output.buffer);
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(bytes);
			stream.close();
			
			View.log(this, "Tilesheet saved."); 
			
			// Encode metadata
			if (View.controls["chkEncodeMetadata"].selected)
			{
				var metadataPath:String = file.nativePath.split(".png")[0] + ".xml";
				var metadata:File = new File(metadataPath);
				View.log(this, "Writing metadata: "+metadata.nativePath);
				
				var tilesheet:Tilesheet = _main.generator.tilesheets[0];
				var xml:String = '<tilesheet rows="'+tilesheet.rows+'" cols="'+tilesheet.cols+'" tileWidth="'+tilesheet.tileWidth+'" tileHeight="'+tilesheet.tileHeight+'" tilesPerClip="TODO">';
				xml += '\n</tilesheet>';
				
				var xmlOut:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + xml;
				
				View.log(this, "metadata output:\n"+ xmlOut);
				
				var fs:FileStream = new FileStream();
				fs.open(metadata, FileMode.WRITE);
				fs.writeUTFBytes(xmlOut);
				fs.close(); 
				
				View.log(this, "Metadata written.");
			}
		}
	}

}