package gml.ast;

import ui.Preferences;
import haxe.extern.EitherType;
import gml.ast.tree.*;
import massive.munit.Assert;

class BinaryEqualsTest {
	var builder:AstBuilder;
	@Before public function setup() {
		builder = new AstBuilder(GmlVersion.v2, Preferences.current);
	}

	@Test public function testBinaryEquals() {
		var codes = [
			"var a:number = 5;",
			"var a:number = 5",
			"var a:number=5",
			"var /*comment*/ a    :   number =   5;;;;",
			"/*comment*/ var a = 5 //comment",
			"var a = 5 + 5",
			"var a = 5 * -1",
		];

		for (code in codes) {
			var result = builder.build(code);
			Assert.areEqual(code, result.toCompleteString());
		}
	}

	private function treeEquals(gmlCode:String, statementList:EitherType<Array<AstNode>, AstNode>) {
		return AstTestHelper.treeEquals(gmlCode, statementList, builder);
	}
}