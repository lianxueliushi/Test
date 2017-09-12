package{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class MagicWand {
		/**
		 * 
		 * @param bitmapData 
		 * @param num  颜色相似范围
		 * @param x 参考抠图点的X坐标
		 * @param y 参考抠图点的Y坐标
		 * @return 抠图完毕后新的bitmapData
		 * 
		 */			
		
		public static function selectColors(bitmapData:BitmapData,num:int=50,x:Number=0,y:Number=0):BitmapData
		{
			var rgb:Number = bitmapData.getPixel(x,y);
			trace(new Date().millisecondsUTC)
			var rng:Array = [ -num, num];
			
			var rmin:Number = Math.min(255,Math.max(0,((rgb >> 16) & 0xff) + rng[0] ));
			var gmin:Number = Math.min(255,Math.max(0,((rgb >> 8) & 0xff) + rng[0] ));
			var bmin:Number = Math.min(255,Math.max(0,(rgb  & 0xff) + rng[0] ));
			var rgbMin:Number = rmin<<16 | gmin<<8 | bmin;
			
			var rmax:Number = Math.min(255,Math.max(0,((rgb >> 16) & 0xff) + rng[1] ));
			var gmax:Number = Math.min(255,Math.max(0,((rgb >> 8) & 0xff ) + rng[1] ));
			var bmax:Number = Math.min(255,Math.max(0, (rgb & 0xff) + rng[1] ));
			var rgbMax:Number = rmax<<16 | gmax<<8 | bmax;
	
			
			rmin = (rgbMin >> 16) & 0xff;
			gmin = (rgbMin >> 8) & 0xff;
			trace("gmin:"+gmin,String((gmin<<8) ));
			bmin = rgbMin  & 0xff;
			
			rmax = (rgbMax >> 16) & 0xff;
			gmax = (rgbMax >> 8) & 0xff;
			bmax = rgbMax  & 0xff;
			
			var tmp:Number
			
			if (rmin>rmax){
				tmp=rmin;
				rmin = rmax;
				rmax = tmp;
			}
			
			if (gmin>gmax){
				tmp =gmin;
				gmin = gmax;
				gmax = tmp;
			}
			
			if (bmin>bmax){
				tmp=bmin;
				bmin = bmax;
				bmax = tmp;
			}
			
			var mask:BitmapData = new BitmapData( bitmapData.width, bitmapData.height, true);
			
			var hideColor:Number = 0xff000000;
			var rect:Rectangle = bitmapData.rect;
			var zero:Point = new Point();
			
			var ms:uint=0x00ff00;
			var threshord:uint=0xff007000;
			var color:uint=0xff0000ff;
			mask.threshold( bitmapData, rect, zero, "<", rmin<<16,hideColor,0x00FF0000,true);
			mask.threshold( mask, rect, zero, "<", gmin<<8,hideColor,0x0000ff00,true);
			mask.threshold( mask, rect, zero, "<", bmin,hideColor,0x000000ff,true);
//			
			mask.threshold( mask, rect, zero, ">", rmax<<16,hideColor,0x00FF0000,true);
			mask.threshold( mask, rect, zero, ">", gmax<<8,hideColor,0x0000ff00,true);
			mask.threshold( mask, rect, zero, ">", bmax,hideColor,0x000000ff,true);
//		
			mask.threshold( mask, rect, zero, "!=", hideColor,0x00ffffff,0xFFFFFF,true);
//			mask.floodFill(x, y, 0);
			mask.threshold( mask, rect, zero, "!=", 0x00FFFFFF,hideColor,0x00000000,true);
			

			
			mask.applyFilter( mask,rect,zero, new BlurFilter(3,3,BitmapFilterQuality.HIGH));
	
			var transformMap:BitmapData = new BitmapData( bitmapData.width, bitmapData.height, true,0);
			
			transformMap.copyPixels(bitmapData,rect,zero,mask,zero,true);
			
			mask.dispose();
			trace(new Date().millisecondsUTC)
			return transformMap;
			
		}
		public static function clearGreen(_sbd:BitmapData):BitmapData{
			var _bd:BitmapData = new BitmapData(_sbd.width,_sbd.height,true,0x0);
			var r:int;
			var g:int;
			var b:int;
			var hmax:int = _bd.height;
			var wmax:int = _bd.width;
			var rect:Rectangle = _bd.rect;
			var zero:Point = new Point();
			_bd.lock();
			for(var h:int=0;h<hmax;h++){
				for(var w:int=0;w<wmax;w++){
					var color:int = _sbd.getPixel32(w,h);
					r = (color>> 16 & 0xFF);
					g = (color >> 8 & 0xFF);
					b = (color & 0xFF);
					//					var hsb:Object = RGBToHSB(r,g,b);
					var alpha:Number=255;
					if(g>(r+b) && g>40){
						alpha = 0;
						_bd.setPixel32(w,h,0);
					}
					else if(g-b>20 && g-r>20){
						alpha=0;
						_bd.setPixel32(w,h,0);
					}
					else _bd.setPixel32(w,h,color);
//					trace(color);
//					_bd.setPixel32(w,h,color+int(alpha/255)*255* 0x01000000);
				}
				
			}
			_bd.unlock();
			_bd.applyFilter( _bd,rect,zero, new BlurFilter(1,1,BitmapFilterQuality.HIGH));
			return  _bd;
			
		}
		
	}
}