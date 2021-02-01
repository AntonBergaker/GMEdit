package gml.tokenizer;

import parsers.linter.GmlLinterImports;
import ui.preferences.PrefData;
import parsers.linter.GmlLinterKind;
import parsers.linter.GmlLinterInit;
import parsers.GmlReaderExt;
import tools.Dictionary;
import parsers.linter.GmlLinterKind.*;


class Tokenizer {
	var gmlVersion : GmlVersion;
	var preferences: PrefData;
	var keywords: Dictionary<GmlLinterKind>;

	public function new(gmlVersion:GmlVersion, preferences:PrefData) {
		this.gmlVersion = gmlVersion;
		keywords = GmlLinterInit.keywords(gmlVersion.config);
	}

	public function tokenize(code: String): TokenCollection {
		var reader = new GmlReaderExt(code, gmlVersion);
		var tokens = new Array<Token>();

		var whitespaceStart = 0;
		var readerPosition = 0;

		var insideMacro: TokenMacroSource = null;

		inline function push(kind:GmlLinterKind, string: String) {
			if (readerPosition > whitespaceStart) {
				tokens.push(new Token(KWhitespace, reader.substring(whitespaceStart, readerPosition), whitespaceStart, insideMacro));
			}
			whitespaceStart = reader.pos;
			tokens.push(new Token(kind, string, readerPosition, insideMacro));
		}
		inline function pushWithoutWhitespace(kind:GmlLinterKind, string: String) {
			tokens.push(new Token(kind, string, readerPosition, insideMacro));
		}

		while (reader.loop) {
			if (reader.depth == 0) {
				insideMacro = null;
			}
			readerPosition = reader.pos;
			var c = reader.read();


			switch (c) {
				case "\n".code: {
					pushWithoutWhitespace(KWhitespace, reader.substring(whitespaceStart, readerPosition+1));
					whitespaceStart = reader.pos;
				}
				case "/".code: switch (reader.peek()) {
					case "/".code: reader.skipLine();
					case "*".code: reader.skip(); reader.skipComment();
					default: {
						if (reader.peek() == "=".code) {
							reader.skip();
							push(KSetOp, "/=");
						} else push(KDiv, "/");
					};
				};
				case '"'.code, "'".code, "`".code: {
					var string = reader.readStringAuto(c);
					push(KString, string);
				};
				//
				case "?".code: {
					switch (reader.peek()) {
						case "?".code: {
							if (reader.peek(1) == "=".code) {
								reader.skip(2);
								push(KSet, "??=");
							} else {
								reader.skip(1);
								push(KNullCoalesce, "??");
							}
						};
						case ".".code: {
							c = reader.peek(1);
							if (!c.isDigit()) {
								reader.skip();
								push(KNullDot, "?.");
							} else push(KQMark, "?");
						};
						case "[".code: reader.skip(); push(KNullSqb, "?[");
						default: push(KQMark, "?");
					}
				};
				case ":".code: {
					if (reader.peek() == "=".code) {
						reader.skip();
						push(KSet, ":=");
					} else push(KColon, ":");
				};
				case "@".code: {
					if (gmlVersion.hasLiteralStrings()) {
						var nextChar = reader.peek();
						if (nextChar == '"'.code || nextChar == "'".code) {
							var string = reader.readStringAuto('@'.code);
							push(KString, string);
							continue;
						}
					}
					push(KAtSign, "@");
				};
				case "#".code: {
					c = reader.peek();
					if (c.isHex()) {
						var i = 0, ci;
						while (++i < 6) {
							ci = reader.peek(i);
							if (!ci.isHex()) break;
						}
						if (i >= 6) {
							ci = reader.peek(i);
							if (!ci.isHex()) {
								reader.pos += 6;
								push(KNumber, reader.substr(readerPosition, 7));
								continue;
							}
						}
					}
					if (c.isIdent0()) {
						reader.skipIdent1();
						var newPosition = readerPosition+1;
						var identifier = reader.substring(newPosition, reader.pos);
						switch (identifier) {
							case "mfunc", "macro": {
								var startPosition = reader.pos;
								while (reader.loopLocal) {
									reader.skipLine();
									if (reader.peek( -1) != "\\".code) break;
									reader.skipLineEnd();
								}
								push (identifier == "macro" ? KMacro : KMFuncDecl, "#" + identifier);
								var definition = reader.substring(startPosition, reader.pos);
								push(KMacroDefinition, definition);
							};
							case "args": {
								var line = reader.readLine();
								push(KArgs, "#args");
								continue;
							};
							case "lambda": push(KLambda, "#lambda");
							case "lamdef": push(KLamDef, "#lamdef");
							case "import", "hyper": {
								reader.skipLine();
							};
							case "define", "event", "moment", "target", "action": {
								// If start of file or start of newline
								if (readerPosition - 2 <= 0 || reader.get(readerPosition - 2) == "\n".code) {
									reader.pos = readerPosition;
									push(KPragma, "#" + identifier);
								} else {
									reader.pos = newPosition; push(KHash, "#");
								}
							};
							case "gmcr": {
								push(KGmcr, "#gmcr");
							};
							case "region", "endregion", "section": {
								reader.skipLine();
								var line = reader.substring(readerPosition, reader.pos);
								push(KWhitespace, line);
							};
							default: reader.pos = newPosition; push(KHash, "#");
						}
					}
					else push(KHash, "#");
				};
				case "$".code: {
					if (reader.peek(-2) == '['.code) { // Special case, $ after a [ is always treated as an accessor
						push(KDollar, "$");
						continue;
					}
					if (reader.peek().isHex()) {
						var hex = reader.readHex();
						push(KNumber, "$" + hex);
						continue;
					}
					push(KDollar, "$");
				};
				case ";".code: push(KSemico, ";");
				case ",".code: push(KComma, ",");
				//
				case "(".code: push(KParOpen, "(");
				case ")".code: push(KParClose, ")");
				case "[".code: push(KSqbOpen, "[");
				case "]".code: push(KSqbClose, "]");
				case "{".code: push(KCubOpen, "{");
				case "}".code: push(KCubClose, "}");
				//
				case "=".code: {
					if (reader.peek() == "=".code) {
						reader.skip();
						push(KEQ, "==");
					} else push(KSet, "=");
				};
				case "!".code: {
					if (reader.peek() == "=".code) {
						reader.skip();
						push(KNE, "!=");
					} else push(KNot, "!");
				};
				//
				case "+".code: {
					switch (reader.peek()) {
						case "=".code: reader.skip(); push(KSetAdd, "+=");
						case "+".code: reader.skip(); push(KInc, "++");
						default: push(KAdd, "+");
					}
				};
				case "-".code: {
					switch (reader.peek()) {
						case "=".code: reader.skip(); push(KSetSub, "-=");
						case "-".code: reader.skip(); push(KDec, "--");
						case ">".code: reader.skip(); push(KArrow, "->");
						default: push(KSub, "-");
					}
				};
				//
				case "*".code: {
					if (reader.peek() == "=".code) {
						reader.skip();
						push(KSetMul, "*=");
					} else push(KMul, "*");
				};
				case "%".code: {
					if (reader.peek() == "=".code) {
						reader.skip();
						push(KSetMod, "%=");
					} else push(KMod, "%");
				};
				//
				case "|".code: {
					switch (reader.peek()) {
						case "=".code: reader.skip(); push(KSetOr, "|=");
						case "|".code: reader.skip(); push(KBoolOr, "||");
						default: push(KOr, "|");
					}
				};
				case "&".code: {
					switch (reader.peek()) {
						case "=".code: reader.skip(); push(KSetAnd, "&=");
						case "&".code: reader.skip(); push(KBoolAnd, "&&");
						default: push(KAnd, "&");
					}
				};
				case "^".code: {
					switch (reader.peek()) {
						case "=".code: reader.skip(); push(KSetXor, "^=");
						case "^".code: reader.skip(); push(KBoolXor, "^^");
						default: push(KXor, "^");
					}
				};
				case "~".code: push(KBitNot, "~");
				//
				case ">".code: {
					switch (reader.peek()) {
						case "=".code: reader.skip(); push(KGE, ">=");
						case ">".code: reader.skip(); push(KShr, ">>");
						default: push(KGT, ">");
					}
				};
				case "<".code: {
					switch (reader.peek()) {
						case "=".code: reader.skip(); push(KLE, "<=");
						case "<".code: reader.skip(); push(KShl, "<<");
						case ">".code: reader.skip(); push(KNE, "<>");
						default: push(KLT, "<");
					}
				};
				//
				case ".".code: {
					c = reader.peek();
					if (c.isDigit()) {
						var number = reader.readNumber(false);
						push(KNumber, "." + number);
					} else push(KDot, ".");
				};
				default: {
					if (c.isIdent0()) {
						reader.skipIdent1();
						var identifier = reader.substring(readerPosition, reader.pos);
						
						// TODO
						/*
						//
						if (identifier != "var") {
							var imp = l.editor.imports[l.context];
							if (imp != null) {
								var ir = GmlLinterImports.proc(l, q, p, imp, nv);
								if (ir) return KEOF;
								if (ir != null) return next(l, q);
							}
						}
						//
						var mf = GmlAPI.gmlMFuncs[identifier];
						if (mf != null) {
							if (GmlLinterMFunc.read(l, q, nv)) return KEOF;
							continue;
						}
						*/

						// expand macros:
						var mcr = GmlAPI.gmlMacros[identifier];
						if (mcr != null) {
							if (insideMacro == null) {
								insideMacro = new TokenMacroSource(mcr.name);
							}
							if (reader.depth > 128) {
								return TokenCollection.CreateError("Recursive macro detected at position " + readerPosition);
							}
							if (mcr.expr == "var") switch (mcr.name) {
								case "const": push(KConst, identifier); continue;
								case "let": push(KLet, identifier); continue;
							}
							reader.pushSource(mcr.expr, mcr.name);
							continue;
						}
						switch (identifier) {
							case "cast":
								if (preferences.castOperators) push(KCast, identifier); continue;
							case "as":
								if (preferences.castOperators) push(KAs, identifier); continue;
						}
						push(keywords.defget(identifier, KIdent), identifier); continue;
						
					}
					else if (c.isDigit()) {
						if (reader.peek() == "x".code) {
							reader.skip();
							var number = reader.readHex();
							push(KNumber, "0x"+number);
						} else {
							// Since we already read the first digit, move back one so we read the complete number
							reader.pos--;
							var number = reader.readNumber();
							push(KNumber, number);
						}
					}
					else if (c.code > 32) {
						push(KUnknown, String.fromCharCode(c));
					}
				};
			}
		}

		if (reader.pos > whitespaceStart) {
			tokens.push(new Token(KWhitespace, reader.substring(whitespaceStart, reader.pos), whitespaceStart, insideMacro));
		}

		return new TokenCollection(tokens);
	}
}