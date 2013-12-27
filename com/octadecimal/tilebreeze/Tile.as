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
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	/**
	 * A tile has a bitmap buffer and an associated file on the filesystem.
	 */
	public class Tile implements IDimensional
	{
		public var buffer:BitmapData;
		public var path:String;
		public var width:uint;
		public var height:uint;
		public var transparent:Boolean;
		
		private var _bounds:Rectangle = new Rectangle();
		public function get bounds():Rectangle { return _bounds; }
		
		private var _loader:URLLoader;
		private var _onLoadedCallback:Function;
		
		public function Tile(path:String, onLoaded:Function) 
		{
			this.path = path;
			this._onLoadedCallback = onLoaded;
			
			load();
		}
		
		private function load():void
		{
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(Event.COMPLETE, onLoaded);
			_loader.load(new URLRequest(path));
			//View.log(this, "Loading: " + path);
		}
		
		private function onLoaded(e:Event):void 
		{
			// Decode bitmap
			buffer = Generator.decoder.decode(_loader.data);
			//View.log(this, "Decoded: " + path);
			
			// Save metadata
			width = buffer.width;
			height = buffer.height;
			transparent = buffer.transparent;
			_bounds.width = width;
			_bounds.height = height;
			_bounds.left = 0;
			_bounds.top = 0;
			
			// Smart-Crop
			if (View.controls["chkSmartCrop"].selected)
			{
				_bounds.left = width;
				_bounds.right = 0;
				_bounds.top = height;
				_bounds.bottom = 0;
				
				// Find Edges
				for(var x:uint = 0, w:uint = width; x < w; x++)
					for(var y:uint=0, h:uint = height; y < h; y++)
						if(buffer.getPixel(x, y) > 0)
						{
							if(x < _bounds.left) _bounds.left = x;
							if(x > _bounds.right) _bounds.right = x;
							if(y < _bounds.top) _bounds.top = y;
							if(y > _bounds.bottom) _bounds.bottom = y;
						}
				
				// Force center
				if (View.controls["chkForceCenter"].selected)
				{
					// Derive edge margins
					var l:int = _bounds.left;
					var r:int = width -_bounds.right;
					var t:int = _bounds.top;
					var b:int = height - _bounds.bottom;
					
					// Move the edge with the wider margin equidistant of the opposite edge's margin
					(l < r) ? _bounds.right = (width-l) : _bounds.left = (width-r);
					(t < b) ? _bounds.bottom = (height-t) : _bounds.top = (height-b);
					//View.log(this, w1(bounds.left)+" "+w2(bounds.right)+"  "+h1(bounds.top)+" "+h2(bounds.bottom));
				}
			}
			
			// Dispose loader
			_loader.close();
			_loader.removeEventListener(Event.COMPLETE, onLoaded);
			_loader = null;
			
			// Callback
			_onLoadedCallback(this);
		}
		
		private function w1(n:Number):String
		{
			return int((n / width)*100).toString();  
		}
		private function w2(n:Number):String
		{
			return int(100-((n / width)*100)).toString();  
		}
		private function h1(n:Number):String
		{
			return int((n / height)*100).toString();  
		}
		private function h2(n:Number):String
		{
			return int(100-((n / height)*100)).toString();  
		}
	}
}