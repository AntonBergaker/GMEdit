package gml.ast;

import gml.ast.tree.NumberLiteral;
import gml.ast.tree.VarDefinition;
import gml.ast.tree.AstCode;
import haxe.display.Protocol.Version;
import gml.ast.tree.StatementList;
import massive.munit.Assert;

class AstBuilderTest {

	@Test public function testVar() {
		var builder = new AstBuilder(GmlVersion.v2);

		var result = builder.build("var a = 5");

		Assert.isTrue( result.equals(
			new AstCode(
				new StatementList([
					new VarDefinition("a", null,
						new NumberLiteral("5")
					)]
				)
			)
		) );
	}

}