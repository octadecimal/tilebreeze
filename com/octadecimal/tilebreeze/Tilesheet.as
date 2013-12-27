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
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * A collection of <code>Tile</code> or <code>Tilesheet</code> objects ordered and drawn in a grid arrangement.
	 * <p>Any and all <code>Tilesheet</code> objects are created after all Tiles have been loaded and built.</p>
	 * <p>If <code>Tilesheet</code> objects are used as input,  <code>alphPass()</code> and
	 * <code>lightenPass()</code> can be used to perform color operations.</p><p>When applying color operations,
	 * <code>tilesheets[0]</code> will be the target of the operations, while all remaining 
	 * <code>Tilesheet</code> objects in <code>tilesheets</code> will be used as input,
	 * applied recursively to <code>tilesheets[0]</code>.This, for example, allows you you to easily
	 * use multiple images as a source for an alpha channel or merging multiple tilesheets into one.</p>
	 */
	public class Tilesheet implements IDimensional
	{
		/**
		 * The bitmap buffer.
		 */ public var buffer:BitmapData;
		
		/**
		 * Source array of <code>Tile</code> objects.
		 */ public var tiles:Array;
		
		/**
		 * Source array of <code>Tilesheet</code> objects.
		 */ public var tilesheets:Array;
		
		/**
		 * Dimensional bounds.
		 */ public function get bounds():Rectangle { return _bounds; }
		    public function set bounds(r:Rectangle):void { _bounds = r; }
		    private var _bounds:Rectangle = new Rectangle();
		
		/**
		 * Number of generated rows for this <code>Tilesheet</code>
		 */ public var rows:uint;
		
		/**
		 * Number of generated columns for this <code>Tilesheet</code>
		 */ public var cols:uint;
		
		/**
		 * The total width of this <code>Tilesheet</code>: <code>(cols x tileWidth)</code>
		 */ public var width:uint;
		
		/**
		 * The total height of this <code>Tilesheet</code>: <code>(rows x tileHeight)</code>
		 */ public var height:uint;
		
		/**
		 * The unmodified input width for the tiles in the <code>tiles</code> array.
		 */ public var tileWidth:uint;
		
		/**
		 * The unmodified input width for the tiles in the <code>tiles</code> array.
		 */ public var tileHeight:uint;
		
		/**
		 * State memory
		 */ private var _bestRows:Array=new Array(), _bestCols:Array=new Array();
		
		
		/**
		 * Constructor.
		 */
		public function Tilesheet() 
		{
			tileWidth = Main.instance.generator.bounds.width;
			tileHeight = Main.instance.generator.bounds.height;
		}
		
		
		/**
		 * Creates and returns a new <code>Tilesheet</code> that uses an array of <code>Tile</code> objects as input.
		 * @param	tiles Source array of tiles.
		 * @return		  The created <code>Tilesheet</code>
		 */
		static public function createFromTiles(tiles:Array):Tilesheet
		{
			var t:Tilesheet = new Tilesheet();
			t.buildFromTiles(tiles);
			//Main.instance.generator.tiles.push(t);
			Main.instance.generator.tilesheets.push(t);
			return t;
		}
		
		/**
		 * Creates and returns a new <code>Tilesheet</code> that uses an array of <code>Tilesheets</code> objects
		 * as input and saves each to their own channel for later color processing operations to take place.
		 * @param	tilesheets
		 * @return
		 */
		static public function createFromTilesheets(tilesheets:Array):Tilesheet
		{
			var t:Tilesheet = new Tilesheet();
			t.buildFromTilesheets(tilesheets);
			Main.instance.generator.tilesheets.push(t);
			return t;
		}
		
		/**
		 * Builds this <code>Tilesheet</code> object from the <code>Tiles</code> array.
		 * @param	tilesheets
		 */public function buildFromTiles(tiles:Array):void
		{
			// Save tiles ref
			this.tiles = tiles;
			
			// Determine optimal dimensions
			generateDimensions();
			
			// Determine bounds
			Generator.trimR(_bounds, tiles);
			
			// Create buffer
			try   { buffer = new BitmapData(width, height, true, 0x0); }
			catch(e:ArgumentError) {
				View.log(this, "Error creating Tilesheet bitmap with: width=" + width + " height=" + height);
			}
			
			// Draw
			draw();
		}
		
		/**
		 * Builds this <code>Tilesheet</code> object from the <code>Tilesheets</code> array.
		 * @param	tilesheets
		 */
		public function buildFromTilesheets(tilesheets:Array):void
		{ 
			// Save tilesheets ref
			this.tilesheets = tilesheets; 
			
			// Dimensions
			for (var i:uint = 0; i < tilesheets.length; i++)
			{
				if (tilesheets[i].width  > width)  width = tilesheets[i].width;
				if (tilesheets[i].height > height) height = tilesheets[i].height;
			}
			
			// Create buffer
			buffer = new BitmapData(width, height, false, 0x0);
			
			// Draw first tilesheet
			var t:Tilesheet = tilesheets[0];
			buffer.draw(t.buffer);
		}
		
		
		/**
		 * Finds the optimal grid arrangement.
		 */
		private function generateDimensions():void
		{
			var c:int, pixels:int, pixelsWide:int, pixelsHigh:int, pixelsBest:int;
			
			// Loop through all possible factors
			for (var r:int = 1, len:int = tiles.length; r < len; r++)
			{
				// Factor
				c = Math.ceil(tiles.length / r);
				
				// Calculate pixel counts
				pixelsWide = c * tileWidth;
				pixelsHigh = r * tileHeight;
				pixels = pixelsWide * pixelsHigh;
				
				// Check for preferred square
				if (pixelsWide == pixelsHigh && View.controls["chkPreferSquare"].selected)
				{
					rows = r;
					cols = c;
					View.log(this, "Square found, using: "+rows+","+cols+" "+(cols*tileWidth)+"x"+(rows*tileHeight)+" "+(Number(pixels/1024000)*4).toFixed(2)+"mb.");
					break;
				}
				
				// Check for lower pixel count
				if (pixels < pixelsBest || pixelsBest == 0)
					if (pixelsWide < 2880 && pixelsHigh < 2880)
					{
						// Save better data
						pixelsBest = pixels;
						
						// Create new arrays for this pixel count
						_bestRows = new Array();
						_bestCols = new Array();
					} 
				
				// Check if pixel count matches best
				if (pixels == pixelsBest)
				{
					// Save row,col combo
					_bestRows.push(r);
					_bestCols.push(c);
				}
			}
			
			// Loop through candidates and find most square match
			var candidateOutput:String = "";
			var distance:int, bestDistance:int=int.MAX_VALUE, bestIndex:int;
			for (var i:uint = 0; i < _bestRows.length; i++)
			{
				if (View.controls["chkPreferSquare"].selected) 
					distance = _bestCols[i] - _bestRows[i];
				else 
					distance = _bestCols[i]*tileWidth - _bestRows[i]*tileHeight;
				
				if (Math.abs(distance) < bestDistance && distance >= 0) {
					bestIndex = i;
					bestDistance = Math.abs(distance);
				}
				candidateOutput += _bestRows[i] + "," + _bestCols[i] + "("+distance+")  ";
			}
			
			// Use best candidate
			rows = _bestRows[bestIndex];
			cols = _bestCols[bestIndex];
			
			// Derive tilesheet dimensions
			width = cols * tileWidth;
			height = rows * tileHeight;
			
			// Post-process
			View.log(this, "Best grid candidates: " + candidateOutput);
			View.log(this, "Optimal grid size: "+rows+"x"+cols+" "+width+"x"+height+" "+(Number(pixels/1024000)*4).toFixed(2)+"mb.");
		}
		
		
		/**
		 * Performs a lighten pass on the first passed tilesheet in <code>tilesheets</code>, using all remaining
		 * tilesheets in <code>tilesheets</code> as input for the color operation.
		 */
		public function lightenPass():void
		{
			// Lighten remaining tilesheets
			for (var i:uint = 1; i < tilesheets.length; i++) {
				var t:Tilesheet = tilesheets[i];
				View.log(this, "Merging channels: "+i+"->0");
				buffer.draw(t.buffer, null, null, BlendMode.ADD);
			}
		}
		
		/**
		 * Performs an alpha pass on the first passed tilesheet in <code>tilesheets</code>, using all remaining
		 * tilesheets in <code>tilesheets</code> as input for the color operation.
		 */
		public function alphaPass():void
		{
			// Recreate buffer as transparent
			buffer = new BitmapData(buffer.width, buffer.height, true, 0x0);
			var t:Tilesheet = tilesheets[0];
			buffer.draw(t.buffer);
			
			for (var i:uint = 1; i < tilesheets.length; i++)
			{
				t = tilesheets[i];
				View.log(this, "Copying channel to alpha: "+i+"->0");
				buffer.copyChannel(t.buffer, new Rectangle(0, 0, width, height), new Point(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			}
		}
		
		
		/**
		 * Draws this <code>Tilesheet</code> to the screen.
		 */
		public function draw():void
		{
			if (tiles && buffer) {
				for (var row:uint = 0; row < rows; row++)
					for (var col:uint = 0; col < cols; col++)
						buffer.copyPixels(tiles[(row*cols)+col].buffer, Main.instance.generator.bounds, new Point(col*tileWidth, row*tileHeight));
			}
		}
	}
}