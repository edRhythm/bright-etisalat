package rhythm.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import rhythm.events.CustomEvent;
	
	
	public class DataIO extends EventDispatcher
	{
		public var configXML:XML;
		public var kioskXML:Array;  // kioskXML[0].file, kioskXML[0].xml, etc.
		public var tweetsXML:XML;
		
		private var tweetsLoader:URLLoader;
		
		
		public function DataIO(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function getData():void
		{
			// listFiles();
			
			getConfig();			
			getKioskData();
			getTweets();
		}
		
		private function listFiles():void
		{
			var file:File = File.desktopDirectory.resolvePath('kioskData');
			var listing:Array = file.getDirectoryListing();
			
			for (var i:int=0; i<listing.length; ++i)
			{
				trace(listing[i].name, 'is directory?', listing[i].isDirectory, 'is symbolic link?', listing[i].isSymbolicLink);
			}
		}
		
		private function getConfig():void
		{
			var file:File = File.desktopDirectory.resolvePath('kioskData/config.xml');
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
				configXML = XML(fs.readUTFBytes(fs.bytesAvailable));
			fs.close();
			
			trace('\tconfigXML loaded');
		}
		
		public function getKioskData():void
		{
			kioskXML = [];
			
			for each (var fileName:XML in configXML.kiosk.file)
			{
				var file:File = File.desktopDirectory.resolvePath('kioskData/localXML/' + fileName + '.xml');
				trace('\t\tloading', file.nativePath);
				
				var fs:FileStream = new FileStream();
				fs.open(file, FileMode.READ);
				kioskXML.push({ file:fileName, xml:XML(fs.readUTFBytes(fs.bytesAvailable)) });
				fs.close();
			}
			
			trace('\tkioskXML loaded (' + kioskXML.length + ' files)');
		}
		
		private function getTweets():void
		{
			tweetsLoader = new URLLoader();
			var req:URLRequest = new URLRequest(configXML.tweetsURL);
			req.requestHeaders.push(new URLRequestHeader("Content-Type", "application/soap+xml"));
			req.method = URLRequestMethod.POST;
			
			var reqData:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
			reqData += "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">";
			reqData += "<soap12:Body>";
			reqData += "<Get xmlns=\"http://tempuri.org/\" />";
			reqData += "</soap12:Body>";
			reqData += "</soap12:Envelope>";
			
			req.data = new XML(reqData);
			
			tweetsLoader.addEventListener(Event.COMPLETE, loadingCompleteHandler);
			tweetsLoader.addEventListener(IOErrorEvent.IO_ERROR, loadingErrorHandler);
			tweetsLoader.load(req);
		}
		
		private function loadingErrorHandler(e:IOErrorEvent):void
		{
			// error! So load local tweets xml...
			var file:File = File.desktopDirectory.resolvePath('kioskData/serverXML/tweets.xml');
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			tweetsXML = XML(fs.readUTFBytes(fs.bytesAvailable));
			fs.close();
			
			trace('\ttweetsXML FAILED, so loaded local version');
			allXMLLoaded();
		}
		
		private function loadingCompleteHandler(e:Event):void
		{
			tweetsXML = XML(XML(tweetsLoader.data)..Profiles); // only need Profiles node. Not all the soap crap.
			
			var file:File = File.desktopDirectory.resolvePath('kioskData/serverXML/tweets.xml');
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes(tweetsXML);
			fs.close();
			
			trace('\ttweetsXML LOADED and saved in serverXML/tweets.xml');
			allXMLLoaded();
		}
		
		private function allXMLLoaded():void
		{
			dispatchEvent(new CustomEvent(CustomEvent.DATA_READY, true));
		}		
	}
}