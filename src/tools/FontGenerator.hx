package tools;

import electron.FontScanner.FontDescriptor;
import js.html.Node;
import js.html.webgl.Buffer;
import electron.FileSystem;
import js.html.Document;
import js.html.CanvasElement;
import yy.YyFont;
import Main.document;

class FontGenerator {
	public static function export(font:YyFont, fontDescriptor:FontDescriptor, path:String, callback:() -> Void) {
		var spacing = 16;

		var canvas = document.createCanvasElement();
		canvas.id = "canvas";
		canvas.width = 512;
		canvas.height = 512;

		var context = canvas.getContext("2d");
		context.textAlign = "left";
		context.textBaseline = "top";
		context.font = '${font.size}pt "${fontDescriptor.postscriptName}", "${fontDescriptor.family} ${fontDescriptor.style}", "${fontDescriptor.family}"';
		context.fillStyle = 'white';

		var characterArray = NativeArray.from(font.getAllCharacters());
		var characterTextureArray = [];

		for (char in characterArray) {
			var charstats = context.measureText(char);
			var w = Math.ceil(charstats.actualBoundingBoxRight + charstats.actualBoundingBoxLeft);
			var h = Math.ceil(charstats.actualBoundingBoxDescent + charstats.actualBoundingBoxAscent);
			characterTextureArray.push(new CharacterTexture(char, w, h, w * h));
		}

		characterTextureArray.sort((a, b) -> (b.area - a.area));

		var posX = 0;
		var posY = 0;
		var heightMax = 0;
		var i = 0;

		font.glyphsClear();
		while (i < characterTextureArray.length) {
			var charTexture = characterTextureArray[i];
			var charstats = context.measureText(charTexture.character);
	
			var x = posX;
			var y = posY;
			var w = Math.ceil(charstats.actualBoundingBoxRight + charstats.actualBoundingBoxLeft);
			var h = Math.ceil(charstats.actualBoundingBoxDescent + charstats.actualBoundingBoxAscent);
			heightMax = cast(Math.max(heightMax, h),Int);
	
			if (posX + w + spacing > 512) {
				posY += heightMax + spacing;
				heightMax = 0;
				posX = spacing;
				continue;
			}

			//context.rect(x, y, w, h);
            //context.strokeStyle = 'red';
            //context.stroke();
	
			context.fillText(charTexture.character, posX + charstats.actualBoundingBoxLeft, posY + charstats.actualBoundingBoxAscent);
			var code = NativeString.codePointAt(charTexture.character,0);
			if (code != 32) {
				font.glyphsAdd(code,x,y + charstats.actualBoundingBoxAscent,w,h - charstats.actualBoundingBoxAscent,w,0);
			} else {
				font.glyphsAdd(code,x,y + charstats.actualBoundingBoxAscent,Math.round(0.25*font.size),h - charstats.actualBoundingBoxAscent,Math.round(0.25*font.size),0);
			}
	
			posX += w + spacing;
			i++;
		}

		canvas.toBlob(result -> {
			var buffer_promise = (cast result).arrayBuffer();
			buffer_promise.then((result) -> {
				//var bytes = haxe.io.Bytes.ofData(result);
				var nodeBuffer = new electron.Buffer(result);
				FileSystem.writeFileSync(path,nodeBuffer);
				callback();
				trace("Done!");
			});
		}, 'image/png');
		
	}
}

private class CharacterTexture {
	public var character = "A";
	public var width = 0;
	public var height = 0;
	public var area = 0;
	public function new(character, width, height, area) {
		this.character = character;
		this.width = width;
		this.height = height;
		this.area = area;
	}
}