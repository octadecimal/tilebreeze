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
	import com.voidelement.images.BMPDecoder;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	/**
	 * Generator class, handles the generation of tiles and tilesheets.
	 */
	public class Generator implements IDimensional
	{
		/**
		 * Binary bitmap decoder.
		 */
		public static var decoder:BMPDecoder = new BMPDecoder();
		
		/**
		 * The global bounds for every tile; encapsulates Color, Alpha and Shadow channels.
		 */
		private var _bounds:Rectangle = new Rectangle();
		public function get bounds():Rectangle { return _bounds; }
		public function set bounds(r:Rectangle):void { _bounds = r; }
		
		/**
		 * Tiles array.
		 */
		public function get tiles():Array { return _tiles; }
		private var _tiles:Array, _tilesColor:Array, _tilesAlpha:Array, _tilesShadow:Array;
		
		/**
		 * Tilesheets array.
		 */
		public var tilesheets:Array;
		private var _tsColor:Tilesheet, _tsAlpha:Tilesheet, _tsShadow:Tilesheet;
		
		/**
		 * Set to true if successfully generated.
		 */
		public var generated:Boolean = false;
		
		/**
		 * State memory
		 */
		private var _tilesTotal:uint, _tilesLoaded:uint;
		private var _startTime:int;
		
		/**
		 * Reference to Main.
		 */
		private var _main:Main;
		
		
		/**
		 * Constructor.
		 * @param	main Reference to the <code>Main</code> object.
		 */
		public function Generator(main:Main) 
		{
			_main = main;
		}
		
		
		/**
		 * Begins generation routine; loads tiles from their respective folders.
		 */
		public function generate():void
		{
			with (_main.filesystem)
			{
				if (!colorFolder && !alphaFolder && !shadowFolder) {
					View.log(this, "ERROR: Requires at least one channel to generate. Please select a folder under the Import tab.");
					View.controls["tabOptions"].selectedIndex = 0;
					return;
				}
			}
			
			var fs:Filesystem = _main.filesystem;
			var i:uint = 0, c:uint = 0;
			var t:Tile;
			_startTime = getTimer();
			
			View.log(this, "============================================");
			View.log(this, "Generating...");
			View.log(this, "============================================");
			
			// Reset
			_tilesLoaded = _tilesTotal = 0;
			_tiles = new Array(); _tilesColor = new Array(); _tilesAlpha = new Array(); _tilesShadow = new Array(); tilesheets = new Array();
			
			// Generate tiles
			if (fs.colorFolder)  _tilesColor  = generateTilesFromFolder(fs.colorFolder, fs.colorFiles);
			if (fs.alphaFolder)  _tilesAlpha  = generateTilesFromFolder(fs.alphaFolder, fs.alphaFiles);
			if (fs.shadowFolder) _tilesShadow = generateTilesFromFolder(fs.shadowFolder, fs.shadowFiles);
		}
		
		
		/**
		 * Creates <code>Tile</code> objects from the files contained contained in the passed <code>folder</code>.
		 * @param	folder		The folder to create <code>File</code> objects from.
		 * @param	filesTarget	The <code>files</code> to save the files in.
		 * @return
		 */
		private function generateTilesFromFolder(folder:File, filesTarget:Array):Array
		{
			var output:Array = new Array();
			
			// Get files
			filesTarget = _main.filesystem.getFiles(folder);
			_tilesTotal += filesTarget.length;
			
			// Create tiles
			for (var i:uint = 0, c:uint = filesTarget.length; i < c; i++) {
				var t:Tile = new Tile(filesTarget[i].nativePath, onTileLoaded); 
				_tiles.push(t);
				output.push(t);
			}
			
			return output;
		}
		
		
		/**
		 * Called when an individual <code>Tile</code> has been loaded and successfully built.
		 */
		private function onTileLoaded(tile:Tile):void
		{
			//View.log(this, "Tile created: "+tile.path);
			_tilesLoaded++;
			View.controls["progressBar"].label = _tilesLoaded+"/"+_tilesTotal+" ("+Number((_tilesLoaded/_tilesTotal)*100).toFixed(0)+"%)";
			View.progress(_tilesLoaded / _tilesTotal);
			if (_tilesLoaded == _tilesTotal) onTilesLoaded();
		}
		
		
		/**
		 * Called when all <code>Tile</code> objects have been fully loaded and successfully built.
		 */
		private function onTilesLoaded():void
		{
			View.log(this, "All tiles loaded.");
			
			// Derive bounds to alpha and shadow
			if (_tilesAlpha) trimR(bounds, _tilesAlpha);
			if (_tilesAlpha) growR(bounds, _tilesShadow);
			
			// Generate tilesheets
			generateTilesheets();
			
			// Add preview pane
			View.controls["imgHolder"].addChild(_main.preview);
			
			// Show last shown tilesheet
			switch(_main.preview.activeTilesheet) {
				case 0: _main.preview.showTilesheet(_main.preview.output); break;
				case 1: _main.preview.showTilesheet(_main.preview.animated); break;
				case 2: _main.preview.showTilesheet(_main.preview.color); break;
				case 3: _main.preview.showTilesheet(_main.preview.alphaShadow); break;
				case 4: _main.preview.showTilesheet(_main.preview.matte); break;
				case 5: _main.preview.showTilesheet(_main.preview.shadow); break;
			}
			
			// Post-process
			generated = true;
			View.progress(0);
			View.controls["progressBar"].label = "READY";
			View.log(this, "============================================");
			View.log(this, "Generated. (" + (getTimer() - _startTime) + "ms)");
			View.log(this, "============================================");
		}
		
		
		/**
		 * Generates all tilesheets.
		 */
		private function generateTilesheets():void
		{
			View.log(this, "Generating tilesheets...");
			
			// Create user tilesheets
			if (_tilesColor.length  > 0) _main.preview.color  = Tilesheet.createFromTiles(_tilesColor);
			if (_tilesAlpha.length  > 0) _main.preview.matte  = Tilesheet.createFromTiles(_tilesAlpha);
			if (_tilesShadow.length > 0) _main.preview.shadow = Tilesheet.createFromTiles(_tilesShadow);
			
			/*View.log(this, "f" + _bounds.toString() +
							", c" + _main.preview.color.bounds.toString() +
							", a" + _main.preview.matte.bounds.toString() +
							", s" + _main.preview.shadow.bounds.toString());*/
			
			// Center shadow by alpha (not right)
			//_main.preview.shadow.copyPoint.x = (_main.preview.matte.bounds.width  - _main.preview.shadow.bounds.width) / 2;
			//_main.preview.shadow.copyPoint.y = (_main.preview.matte.bounds.height - _main.preview.shadow.bounds.height);
			//_main.preview.shadow.bounds = _main.preview.matte.bounds.clone();
			//_main.preview.shadow.draw();
			
			// Create alpha+shadow tilesheet
			if (_main.preview.matte && _main.preview.shadow) {
				_main.preview.alphaShadow = Tilesheet.createFromTilesheets([_main.preview.matte, _main.preview.shadow]);
				_main.preview.alphaShadow.lightenPass();
			}
			
			// Create final output tilesheet
			if (_main.preview.matte) {
				_main.preview.color.bounds.x = bounds.left;
				_main.preview.color.bounds.y = bounds.top;
				_main.preview.color.draw();
				_main.preview.output = Tilesheet.createFromTilesheets([_main.preview.color, _main.preview.alphaShadow]);
				_main.preview.output.alphaPass();
			}
			
			// Create animated preview tilesheet
			_main.preview.animated = new Tilesheet();
			_main.preview.animated.buffer = new BitmapData(_main.preview.color.width, _main.preview.color.height, true, 0x0);
			_main.preview.animated.width = _main.preview.animated.buffer.width;
			_main.preview.animated.height = _main.preview.animated.buffer.height;
			
			View.log(this, "Tilesheets generated.");
		}
		
		
		
		/**
		 * Shrinks the target rectangle to be, at most, as large as the largest input list items.
		 */
		static public function trimR(target:Rectangle, list:Array):void
		{
			target.left = target.top = Number.MAX_VALUE;
			target.right = target.bottom = 0;
			
			for (var i:uint = 0; i < list.length; i++)
				trim(target, list[i].bounds);
		}
		
		/**
		 * Trims the target rectangle to be, at most, as large as the source rectangle.
		 */
		static public function trim(target:Rectangle, source:Rectangle):void
		{
			if (source.left   < target.left)   target.left   = source.left;
			if (source.right  > target.right)  target.right  = source.right;
			if (source.top    < target.top)    target.top    = source.top;
			if (source.bottom > target.bottom) target.bottom = source.bottom;
		}
		
		
		/**
		 * Expands the target rectangle to be, at least, as small as the smallest input list items.
		 */
		static public function growR(target:Rectangle, list:Array):void
		{
			for (var i:uint = 0; i < list.length; i++)
				grow(target, list[i].bounds);
		}
		
		/**
		 * Expands the target rectangle to be, at least, as small as the source rectangle.
		 */
		static public function grow(target:Rectangle, source:Rectangle):void
		{
			if (source.left   < target.left)   target.left   = source.left;
			if (source.right  > target.right)  target.right  = source.right;
			if (source.top    < target.top)    target.top    = source.top;
			if (source.bottom > target.bottom) target.bottom = source.bottom;
		}
	}
}