local vector = {}
-- maybe extract this?
local function getSize(targetTable)
	local numItems = 0
	for k,v in pairs(targetTable) do
		numItems = numItems + 1
	end
	return numItems;
end

function vector:new(tableOfVector) 
	o = {value=(tableOfVector or {})}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o;
end;
vector.add = function(self,otherVector)
	local newVector = {}
	for k,v in pairs(self.value) do
		newVector[k] = self.value[k] + (otherVector.value[k] or 0);
	end;
	return vector:new(newVector);
end;

vector.subtract = function(self,otherVector)
	local newVector = {}
	for k,v in pairs(self.value) do
		newVector[k] = self.value[k] - (otherVector.value[k] or 0);
	end;
	return vector:new(newVector);
end;

vector.scalarMult = function(self,multiplicator)
	local newVector = {}
	for k,v in pairs(self.value) do
		newVector[k] = self.value[k] * multiplicator;
	end
	return vector:new(newVector);
end;

vector.dotProduct = function(self,otherVector)
	assert(getSize(self.value) == getSize(otherVector.value),"same lengths are required");
	local product = 0;
	for k,v in pairs(self.value) do
		product = product + (self.value[k] * otherVector.value[k]);
	end
	return product;
end;

vector.crossProduct = function(self,otherVector)
	assert((getSize(self.value) == 3 and getSize(otherVector.value) == 3),"sorry no >3 vectors supported at this moment.");
	return vector:new({
		x = (self.value.y * otherVector.value.z - self.value.z * otherVector.value.y),
		y = (self.value.z * otherVector.value.x - self.value.x * otherVector.value.z),
		z = (self.value.x * otherVector.value.y - self.value.y * otherVector.value.x),
	});
end;

-- functions to get vectors of equations. (can be used to calculate points for every x,y,z for a given t value)
vector.math = {};
vector.math.lineEquationTable = function(p1,p2)
	local beginV = p1;
	local endV = p2;
	local totalV = endV:subtract(beginV);

	local f = function(t,ind) return beginV.value[ind] + (totalV.value[ind] * t) end; -- the equation for a line
	
	-- find the minimum step size
	local maxima = 0;
	for k,v in pairs(totalV.value) do
	  if v>maxima then maxima=v end
	end;
	local stepSize = (1.0 / maxima)/2 ;
	
	-- run the stepsize till 1
	return {x=(function(i) return f(i,"x") end),y=(function(i) return f(i,"y") end),z=(function(i) return f(i,"z") end),step=stepSize};
end;

return vector;