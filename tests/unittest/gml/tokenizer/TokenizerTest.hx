package gml.tokenizer;

import parsers.linter.GmlLinterKind;
import massive.munit.Assert;
import ui.Preferences;

class TokenizerTest {
	var tokenizer:Tokenizer;
	@Before public function setup() {
		tokenizer = new Tokenizer(GmlVersion.v2, Preferences.current);
	}

	@Test public function testTokens() {
		tokensEqual("var a = b",
			[token(KVar, "var"), token(KWhitespace, " "), token(KIdent, "a"), token(KWhitespace, " "), token(KSet, "="), token(KWhitespace, " "), token(KIdent, "b")]
		);
	}

	private inline function token(kind: GmlLinterKind, source: String): Token {
		return new Token(kind, source, 0, null);
	}

	private function tokensEqual(gmlCode: String, tokens: Array<Token>, ?compareIndex: Bool = false): Bool {
		var compiledTokens = tokenizer.tokenize(gmlCode);
		//Assert.areEqual(tokens.length, compiledTokens.length, "Length of the tokens and string are not equal");

		var index = 0;
		while (compiledTokens.reachedEnd == false) {
			var aToken = tokens[index++];
			var bToken = compiledTokens.next();
			if (Token.equals(aToken, bToken) == false) {
				Assert.fail('Tokens are not identical\nExpected:\n${aToken.getInfoString(false)}\nGot:\n${bToken.getInfoString(false)}');
			}
			if (compareIndex && aToken.position != bToken.position) {
				Assert.fail('Tokens have varying index.\nExpected: ${aToken.position}\nGot: ${bToken.position}');
			}
		}
		
		return false;
	}
}