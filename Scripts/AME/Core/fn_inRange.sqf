/*
	Author: [C-L-F] NetFusion

	Description:
	Checks whether an object is in a given range to player.

	Parameter(s):
	0: OBJECT - the object which should be checked.
	1: NUMBER - the range to check.

	Returns:
	- BOOL - true if the object in in range, false if not.

	Example:
	[object, 10] call AME_Core_fnc_inRange;
*/

_object = _this select 0;
_distance = _this select 1;

if (_object isKindOf "Man") exitWith {player distance _object < _distance};

_playerPos = eyePos player;
_viewDirection = eyeDirection player;

_direction = _viewDirection vectorMultiply (_distance / (vectorMagnitude _viewDirection));

_object in lineIntersectsWith [_playerPos, _playerPos vectorAdd _direction] || player distance _object < _distance