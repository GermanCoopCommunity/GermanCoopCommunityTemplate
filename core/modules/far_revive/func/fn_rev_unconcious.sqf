////////////////////////////////////////////////
// Make Player Unconscious
////////////////////////////////////////////////
params ["_unit","_killer"];

if (isPlayer _unit) then {
	disableUserInput true;
};
//_unit setVariable ["GREUH_isUnconscious", 1, true];
[] spawn tcb_fnc_rev_reviveCamera;

// mute TFAR
[false] call tcb_fnc_rev_toggleTFAR;
	
// create marker
if (tcb_downedMarkers) then {
	["far_mapMarker", _unit] call tcb_fnc_NetCallEvent;
};

["setCaptive", [_unit, true]] call tcb_fnc_NetCallEvent;

// Death message
if (FAR_EnableDeathMessages) then {
	_name = _this call tcb_fnc_rev_showKiller;
	if (_name != "") then {
		[_name] spawn {
			if (opt_far_dm_running) exitWith {};
			opt_far_dm_running = true;
			sleep 3.5;
			_txt = format ["%1",(_this select 0)];
			_print = [
				["wounded by:","align = 'right' size = '0.8'","#f0bfbfbf"],				// grey
				["","<br/>"],
				[_txt, "align = 'right' size = '1.2' font='PuristaBold'","#f07f7f00"]	// yellow
			];
			[_print, safezoneX, 0.95] spawn BIS_fnc_typeText2;
			opt_far_dm_running = false;
		};
	};
};
	
// Eject unit if inside vehicle
if (vehicle _unit != _unit) then {
	unAssignVehicle _unit;
	_unit action ["GetOut",vehicle _unit];
	sleep 2;
};

_unit setDamage 0;
_unit setVelocity [0,0,0];
_unit allowDamage false;
//_unit playMove "AinjPpneMstpSnonWrflDnon_rolltoback";
_unit playActionNow "Down";
_unit playAction "Unconscious";

sleep 4;
//_unit switchMove "AinjPpneMstpSnonWrflDnon";
_unit enableSimulation false;
_unit setVariable ["FAR_isUnconscious", 1, true];
	

_bleedOut = time + FAR_BleedOut;

// fix the key binding after respawn/revive
disableUserInput false;
disableUserInput true;
disableUserInput false;

while {!isNull _unit && {alive _unit} && {_unit getVariable "FAR_isUnconscious" == 1} && {_unit getVariable "FAR_isStabilized" == 0} && {(FAR_BleedOut <= 0 || time < _bleedOut)}} do {
	if (FAR_checkNearbyMedics) then {hintSilent format["Bleedout in %1 seconds\n\n%2", round (_bleedOut - time), call tcb_fnc_rev_CheckFriendlies]};
	public_bleedout_message = format ["Bleedout in %1 seconds", round (_bleedOut - time)];
	public_bleedout_timer = round (_bleedOut - time);
	sleep 0.5;
};

if (_unit getVariable ["FAR_isStabilized",1] == 1) then {
	//Unit has been stabilized. Disregard bleedout timer and unmute player
	[true] call tcb_fnc_rev_toggleTFAR;
			
	while {!isNull _unit && {alive _unit} && {_unit getVariable "FAR_isUnconscious" == 1}} do {
		if (FAR_checkNearbyMedics) then {hintSilent format ["You have been stabilized\n\n%1", call tcb_fnc_rev_CheckFriendlies]};
		public_bleedout_message = "Stabilized";
		public_bleedout_timer = FAR_BleedOut;
		sleep 0.5;
	};
};


// Player bled out
if (FAR_BleedOut > 0 && {time > _bleedOut} && {_unit getVariable ["FAR_isStabilized",0] == 0}) then {
	_unit setDamage 1;
	disableUserInput false;
	_unit allowDamage true;
	["setCaptive", [_unit, false]] call tcb_fnc_NetCallEvent;
} else {
	// Player got revived
	_unit setVariable ["FAR_isStabilized", 0, true];
	["far_removeMapMarker", _unit] call tcb_fnc_NetCallEvent;
	sleep 3;
	["setCaptive", [_unit, false]] call tcb_fnc_NetCallEvent;
	
	// Clear the "medic nearby" hint
	hintSilent "";

	// Unmute TFAR
	[true] call tcb_fnc_rev_toggleTFAR;
	
	_unit enableSimulation true;
	_unit allowDamage true;
	_unit setDamage 0.6;
	_unit setFatigue 0.9;
	_unit playActionNow "agonyStop";
	
	if (dialog) then {
		[] spawn {
			while {dialog} do {
				closeDialog 5566;
				closeDialog 5651;
				closeDialog 0;
			};
		};
	};
};

true