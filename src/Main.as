package 
{
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Yanlin Qiu
	 */
	public class Main extends AppBase 
	{
		private var cam:Camera;
		private var v:Video;
		
		private var output_txt:TextField;
		
		private var netConn:NetConnection;
		private var netStream:NetStream;
		private var groupSpec:GroupSpecifier;
		
		override protected function init():void
		{
			createUI();
			
			startConnect();
		}		
		
		private function createUI():void
		{
			v = new Video(480, 360);			
			addChild(v);
			
			var tf:TextFormat = new TextFormat("Droid Serif", 20, 0x666666);
			output_txt = new TextField();
			output_txt.defaultTextFormat = tf;			
			output_txt.wordWrap = true;
			output_txt.multiline = true;
			output_txt.width = 300;
			output_txt.height = 480;
			output_txt.x = 490;
			
			addChild(output_txt);
		}
		
		private function log(s:String):void
		{
			s = s + "\n";
			output_txt.appendText(s);
			output_txt.scrollV = output_txt.maxScrollV;
		}
		
		private function startConnect():void
		{
			netConn = new NetConnection();
			netConn.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			netConn.connect("rtmfp://p2p.rtmfp.net/81e58b5487f9ed79f4f88558-8a07c37d1fa4/");    
			
			log("连接服务器...");	
		}
		
		private function onNetStatus(e:NetStatusEvent):void
		{
			trace(e.info.code);
			switch(e.info.code)
			{
				case "NetConnection.Connect.Success":
					log("连接成功.");	
					connectStream();
					break;
				case "NetConnection.Connect.Closed":
					log("连接断开.");	;
					break;
				case "NetStream.Connect.Success": 
					log("NetStream连接成功.");
					if ( Capabilities.version.indexOf("AND") != -1 )
					{
						log("开始分享视频.");
						startShareStream();
					}
					else
					{
						log("观看视频.");	
						watchStream();
					}
                    break;
                case "NetStream.Connect.Rejected": 
                case "NetStream.Connect.Failed":
                    break;
				case "NetStream.Publish.Start":
					log("已经开始发布视频");
					break;
			}			
		}
		
		private function connectStream():void
		{
            groupSpec = new GroupSpecifier("walktree/p2pTest");
			groupSpec.multicastEnabled = true;            
            groupSpec.serverChannelEnabled = true;

			netStream = new NetStream(netConn, groupSpec.groupspecWithAuthorizations());
            netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		
		private function startShareStream():void
		{
			netStream.client = this;
			cam = Camera.getCamera();			
			if(cam)
			{
				cam.setMode(480, 360, 10);
				cam.setQuality(0, 0);
				v.attachCamera(cam);

				netStream.attachCamera(cam);
			}
			
			netStream.publish("myStream");
		}
		
		private function watchStream():void
		{
			netStream.client = this;
			v.attachNetStream(netStream);
			
			netStream.play("myStream");
		}
		
		public function onPlayStatus(info:Object):void {}
        public function onMetaData(info:Object):void {}
        public function onCuePoint(info:Object):void {}
        public function onTextData(info:Object):void {}
	}
	
}