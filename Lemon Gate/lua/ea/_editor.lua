/*==============================================================================================
	Expression Advanced: Editor.
	Purpose: We where gonna make our own but meh.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

E_A.Editor = {}
local Editor = E_A.Editor

/*==============================================================================================
	Home Screen
==============================================================================================*/
local HomeScreen = [[/*===================================================
Expression Advanced Beta
- Rusketh, Oskar94, Divran, Syranide

For documentation and help visit out wiki.
Wiki: https://github.com/SpaceTown-Developers/Lemon-Gate/wiki

There are bugs you will find them, there are also ideas and you will have them.
When you do please post them on your bug tracker to help development.
Bug Tracker: https://github.com/SpaceTown-Developers/Lemon-Gate/issues

New Features:
* Try and Catch statements.
* Entity find functions.
* Foreach loops.

Thank you for taking part in this Beta!
===================================================*/]]

/*==============================================================================================
	Syntax Highlighting
==============================================================================================*/
local KeyWords = { }
for _,V in pairs( {
	"if", "elseif", "else",
	"for", "while", "foreach",
	"try", "catch",
	"return", "break", "continue",
	"function", "event",
	"global", "input", "output"
} ) do KeyWords[V] = V end


local Tokens

local function AddToken( Data, Color, Flag )
	Tokens[#Tokens + 1] = { Data, {Color, Flag} }
end

local function SyntaxColorLine(self, Row)
	local Line = self.Rows[Row]
	Tokens = { }
	
	AddToken( Line, Color(255, 255, 255) , false )
	
	return Tokens
end

/*==============================================================================================
	Validator
==============================================================================================*/
local Tokenizer = E_A.Tokenizer
local Parser = E_A.Parser
local Compiler = E_A.Compiler

function Editor.Validate(Script, Editor)
	local Check, Tokens, Rows = Tokenizer.Execute(Script, true)
	if !Check then return Tokens end
	
	local Check, Instructions = Parser.Execute(Tokens)
	if !Check then return Instructions end
	
	local Check, Executable, Instance = Compiler.Execute(Instructions)
	if !Check then return Executable end
	
	local Types = Instance.VarTypes
	
	for Cell, Name in pairs( Instance.Inputs ) do
		local Type = E_A.TypeShorts[ Types[Cell] ]
		
		if !Type[4] or !Type[5] then
			return "Type '" .. Type[1] .. "' may not be used as input."
		end
	end
	
	for Cell, Name in pairs( Instance.Outputs ) do
		local Type = E_A.TypeShorts[ Types[Cell] ]
		
		if !Type[4] or !Type[6] then
			return "Type '" .. Type[1] .. "' may not be used as output."
		end
	end
end

local Validate = Editor.Validate

/*==============================================================================================
	Hack the E2 Editor!
==============================================================================================*/
function Editor.Create()
	if Editor.Instance then return end
	
	file.CreateDir("LemonGate")
	
	local Instance = vgui.Create("Expression2EditorFrame")
	Instance:Setup("Expression Advanced Editor", "LemonGate", "EA")
	Instance:SetSyntaxColorLine( SyntaxColorLine )
	
	local Panel = Instance:GetCurrentEditor()
	
	function Instance:InitShutdownHook()
		self:SaveTabs()
	end
	
	function Instance:OnTabCreated( Tab )
		local Editor = Tab.Panel
		Editor:SetText( HomeScreen )
		Editor.Start = Editor:MovePosition({1,1}, #HomeScreen)
		Editor.Caret = Editor:MovePosition(Editor.Start, #HomeScreen)
	end
	
	function Instance:Validate( Goto )
		local Panel = self.C['Val'].panel
		
		if !E_A.TypeTable or !E_A.FunctionTable or !E_A.OperatorTable or !E_A.EventsTable then
			Panel:SetText( "Downloading Validation Files, Please wait..." )
			return RunConsoleCommand("lemon_sync")
		end
		
		
		local Error = Validate( self:GetCode(), self:GetCurrentEditor() )
		
		if !Error then
			Panel:SetBGColor(0, 128, 0, 180)
			Panel:SetFGColor(255, 255, 255, 128)
			Panel:SetText( "Validation Successful!" )
		else
			Panel:SetBGColor(128, 0, 0, 180)
			Panel:SetFGColor(255, 255, 255, 128)
			Panel:SetText( Error )
			
			if Goto then
				local Row, Col = Error:match("at line ([0-9]+), char ([0-9]+)$")
				
				if !Row then Row, Col = Error:match("at line ([0-9]+)$"), 1 end
				
				if Row then self:GetCurrentEditor():SetCaret({ tonumber(Row), tonumber(Col) }) end
			end
		end
	end
	
	Editor.Instance = Instance
end

function Editor.Open(Line, Code, NewTab)
	Editor.Create()
	Editor.Instance:Open(Line, Code, NewTab)
end

function Editor.NewTab(Script, Title)
	Editor.Create()
	
	local Instance = Editor.Instance
	local Tab = Instance:CreateTab( Title or "Generic" ).Tab
	Instance:SetActiveTab( Tab )
	Instance:ChosenFile()
	Instance:SetV(true)
	
	if Script then
		Instance:SetCode( Script )
	end
end

function Editor.GetOpenFile()
	if Editor.Instance then
		return Editor.Instance:GetChosenFile()
	end
end

function Editor.GetCode()
	if Editor.Instance then
		return Editor.Instance:GetCode()
	end
end

function Editor.GetInstance()
	Editor.Create()
	return Editor.Instance
end

function Editor.Validate()
	if Editor.Instance then
		Editor.Instance:Validate( true )
	end
end
