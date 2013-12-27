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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import mx.controls.Image;
	
	/**
	 * Controls which <code>Tilesheet</code> to be drawn.
	 */
	public class Preview extends Bitmap
	{
		// Channels
		public var color:Tilesheet;
		public var matte:Tilesheet;
		public var shadow:Tilesheet;
		public var alphaShadow:Tilesheet;
		public var output:Tilesheet;
		public var animated:Tilesheet;
		private var _animatedIndex:uint = 0;
		
		public var activeTilesheet:int;
		
		private var _main:Main;
		private var _timer:Timer;
		
		public function Preview(main:Main) 
		{
			_main = main;
			
			_timer = new Timer(1000/30);
			_timer.addEventListener(TimerEvent.TIMER, drawNextAnimatedFrame);
			_timer.start();
		}
		
		/**
		 * Sets the passed tilesheet as the active tilesheet to be drawn from.
		 * @param	tilesheet Tilesheet to draw.
		 */
		public function showTilesheet(tilesheet:Tilesheet):void
		{
			bitmapData = tilesheet.buffer;
			
			var imgHolder:Image = View.controls["imgHolder"];
			imgHolder.width = tilesheet.width;
			imgHolder.height = tilesheet.height;
		}
		
		/**
		 * Draws the next animated frame for the Animation preview.
		 * @param	e
		 */
		private function drawNextAnimatedFrame(e:TimerEvent):void
		{
			if (animated == null || activeTilesheet != 1) return;
			
			var r:uint = _animatedIndex / color.cols;
			var c:uint = _animatedIndex % color.cols;
			animated.buffer.fillRect(new Rectangle(0, 0, animated.buffer.width, animated.buffer.height), 0x0);
			
			var m:Matrix = new Matrix();
			//m.translate(0, _main.generator.bounds.height);
			animated.buffer.draw(output.buffer, m, new ColorTransform(1, 1, 1, .5));
			
			var generator:Rectangle = _main.generator.bounds;
			
			var copyRect:Rectangle = new Rectangle(c * generator.width, r * generator.height, generator.width, generator.height);
			animated.buffer.copyPixels(output.buffer, copyRect, new Point(copyRect.x, copyRect.y));
			animated.buffer.copyPixels(output.buffer, copyRect, new Point(0, 0));
			
			_animatedIndex++;
			if (_animatedIndex == color.rows * color.cols) _animatedIndex = 0;
		}
	}

}