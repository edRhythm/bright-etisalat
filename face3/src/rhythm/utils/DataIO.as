package rhythm.utils
{
	import flash.display.Sprite;
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

		private var kioskXMLMerged:XML;
		
		
		public function DataIO(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function getData():void
		{
			// listFiles();
			
			getConfig();			
			getKioskData();
			
			// getTweets();
			tweetsLoaderErrorHandler(null);
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
			
			// merge all kiosk message data
			kioskXMLMerged = <users></users>;
			
			for (var i:int=0; i<kioskXML.length; ++i)
			{
				for each (var j:XML in kioskXML[i].xml.user)
				{
					kioskXMLMerged.appendChild(j);
				}
			}
			
			resetUsedMessages();
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
			
			tweetsLoader.addEventListener(Event.COMPLETE, tweetsLoaderCompleteHandler);
			tweetsLoader.addEventListener(IOErrorEvent.IO_ERROR, tweetsLoaderErrorHandler);
			tweetsLoader.load(req);
		}
		
		private function tweetsLoaderErrorHandler(e:IOErrorEvent):void
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
		
		private function tweetsLoaderCompleteHandler(e:Event):void
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
			resetUsedTweets();
			dispatchEvent(new CustomEvent(CustomEvent.DATA_READY, true));
		}		
		
		public function getRandomTweets(amount:int):XML
		{
			var pool:XMLList;
			var tweets:XML = <Profiles></Profiles>;
			
			for (var i:int=0; i<amount; ++i)
			{
				pool = tweetsXML..Profile.(@used == 'false');
				if (pool.length() <= 0) 
				{
					resetUsedTweets();
					pool = tweetsXML..Profile.(@used == 'false');
				}
				
				var tweet:XML = pool[Math.floor(Math.random()*pool.length())]; 
				tweet.@used = 'true';					
				tweets.appendChild(tweet);
			}		
			return tweets;
		}
		
		private function resetUsedTweets():void
		{
			// set all to unused
			for each (var tweet:XML in tweetsXML.Profile)
			{
				tweet.@used = 'false';
			}
		}
		
		public function getRandomMessages(amount:int):XML
		{
			var pool:XMLList;
			var messages:XML = <users></users>;
			
			for (var i:int=0; i<amount; ++i)
			{
				pool = kioskXMLMerged..user.(@used == 'false');
				if (pool.length() <= 0) 
				{
					resetUsedMessages();
					pool = kioskXMLMerged..user.(@used == 'false');
				}
				
				var message:XML = pool[Math.floor(Math.random()*pool.length())]; 
				message.@used = 'true';					
				messages.appendChild(message);
			}		
			return messages;
		}
		
		private function resetUsedMessages():void
		{
			// set all to unused
			for each (var message:XML in kioskXMLMerged.user)
			{
				message.@used = 'false';
			}
		}
	}
}