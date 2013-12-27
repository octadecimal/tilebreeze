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
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import mx.controls.Alert;
	import mx.core.WindowedApplication;
	import mx.events.FlexEvent;
	import mx.events.FlexNativeWindowBoundsEvent;
	
	/**
	 * Serves as the base class; provides no functionality and mostly holds references to
	 * other core objects.
	 */
	public class Main
	{
		/**
		 * Reference to the View object.
		 */
		public var view:View;
		
		/**
		 * Reference to the Controller object.
		 */
		public var controller:Controller;
		
		/**
		 * Reference to the Filesystem object.
		 */
		public var filesystem:Filesystem;
		
		/**
		 * Reference to the Generator object.
		 */
		public var generator:Generator;
		
		/**
		 * Reference to the Preview object.
		 */
		public var preview:Preview;
		
		private var _form:WindowedApplication;
		
		/**
		 * Static reference to this object.
		 */
		static public var instance:Main;
		
		/**
		 * The Main constructor, instantiated from within the MXML file.
		 * @param	form	Reference to the MXML object that created this class.
		 */
		public function Main(form:*) 
		{
			Main.instance = this;
			
			_form = form as WindowedApplication;
			_form.addEventListener(FlexEvent.APPLICATION_COMPLETE, ready);
			_form.addEventListener(FlexNativeWindowBoundsEvent.WINDOW_RESIZE, onWindowResize);
		}
		
		private function checkForUpdates():void
		{
			View.log(this, "Checking for updates...");
			
			// Compare to http://tilebreeze.octadecimal.com/version.txt
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onCurrentVersionReceived);
			urlLoader.load(new URLRequest("http://tilebreeze.octadecimal.com/version.txt"));
		}
		
		private function onCurrentVersionReceived(e:Event):void 
		{
			// Get currently installed version
			var app:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var air:Namespace = app.namespaceDeclarations()[0];
			var version:String = app.air::version;
			
			var newestVersion:String = URLLoader(e.target).data;
			
			// Compare
			if (version < newestVersion)
				Alert.show("A newer build is available.\n\nInstalled:\t" + version + "\nNewest:\t\t" + newestVersion + "\n", "Update available");
				
			View.log(this, "Installed build: " + version + " | Newest build: " + newestVersion);
		}
		
		private function onWindowResize(e:FlexNativeWindowBoundsEvent):void 
		{
			if(generator.generated) {
				_form.maxWidth = Math.max(generator.tilesheets[0].width + 20, 435);
				_form.maxHeight = Math.max(generator.tilesheets[0].height + 120 + 150 + 68, 400);
			}
		}
		
		/**
		 * Dispatched when the application is ready.
		 * @param	e	FlexEvent object.
		 */
		private function ready(e:FlexEvent):void 
		{
			filesystem = new Filesystem(this);
			controller = new Controller(this);
			generator = new Generator(this);
			preview = new Preview(this);
			view = new View(this, _form as WindowedApplication); 
			
			_form.showStatusBar = false;
			
			View.controls["btnColorFolder"].toolTip = "Source folder to use for the Color channel.";
			View.controls["btnAlphaFolder"].toolTip = "Source folder to use for the Alpha channel.";
			View.controls["btnShadowFolder"].toolTip = "Source folder to use for the Shadow channel.";
			
			View.controls["canvasGenerate"].addEventListener(FlexEvent.CREATION_COMPLETE, onFormGenerate);
			
			
			
			checkForUpdates();
		}
		
		/**
		 * Called when the Generate Form has been drawn.
		 * @param	e
		 */
		private function onFormGenerate(e:FlexEvent):void 
		{
			View.controls["chkSmartCrop"].toolTip = "Crops any surrounding blackspace around each tile.";
			View.controls["chkForceCenter"].toolTip = "Centers each tile ensuring that a common point origin remains. Useful for situations where a tilesheet may contain different angles and needs to spin around a common point.";
			View.controls["chkPreferSquare"].toolTip = "Where possible, priority will be given to tilesheet squaredness over filesize.";
		}
	}
}