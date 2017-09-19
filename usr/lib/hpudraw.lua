local vector = require("vector");
local hpu = require("hpu");
hpudraw = {};

hpudraw.func = function(Fx,Fy,Fz,value,stepSize)
	for i=0.0,1.0+stepSize,stepSize do
		hpu.set(Fx(i),Fy(i),Fz(i),value);
	end
end;

hpudraw.line = function(beginPoint,endPoint,value)
	-- find the equations:
	local beginV = vector:new(beginPoint);
	local endV = vector:new(endPoint);
	local totalV = endV:subtract(beginV);

	local f = function(t,ind) return beginV.value[ind] + (totalV.value[ind] * t) end;
	
	-- find the minimum step size
	local maxima = 0;
	for k,v in pairs(totalV.value) do
	  if v>maxima then maxima=v end
	end;
	local stepSize = (1.0 / maxima)/2 ;
	
	-- run the stepsize till 1
	hpudraw(
	function(i) f(i,"x") end,
	function(i) f(i,"y") end,
	function(i) f(i,"z") end,
	value,stepSize
	)
end;



return hpudraw;