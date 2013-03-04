
local Data = { } 
LemonGate.HelperFunctionData = Data 


Data["print(...)"] = "Prints all arguments to chat." 
Data["exit()"] = "Exits current execution." 

Data["gate( e)"] = "Returns the entity of the LemonGate." 
Data["owner( e)"] = "Returns the owner of the LemonGate." 
Data["selfDestruct()"] = "Removes the LemonGate. " 
Data["gateName( s)"] = "Returns the name of the LemonGate." 
Data["gateName(s)"] = "Sets the name of the LemonGate." 

Data["perf( n)"] = "Returns the current used performance points." 
Data["maxPerf( n)"] = "Returns the maximum performance points the code can use." 
Data["perfPer( n)"] = "Returns the percentage of performance points used." 

Data["curTime( n)"] = "Returns the server current uptime." 
Data["time(s n)"] = "Returns the server time in unit S" 

Data["getPlayers( t)"] = "Returns a table of all the players on the server." 
Data["findByClass(s t)"] = "Returns a table of all entities of class S." 
Data["findByModel(s t)"] = "Returns a table of all entities of model S." 
Data["findInSphere(vn t)"] = "Returns a table of all entities within a distance of N from point V." 
Data["findInBox(vv t)"] = "Returns a table of all entities within inside V1 min and V2 max." 
Data["findInCone(vvna t)"] = "Returns a table of all entities within inside a cone." 

Data["eyeTrace(e: t)"] = "Returns a trace of the player eye." 
Data["trace(vv t)"] = "Returns a trace between V1 and V2." 
Data["trace(vvn t)"] = "Same as t = trace(vv), but the trace can hit water when N is 1." 
Data["trace(vvnt t)"] = "Same as y = trace(vvn), but T is a table of entities to filter." 
Data["traceHull(vvv t)"] = "Returns a hull trace between V1 and V2 where V3 is boxsize." 
Data["traceHull(vvvn t)"] = "Same as t = traceHull(vvv), but the trace can hit water when N is 1." 
Data["traceHull(vvvnt t)"] = "Same as t = traceHull(vvvn), but T is a table of entities to filter." 

// TODO: EGP Descriptions!

Data["httpRequests(sff)"] = "Makes a HTTP GET request to S and calls F1 with Body[String] on success and F2 with no parameters on failure." 
Data["httpRequests(stff)"] = "Makes a HTTP POST request to S with POST headers T and calls F1 with Body[String] on success and F2 with no parameters on failure." 


Data[""] = "" 
