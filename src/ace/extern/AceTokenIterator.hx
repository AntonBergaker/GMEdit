package ace.extern;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("AceTokenIterator") extern class AceTokenIterator {
	function new(session:AceSession, row:Int, col:Int);
	function getCurrentToken():AceToken;
	function getCurrentTokenRange():AceRange;
	function getCurrentTokenPosition():AcePos;
	function stepBackward():AceToken;
	function stepForward():AceToken;
	inline function getCurrentTokenRow():Int {
		return getCurrentTokenPosition().row;
	}
}
