﻿//macro file
#define __tkccppfln(tkfile1) call compile preprocessFileLineNumbers (TK_PATH + #tkfile1)
#define __tkcppfln(tkdfunc,tkfile2) tkdfunc = compile preprocessFileLineNumbers (TK_PATH + #tkfile2)
#define __tkwaitpl [] spawn {waitUntil {!isNull player};TK_INIT = true}
#define __tksleep sleep 0.152
#define __TKJIPGetVar(jvarname) (TcB_Ref_Point getVariable #jvarname)
#define __TKJIPSetVar TcB_Ref_Point setVariable