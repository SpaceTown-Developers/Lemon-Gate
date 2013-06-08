/*==============================================================================================
	Section: Util
==============================================================================================*/
local function NType( Type )
	return API:GetClass( Type ).Name
end

local function SType( Type )
	return API:GetClass( Type ).Short
end

/*==============================================================================================
	Section: Scopes
==============================================================================================*/
function Compiler:InitScopes( )
	self.ScopeID = 1
	self.Global, self.Scope = { }, { }
	self.Scopes = { [0] = self.Global, self.Scope }
	
	self.IncRef = 0
	
	self.Cells = { }
	self.InPorts = { }
	self.OutPorts = { }
end

function Compiler:PushScope( )
	self.Scope = { }
	self.ScopeID = self.ScopeID + 1
	self.Scopes[ self.ScopeID ] = self.Scope
end

function Compiler:PopScope( )
	self.Scopes[ self.ScopeID ] = nil
	self.ScopeID = self.ScopeID - 1
	self.Scope = self.Scopes[ self.ScopeID ]
end

/*==============================================================================================
	Section: Cell Util
==============================================================================================*/
function Compiler:NextRef( )
	local Ref = self.IncRef + 1
	self.IncRef = Ref
	return Ref
end

function Compiler:TestCell( Trace, Ref, Type, Variable )
	local Cell = self.Cells[ Ref ]
	if !Cell and Variable then
		self:TraceError( Trace, "%s of type %s does not exist", Variable, NType( Type ) )
	elseif Cell.Type ~= Type and Variable then
		self:TraceError( Trace, "%s of type %s can not be assigned as %s", Variable, NType( Cell.Type ), NType( Type ) )
	else
		return true
	end
end

function Compiler:FindCell( Trace, Variable )
	for Scope = self.ScopeID, 0, -1 do
		local Ref = self.Scopes[ Scope ][ Variable ]
		if Ref then return Ref, Scope end
	end
end

/*==============================================================================================
	Section: Cell Assigment
==============================================================================================*/
local CELL_LOCAL = "Local"
local CELL_GLOBAL = "Global"
local CELL_INPUT = "Inport"
local CELL_OUTPUT = "Outport"

function Compiler:SetVariable( Trace, Variable, Type, GlobAss )
	local Ref, Scope = self:FindCell( Trace, Variable )
	
	if !Ref then
		self:TraceError( "Variable %s does not exist", Variable )
	elseif GlobAss then
		return self:Assign( Trace, Variable, Type, CELL_GLOBAL )
	else
		local Cell = self.Cells[ Ref ]
		if Cell.Type ~= Type then
			self:TraceError( Trace, "%s of type %s can not be assigned as %s", Variable, NType( Cell.Type ), NType( Type ) ) 
		else
			return Ref, Scope
		end
	end
end

function Compiler:GetVariable( Trace, Variable )
	local Ref, Scope = self:FindCell( Trace, Variable )
	local Cell = self.Cells[ Ref ]
	if Cell then return Ref, Cell.Type end
end

function Compiler:Assign( Trace, Variable, Type, Assign )
	local Class = API:GetClass( Type )
	
	if Assign == CELL_LOCAL then
		local Ref = self.Scope[ Variable ]
		
		if Ref then
			self:TestCell( Trace, Ref, Type, Variable )
		else
			Ref = self:NextRef( )
			self.Scope[ Variable ] = Ref
			self.Cells[ Ref ] = { Ref = Ref, Scope = self.ScopeID, Type = Type, Variable = Variable, Assign = Assign }
		end
		
		return Ref, self.ScopeID
	elseif Assign == CELL_GLOBAL then
		local Ref = self.GlobalScope[ Variable ]
		
		if Ref then
			self:TestCell( Trace, Ref, Type, Variable )	
		else
			Ref = self:NextRef( )
			self.GlobalScope[ Variable ] = Ref
			self.Cells[ Ref ] = { Ref = Ref, Scope = 0, Type = Type, Variable = Variable, Assign = Assign }
		end
		
		local LRef = self.Scope[ Variable ]
		if LRef then
			self:TraceError( Trace, "Global vairiable %s conflicts with %s variable %s", Variable, self.Cells[ LRef ].Assign, Variable )
		end
		
		self.Scope[ Variable ] = Ref
		return Ref, 0
	elseif Assign == CELL_INPUT then
		local Ref = self.InPorts[ Variable ]
		
		if Ref then
			self:TestCell( Trace, Ref, Type, Variable )
		else
			Ref = self:NextRef( )
			self.InPorts[ Variable ] = Ref
			self.Cells[ Ref ] = { Ref = Ref, Scope = -1, Type = Type, Variable = Variable, Assign = Assign }
		end
			
		local LRef = self.Scope[ Variable ]
		if LRef then
			self:TraceError( Trace, "Inport vairiable %s conflicts with %s variable %s", Variable, self.Cells[ LRef ].Assign, Variable )
		end
		
		self.Scope[ Variable ] = Ref
		return Ref, 0
	elseif Assign == CELL_OUTPUT then
		local Ref = self.OutPorts[ Variable ]
		
		if Ref then
			self:TestCell( Trace, Ref, Type, Variable )
		else
			Ref = self:NextRef( )
			self.OutPorts[ Variable ] = Ref
			self.Cells[ Ref ] = { Ref = Ref, Scope = -1, Type = Type, Variable = Variable, Assign = Assign }
		end
			
		local LRef = self.Scope[ Variable ]
		if LRef then
			self:TraceError( Trace, "Outport vairiable %s conflicts with %s variable %s", Variable, self.Cells[ LRef ].Assign, Variable )
		end
		
		self.Scope[ Variable ] = Ref
		return Ref, 0
	end
end