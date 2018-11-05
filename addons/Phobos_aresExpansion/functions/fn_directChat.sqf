//////////////////////////////////////////////////////////////
//
// Author: Eathox
// Version: 1.0
// Description: Globaly makes unit say message in dirrect chat.
// Changelog: None.
//
//////////////////////////////////////////////////////////////

//TODO make it so curator can hear when close (Need to get posistion fo curatorcamera for that)
//TODO make it so remotecontoledunits can hear it to

Params [
	["_Unit", Objnull, [Objnull]],
	["_ChatText", "", [""]],
	["_Distance", 40, [0]],
	"_AlivePlayers",
	"_ListeningPlayers"
];

if (isnull _Unit || {!alive _Unit} || {_ChatText isequalto ""}) exitwith {};

_AlivePlayers = call BIS_fnc_listPlayers select {Alive _x};
_ListeningPlayers = (_AlivePlayers select {_x distance _Unit <= _Distance});

if (Isnil "Phobos_fnc_Chat_ChannelId") then {
	//Create "Direct channel" on server
	{
		Phobos_fnc_Chat_ChannelId = radioChannelCreate [[67,67,67,1], "Direct channel", " (%UNIT_NAME)", []];
		publicvariable "Phobos_fnc_Chat_ChannelId";
	} remoteExecCall ["Call", 2];
};

[[_Unit, _ChatText], {
	params ["_Unit", "_ChatText"];
	Waituntil {!isnil "Phobos_fnc_Chat_ChannelId"};

	//Add Player and talking unit to the channel say the message and remove them.
	Phobos_fnc_Chat_ChannelId radioChannelAdd [Player, _Unit];
	_Unit customChat [Phobos_fnc_Chat_ChannelId, _ChatText];
	Phobos_fnc_Chat_ChannelId radioChannelRemove [Player, _Unit];
}] remoteExecCall ["Spawn", _ListeningPlayers];
