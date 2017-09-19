local vector = require("vector");
local hpu = require("hpu");
hpudraw = {};

hpudraw.func = function(Fx,Fy,Fz,value,stepSize)
	for i=0.0,1.0+stepSize,stepSize do
		hpu.set(Fx(i),Fy(i),Fz(i),value);
	end
end;

hpudraw.line = function(beginPoint,endPoint,value)
	local p1 = vector:new(beginPoint);
	local p2 = vector:new(endPoint);
	local ftable = vector.math.lineEquationTable(p1,p2);
	hpudraw.func(ftable.x, ftable.y, ftable.z, value,ftable.step);
end;

hpudraw.vertex = function(p1,p2,p3,value) 
	checkArg(1,p1,"table");
	checkArg(2,p2,"table");
	checkArg(3,p3,"table");
	checkArg(4,value,"number","nil");
	local v1,v2,v3 = vector:new(p1),vector:new(p2),vector:new(p3);
	local fp12 = vector.math.lineEquationTable(v1,v2);
	for i=0.0,1.0+fp12.step,fp12.step do
		local vt = {x=fp12.x(i),y=fp12.y(i),z=fp12.z(i)};
		hpudraw.line(vt,v3.value,value);
	end
end;

return hpudraw;