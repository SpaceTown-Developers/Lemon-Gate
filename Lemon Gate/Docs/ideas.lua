==== Class Creation ====
E_Atype vector(v)
	x = 0, y = 0, z = 0
end

-- Is the same as:

E_A:RegisterClass("vector","v",{x = 0, y = 0, z = 0})

-- This will register a lua builder string: "{['x'] = 0, ['y'] = 0, ['z'] = 0}"
-- Oh and yes the builder supports tables in tables in tables in tables in tables.


==== Example Inline Operator ==== 

-- Changed into: E_Aoperator vector op== (vector vec, vector vec2)

inline E_Aoperator vector (vector a == vector b)
	(a.x == b.x and a.y == b.y and a.z == b.z)
end

-- Is the same as:

E_A:RegisterOperator(true, "v==v","n","(%1.x == %2.x and %1.y == %2.y and %1.z == %2.z)")



==== Example Function ====



E_Afunction number vector:distance(vector vec)
	local x, y, z = this.x - vec.x, this.y - vec.y, this.z - vec.z
	return (x * x + y * y + z * z) ^ 0.5
end

-- Is the same as:

E_A:RegisterFunction(false, "distance", "v:v", "n", function(self, this, vec)
	local x, y, z = this.x - vec.x, this.y - vec.y, this.z - vec.z
	return (x * x + y * y + z * z) ^ 0.5
end)



==== Lets Try And Inline It ====

inline E_Afunction number vector:distance(vector vec)
	(((this.x - vec.x) * (this.x - vec.x) + (this.y - vec.y) * (this.y - vec.y) + (this.z - vec.z) * (this.z - vec.z)) ^ 0.5)
end

inline E_Afunction number vector:distance(vector vec)
	"(((@this.x - @vec.x) * (@this.x - @vec.x) + (@this.y - @vec.y) * (@this.y - @vec.y) + (@this.z - @vec.z) * (@this.z - @vec.z)) ^ 0.5)"
end

-- Is the same as:

E_A:RegisterFunction(true, "distance", "v:v", "n",
	"(((%1.x - %2.x) * (%1.x - %2.x) + (%1.y - %2.y) * (%1.y - %2.y) + (%1.z - %2.z) * (%1.z - %2.z)) ^ 0.5)"
end)

-- Now when this has to be handeled by a function it will be, otherwise it will just adapt itself into the lua line.






==== Ideas Sub Section ====

background op codes:
@= -- type check function
@> -- output converter
@< -- input converter