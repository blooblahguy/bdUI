local parent, ns = ...
ns.oUF = {}
ns.oUF.Private = {}
if (select(4, GetBuildInfo()) < 20000) then
	ns.oUF.classic = true
end
