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
	import mx.core.WindowedApplication;
	import mx.events.FlexEvent;
	import mx.events.FlexNativeWindowBoundsEvent;
	
	/**
	 * The main <code>WindowedApplication</code> that the GUI and it's respective controls reside in.
	 */
	public class Form extends WindowedApplication
	{
		
		public function Form() 
		{
			addEventListener(FlexEvent.APPLICATION_COMPLETE, ready);
		}
		
		private function ready(e:FlexEvent):void 
		{
		}
		
	}

}