package control
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import message.Message;
	import message.MessageDispatcher;
	
	import model.JSFLProxy;
	
	import modifySWF.modify;
	
	public class FLAExportSWFCommand
	{
		public static const instance:FLAExportSWFCommand = new FLAExportSWFCommand();
		
		private var _urlLoader:URLLoader;
		
		private var _textureAtlasXML:XML;
		private var _textureBytes:ByteArray;
		
		public function FLAExportSWFCommand()
		{
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		}
		
		public function exportSWF(textureAtlasXML:XML):void
		{
			_textureAtlasXML = textureAtlasXML;
			MessageDispatcher.addEventListener(JSFLProxy.EXPORT_SWF, jsflProxyHandler);
			JSFLProxy.getInstance().exportSWF();
		}
		
		private function jsflProxyHandler(e:Message):void
		{
			MessageDispatcher.removeEventListener(JSFLProxy.EXPORT_SWF, jsflProxyHandler);
			
			var swfURL:String = e.parameters[0];
			if(swfURL)
			{
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoaderHandler);
				_urlLoader.addEventListener(Event.COMPLETE, urlLoaderHandler);
				_urlLoader.load(new URLRequest(swfURL));
			}
		}
		
		private function urlLoaderHandler(e:Event):void
		{
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoaderHandler);
			_urlLoader.removeEventListener(Event.COMPLETE, urlLoaderHandler);
			switch(e.type)
			{
				case IOErrorEvent.IO_ERROR:
					MessageDispatcher.dispatchEvent(IOErrorEvent.IO_ERROR);
					break;
				case Event.COMPLETE:
					_textureBytes = modify(_urlLoader.data, _textureAtlasXML);
					
					MessageDispatcher.dispatchEvent(MessageDispatcher.FLA_TEXTURE_ATLAS_SWF_LOADED, _textureBytes);
					break;
			}
		}
	}
}