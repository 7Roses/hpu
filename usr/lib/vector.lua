local vector = {}
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
return vector;