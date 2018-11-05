//////////////////////////////////////////////////////////////
//
// Author: Eathox
// Version: 1.0
// Description: Remotely creates ChatUI on players screen.
// Changelog: None.
//
//////////////////////////////////////////////////////////////

/*
	Author: Eathox

	Description:
	Opens a chatui wich allows for conversations between a player and AI (To change the name of the Ai use https://community.bistudio.com/wiki/setName)
	This does support sound, Soundconfig requires duration to be defined.
	Chat has a limited distance of 15 meters;
	(Chat is logged in sidechat/globalchat Do note that all Structured text will be removed from this)

	Parameter(s):
	0: ARRAY - Array of Targets
		0: OBJECT - Talking unit
		1: OBJECT - Talked to unit
	1: ARRAY - Array of all textsections
		0: ARRAY - Array of the frist textsection
			0: NUMBER - Number as the ID of the textsection
			1: ARRAY - Array of text params
				0: STRING - Structured text to display (As if said by the Talking unit)
				1: INTEGER (OPTIONAL) - Direct chat distance
				2: ARRAY (OPTIONAL) - Array of soundparams
					0: STRING (OPTIONAL) - SoundConfig
					1: BOOL (OPTIONAL) - isSay3D
			2: ARRAY - Array of all response's
				0: ARRAY - Array of the frist response
					0: NUMBER/STRING - (Number) ID Number of the next TextSection (- number to Close UI) (String) "+" To go up an number "-" to Close UI
					1: STRING - Response Text (if Text starts with ( and ends with ) it wont be said in chat)
					2: INTEGER (OPTIONAL) - Direct chat distance
					3: ARRAY (OPTIONAL) - Array of soundparams
						0: STRING (OPTIONAL) - SoundConfig
						1: BOOL (OPTIONAL) - isSay3D
					4: ARRAY (OPTIONAL) - Array of codeparams
						0: STRING/CODE - Code to execute once the option has been
						1: ARRAY (OPTIONAL) - Arguments to pass in to the code
					5: ARRAY (OPTIONAL) - Array of conditionparams
						0: STRING/CODE - Conidtion code that must return true for the response to be shown
						1: ARRAY (OPTIONAL) - Arguments to pass in to the conidtion
	2: ARRAY (OPTIONAL) - Array of on close codeparams
		0: STRING/CODE - Code to execute once the conversation was closed
		1: ARRAY (OPTIONAL) - Arguments to pass in to the on close code
	3: BOOL (OPTIONAL) - Disable closing of UI with escape
	4: STRING (OPTIONAL) - Name of talking Unit

	Returns:
	none

	Example:
	[
		[Ai, (call BIS_fnc_listplayers select 0)], [
			[0,
			["Is this working?"], [
				["+", "Yes"],
				[2, "Dont think so"]
			]],

			[2,
			["Check Again"], [
				[0, "Sure"],
				["-", "Sorry Mate i realy cant", "", True]
			]],

			[1,
			["Thanks for telling me Have a good one!"], [
				[-1, "You to laddy", "", True]
			]]
		], [
			{},[]
		],
		false,
		"Bob Joe"
	] Call Phobos_fnc_remoteConversation
*/

disableserialization;

#define IDC_ChatUI			180000
#define IDC_TitleBar_Background			180001
#define IDC_TitleBar_TextLeft			180002
#define IDC_TitleBar_TextRight			180003
#define IDC_Text_Background1			180004
#define IDC_Text_Background2			180005
#define IDC_Text_Group			180006
#define IDC_Text_Group_Text			180007
#define IDC_Response_Background			180008
#define IDC_Response			180009
#define IDC_Response_Confirm			180010

#define DISPLAY_X 5.5 * (((safezoneW / safezoneH) min 1.2) / 40)
#define DISPLAY_Y 15.45 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
#define DISPLAY_W 22.3 * (((safezoneW / safezoneH) min 1.2) / 40)
#define DISPLAY_H 24.45 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
#define Ctrl_H1 1 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)

#define MAXDISTANCE 15
#define CONVERSATION_DISPLAY UINameSpace Getvariable "Phobos_fnc_Chat_Display"

params [
	["_Targets", [], [[]]]
];

_Targets params [
	["_TalkingUnit", Objnull, [Objnull]],
	["_TalkedToUnit", Objnull, [Objnull]]
];

if (isNull _TalkedToUnit || {!alive _TalkedToUnit} || {!isPlayer _TalkedToUnit} || {isPlayer _TalkingUnit} || {_TalkedToUnit distance _TalkingUnit > MAXDISTANCE && !isNull _TalkingUnit} || {Is3den}) exitWith {};
if (_TalkedToUnit getvariable ["InConversation", false]) exitWith {};

[_This, {
	params [
		["_Targets", [], [[]]],
		["_ChatParams", [], [[]]],
		["_OnCloseCodeParams", [], [[]]],
		["_DisableEsc", True, [True]],
		["_TalkingUnitName", "", [""]],
		"_display_Close",
		"_chatSection_Next",
		"_chatSection_Show",
		"_chatSection_PlaySoundConfig",
		"_playerColor",
		"_display",
		"_ctrlCA_Vignette",
		"_ctrlChatUI",
		"_ctrlChatUI_TitleBar_Background",
		"_ctrlChatUI_TitleBar_TextLeft",
		"_ctrlChatUI_TitleBar_TextRight",
		"_ctrlChatUI_Text_Background1",
		"_ctrlChatUI_Text_Background2",
		"_ctrlChatUI_Text_Group",
		"_ctrlChatUI_Text_Group_Text",
		"_ctrlChatUI_Response_Background",
		"_ctrlChatUI_Response",
		"_ctrlChatUI_Response_Confirm",
		"_ctrlChatUI_TitleBar_TextLeft_Position",
		"_CurrentWidth",
		"_MaxWidth",
		"_ctrlChatUI_Position",
		"_SavedPosition"
	];

	_Targets params [
		["_TalkingUnit", Objnull, [Objnull]],
		["_TalkedToUnit", Objnull, [Objnull]]
	];

	_playerColor = [
		(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13]),
		(profilenamespace getvariable ['GUI_BCG_RGB_G',0.54]),
		(profilenamespace getvariable ['GUI_BCG_RGB_B',0.21]),
		(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])
	];

	createdialog "RscDisplayEmpty";
	_display = findDisplay -1;

	_display_Close = {
		params ["_display","_onCloseCodeParams","_ctrlChatUI_Position"];

		_display = CONVERSATION_DISPLAY;
		_onCloseCodeParams = _display GetVariable ["_OnCloseCodeParams", []];

		_ctrlChatUI_Position = ctrlPosition (_display displayctrl IDC_ChatUI);
		MissionNameSpace Setvariable ["Phobos_fnc_Chat_SavedPosition", [_ctrlChatUI_Position select 0, _ctrlChatUI_Position select 1]];

		(_display getvariable "_Targets") Params [
			["_TalkingUnit", Objnull, [Objnull]],
			["_TalkedToUnit", Objnull, [Objnull]]
		];

		_onCloseCodeParams params [
			["_OnCloseCode", {}, [{}, ""]],
			["_OnCloseCodeArguments", [], [[]]]
		];

		closedialog 2;
		_OnCloseCode = if (_OnCloseCode isequaltype "") then {compile _OnCloseCode} else {_OnCloseCode};
		[_OnCloseCode, _TalkedToUnit, _TalkingUnit, _OnCloseCodeArguments] spawn {_TalkedToUnit = _This select 1; _TalkingUnit = _This select 2; (_This select 3) call (_This select 0)};

		[[_TalkedToUnit, _TalkingUnit], {_x setVariable ["InConversation", nil]}] remoteExecCall ["Apply"];
		UINameSpace setvariable ["Phobos_fnc_Chat_Display", nil];
	};

	_chatSection_Next = {
		params ["_display","_ctrlChatUI_Response","_LbIndex","_LbText","_LbData","_ChatCount","_display_Close","_NextText","_DirectChat_Distance","_Code","_CodeArguments","_SoundConfig","_isSay3D","_TargetId"];

		_display = CONVERSATION_DISPLAY;
		(_display getvariable "_Targets") Params [
			["_TalkingUnit", Objnull, [Objnull]],
			["_TalkedToUnit", Objnull, [Objnull]]
		];

		_ctrlChatUI_Response = _display displayctrl IDC_Response;
		_LbIndex = lbCursel _ctrlChatUI_Response;
		_LbText = _ctrlChatUI_Response lbtext _LbIndex;
		_LbText = _LbText select [(_LbText find " ")+1, (Count _LbText)-3];
		_LbData = _ctrlChatUI_Response getvariable [str _LbIndex, [-1, {}, []]];
		_ChatCount = _display getvariable ["_ChatCount", 0];
		_display_Close = _display getVariable "_display_Close";

		_NextText = _LbData select 0;
		_DirectChat_Distance = _LbData select 1;
		_Code = _LbData select 2;
		_CodeArguments = _LbData select 3;
		_SoundConfig = _LbData select 4;
		_isSay3D = _LbData select 5;

		_Code = if (_Code isequaltype "") then {compile _Code} else {_Code};
		_CodeArguments call _Code;

		[[_TalkedToUnit, _SoundConfig, _isSay3D], False] Spawn (_display getVariable "_chatSection_PlaySoundConfig");
		if !(_LbText Select [0,1] isequalto "(" && _LbText select [Count _LbText -1, 1] isequalto ")") then {
			[_TalkedToUnit, _LbText, _DirectChat_Distance] Call (_display getVariable "_chatSection_Directchat");
		};

		if (_ChatCount < 2 || Lbsize _ctrlChatUI_Response isequalto 0) exitwith {call _display_Close};
		If (_NextText isequaltype 0 && {_NextText < 0}) exitwith {call _display_Close};
		If (_NextText isequaltype "" && {_NextText select [0,1] isequalto "-"}) exitwith {call _display_Close};

		if (_NextText isequaltype "") then {
			_NextText = ["1", _NextText select [1, (Count _NextText)-1]] select !(_NextText isequalto "+");
		};

		lbClear _ctrlChatUI_Response;
		ctrlsetfocus _ctrlChatUI_Response;

		_TargetId = ([(_display getvariable "CurrentId") + (_NextText call BIS_fnc_ParseNumber), _NextText] select (_NextText isequaltype 0));
		{if ((_x select 0) isequalto _TargetId) exitwith {_x call (_display getVariable "_chatSection_Show")}} foreach (_display getvariable "_ChatParams");
	};

	_chatSection_Show = {
		params [
			["_Id", 0, [0]],
			["_TextParams", [], [[]]],
			["_ResponseParams", [], [[]]],
			"_display",
			"_ctrlChatUI_Response",
			"_ctrlChatUI_Text_Group_Text",
			"_CountText",
			"_HTMLCode",
			"_MinHeight",
			"_CurrentHeight",
			"_Width",
			"_Pos",
			"_LbIndex"
		];

		_TextParams Params [
			["_Text", "", [""]],
			["_DirectChat_Distance", 40, [0]],
			["_SoundParams", [], [[]]]
		];

		_SoundParams Params [
			["_SoundConfig", "", [""]],
			["_isSay3D", True, [True]]
		];

		_display = CONVERSATION_DISPLAY;
		(_display getvariable "_Targets") Params [
			["_TalkingUnit", Objnull, [Objnull]],
			["_TalkedToUnit", Objnull, [Objnull]]
		];
		_display setvariable ["CurrentId", _Id];

		_ctrlChatUI_Response = _display displayctrl IDC_Response;
		_ctrlChatUI_Text_Group_Text = _display displayctrl IDC_Text_Group_Text;
		_ctrlChatUI_Text_Group_Text ctrlsetstructuredtext parsetext _Text;

		//Remove All structeredtext componets
		_Text = _Text splitstring "";
		_CountText = Count _Text;
		_HTMLCode = false;
		for "_i" from 0 to _CountText-1 do {
			private _Char = _Text Select _i;
			If (_Char isequalto "<" || (_Char isequalto ">" && _HTMLCode)) then {_HTMLCode = !_HTMLCode} else {
				If (!_HTMLCode) then {_Text pushback _Char};
			};
		};
		_Text = _Text select [_CountText, Count _Text - _CountText] joinstring "";

		[[_TalkingUnit, _SoundConfig, _isSay3D], True] Spawn (_display getVariable "_chatSection_PlaySoundConfig");
		[_TalkingUnit, _Text, _DirectChat_Distance] Call (_display getVariable "_chatSection_Directchat");

		_MinHeight = 4.2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25);
		_CurrentHeight = CtrlTextHeight _ctrlChatUI_Text_Group_Text + 0.2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25);
		_Width = [21.6 * (((safezoneW / safezoneH) min 1.2) / 40), 21 * (((safezoneW / safezoneH) min 1.2) / 40)] select (_CurrentHeight > _MinHeight);

		_Pos = CtrlPosition _ctrlChatUI_Text_Group_Text;
		_Pos set [2, _Width];
		_Pos set [3, (_MinHeight Max _CurrentHeight)];
		_ctrlChatUI_Text_Group_Text CtrlSetPosition _Pos;
		_ctrlChatUI_Text_Group_Text CtrlCommit 0;

		{
			_x params [
				["_NextText", 0, [0, ""]],
				["_Response", "", [""]],
				["_DirectChat_Distance", 40, [0]],
				["_SoundParams", [], [[]]],
				["_CodeParams", [], [[]]],
				["_ConditionParams", [], [[]]]
			];

			_SoundParams Params [
				["_SoundConfig", "", [""]],
				["_isSay3D", True, [True]]
			];

			_CodeParams params [
				["_Code", {}, [{}, ""]],
				["_CodeArguments", [], [[]]]
			];

			_ConditionParams params [
				["_Condition", {true}, [{}, ""]],
				["_ConditionArguments", [], [[]]]
			];

			_Condition = if (_Condition isequaltype "") then {compile _Condition} else {_Condition};
			if (_ConditionArguments call _Condition) then {
				_LbIndex = _ctrlChatUI_Response lbAdd format ["%1. %2", (lbSize _ctrlChatUI_Response)+1, _Response];
				_ctrlChatUI_Response setvariable [str _LbIndex, [_NextText, _DirectChat_Distance, _Code, _CodeArguments, _SoundConfig, _isSay3D]];
				if (_Response Select [0,1] isequalto "(" && _Response select [Count _Response -1, 1] isequalto ")") then {
					_ctrlChatUI_Response lbSetColor [_LbIndex, [1,1,1,0.5]];
				};
			};
		} foreach _ResponseParams;
		if (lbSize _ctrlChatUI_Response > 0) then {_ctrlChatUI_Response lbsetcursel 0};
	};

	_chatSection_Directchat = {
		Params [
			["_Unit", Objnull, [Objnull]],
			["_ChatText", "", [""]],
			["_Distance", 40, [0]],
			"_AlivePlayers",
			"_ListeningPlayers"
		];

		if (isnull _Unit || !alive _Unit || _ChatText isequalto "") exitwith {};

		_AlivePlayers = (call BIS_fnc_listplayers + call BIS_fnc_listCuratorPlayers) select {Alive _x};
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
	};

	_chatSection_PlaySoundConfig = {
		params [
			["_TalkParams", [], [[]]],
			["_AddToQue", False, [False]],
			"_display",
			"_Duration",
			"_SoundSource"
		];

		_TalkParams params [
			["_Unit", Objnull, [Objnull]],
			["_SoundConfig", "", [""]],
			["_isSay3D", True, [True]]
		];

		if (_Unit isequalto Objnull || _SoundConfig isequalto "") exitwith {};
		_display = CONVERSATION_DISPLAY;

		If (isnil "Phobos_fnc_Chat_SoundPlaying") then {Phobos_fnc_Chat_SoundPlaying = Objnull; Publicvariable "Phobos_fnc_Chat_SoundPlaying"};
		If (isnil "Phobos_fnc_Chat_SoundQue") then {Phobos_fnc_Chat_SoundQue = []; publicvariable "Phobos_fnc_Chat_SoundQue"};
		_Duration = getnumber (configFile >> "CfgSounds" >> _SoundConfig >> "duration");

		if (_AddToQue && !(Phobos_fnc_Chat_SoundPlaying isequalto Objnull)) exitwith {Phobos_fnc_Chat_SoundQue pushback [_TalkParams, _AddToQue]};

		if !(Phobos_fnc_Chat_SoundPlaying isequalto Objnull) then {
			deletevehicle Phobos_fnc_Chat_SoundPlaying;

			Phobos_fnc_Chat_SoundPlaying = Objnull;
			Publicvariable "Phobos_fnc_Chat_SoundPlaying";

			Phobos_fnc_Chat_SoundQue = [];
			publicvariable "Phobos_fnc_Chat_SoundQue";
		};

		_SoundSource = "#particlesource" createVehicle getpos _Unit;
		[_SoundSource, _SoundConfig] remoteExecCall [(["Say2D", "Say3D"] select _isSay3D)];
		Phobos_fnc_Chat_SoundPlaying = _SoundSource;
		publicvariable "Phobos_fnc_Chat_SoundPlaying";

		UiSleep _Duration;

		Phobos_fnc_Chat_SoundPlaying = Objnull;
		publicvariable "Phobos_fnc_Chat_SoundPlaying";
		if !(Phobos_fnc_Chat_SoundQue isequalto []) exitwith {
			(Phobos_fnc_Chat_SoundQue select 0) spawn (_display getVariable "_chatSection_PlaySoundConfig");

			Phobos_fnc_Chat_SoundQue deleteAt 0;
			publicvariable "Phobos_fnc_Chat_SoundQue";
		};
	};

	[_Targets, {_x setVariable ["InConversation", True]}] remoteExec ["Apply"];

	if (isNull _TalkingUnit) then {
		"C_man_1" createUnit [[0,0,0], createGroup [side _TalkedToUnit, true], "ETO_fnc_Chat_TempUnit = this; this hideObject true; this allowDamage false; this enableSimulation false; this disableAi 'ALL'; this setVariable ['InConversation', True];"];
		private _unit = Phobos_fnc_Chat_TempUnit;
		_TalkingUnit = _unit;

		_Targets set [0, _unit];
		_TalkingUnit attachTo [vehicle _TalkedToUnit, [0,0,0]];
		_TalkingUnit spawn {
			waitUntil {!(_this getVariable ["InConversation", false])};
			deleteVehicle _this;
			detach _this;
		};
	};

	if !(_TalkingUnitName isequalto "") then {[_TalkingUnit, _TalkingUnitName] remoteExec ["setName"]};

	_display setvariable ["_ChatCount", Count _ChatParams];
	_display setvariable ["_Targets", _Targets];
	_display setvariable ["_ChatParams", _ChatParams];
	_display setvariable ["_OnCloseCodeParams", _OnCloseCodeParams];
	_display setVariable ["_display_Close", _display_Close];
	_display setVariable ["_chatSection_Show", _chatSection_Show];
	_display setVariable ["_chatSection_Directchat", _chatSection_Directchat];
	_display setVariable ["_chatSection_PlaySoundConfig", _chatSection_PlaySoundConfig];
	UINameSpace setvariable ["Phobos_fnc_Chat_Display", _display];

	//Create UI
	_ctrlCA_Vignette = _display DisplayCtrl 1202;
	_ctrlCA_Vignette ctrlshow false;

	_ctrlChatUI = _display ctrlCreate ["RscControlsGroup", IDC_ChatUI];
	_ctrlChatUI ctrlSetPosition [DISPLAY_X, DISPLAY_Y, DISPLAY_W, DISPLAY_H];
	_ctrlChatUI ctrlCommit 0;

	_ctrlChatUI_TitleBar_Background = _display ctrlCreate ["RscBackground", IDC_TitleBar_Background, _ctrlChatUI];
	_ctrlChatUI_TitleBar_Background ctrlSetPosition [
		0,
		0,
		DISPLAY_W,
		Ctrl_H1
	];
	_ctrlChatUI_TitleBar_Background ctrlSetBackgroundColor _playerColor;
	_ctrlChatUI_TitleBar_Background ctrlCommit 0;

	_ctrlChatUI_TitleBar_TextLeft = _display ctrlCreate ["RscTextNoShadow", IDC_TitleBar_TextLeft, _ctrlChatUI];
	_ctrlChatUI_TitleBar_TextLeft ctrlSetPosition [
		0,
		0,
		DISPLAY_W - (2.1868 * (((safezoneW / safezoneH) min 1.2) / 40)),
		Ctrl_H1
	];
	_ctrlChatUI_TitleBar_TextLeft ctrlCommit 0;

	_ctrlChatUI_TitleBar_TextRight = _display ctrlCreate ["RscTextNoShadow", IDC_TitleBar_TextRight, _ctrlChatUI];
	_ctrlChatUI_TitleBar_TextRight ctrlSetPosition [
		((CtrlPosition _ctrlChatUI_TitleBar_TextLeft) select 2),
		0,
		2.1868 * (((safezoneW / safezoneH) min 1.2) / 40),
		Ctrl_H1
	];
	_ctrlChatUI_TitleBar_TextRight ctrlSetText "CHAT";
	_ctrlChatUI_TitleBar_TextRight ctrlCommit 0;

	_ctrlChatUI_Text_Background1 = _display ctrlCreate ["RscBackground", IDC_Text_Background1, _ctrlChatUI];
	_ctrlChatUI_Text_Background1 ctrlSetPosition [
		0,
		1.10 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25),
		DISPLAY_W,
		4.9 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
	];
	_ctrlChatUI_Text_Background1 ctrlSetBackgroundColor [0,0,0,0.6];
	_ctrlChatUI_Text_Background1 ctrlCommit 0;

	_ctrlChatUI_Text_Background2 = _display ctrlCreate ["RscBackground", IDC_Text_Background2, _ctrlChatUI];
	_ctrlChatUI_Text_Background2 ctrlSetPosition [
		0.35 * (((safezoneW / safezoneH) min 1.2) / 40),
		1.45 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25),
		21.6 * (((safezoneW / safezoneH) min 1.2) / 40),
		4.2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
	];
	_ctrlChatUI_Text_Background2 ctrlSetBackgroundColor [0,0,0,0.4];
	_ctrlChatUI_Text_Background2 ctrlCommit 0;

	_ctrlChatUI_Text_Group = _display ctrlCreate ["RscControlsGroup", IDC_Text_Group, _ctrlChatUI];
	_ctrlChatUI_Text_Group ctrlSetPosition [
		((CtrlPosition _ctrlChatUI_Text_Background2) select 0),
		((CtrlPosition _ctrlChatUI_Text_Background2) select 1),
		((CtrlPosition _ctrlChatUI_Text_Background2) select 2),
		((CtrlPosition _ctrlChatUI_Text_Background2) select 3)
	];
	_ctrlChatUI_Text_Group ctrlCommit 0;

	_ctrlChatUI_Text_Group_Text = _display ctrlCreate ["RscStructuredText", IDC_Text_Group_Text, _ctrlChatUI_Text_Group];
	_ctrlChatUI_Text_Group_Text ctrlSetPosition [
		0,
		0,
		((CtrlPosition _ctrlChatUI_Text_Group) select 2),
		((CtrlPosition _ctrlChatUI_Text_Group) select 3)
	];
	_ctrlChatUI_Text_Group_Text ctrlCommit 0;

	_ctrlChatUI_Response_Background = _display ctrlCreate ["RscBackground", IDC_Response_Background, _ctrlChatUI];
	_ctrlChatUI_Response_Background ctrlSetPosition [
		0,
		6.1 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25),
		DISPLAY_W,
		2.9 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
	];
	_ctrlChatUI_Response_Background ctrlSetBackgroundColor [0,0,0,0.6];
	_ctrlChatUI_Response_Background ctrlCommit 0;

	_ctrlChatUI_Response = _display ctrlCreate ["RscListBox", IDC_Response, _ctrlChatUI];
	_ctrlChatUI_Response ctrlSetPosition [
		0,
		((CtrlPosition _ctrlChatUI_Response_Background) select 1),
		((CtrlPosition _ctrlChatUI_Response_Background) select 2) - (2 * (((safezoneW / safezoneH) min 1.2) / 40)),
		((CtrlPosition _ctrlChatUI_Response_Background) select 3)
	];
	_ctrlChatUI_Response ctrlSetBackgroundColor [0,0,0,0.3];
	_ctrlChatUI_Response ctrlCommit 0;

	_ctrlChatUI_Response_Confirm = _display ctrlCreate ["CtrlButtonPictureKeepAspect", IDC_Response_Confirm, _ctrlChatUI];
	_ctrlChatUI_Response_Confirm ctrlSetPosition [
		((CtrlPosition _ctrlChatUI_Response) select 2),
		((CtrlPosition _ctrlChatUI_Response) select 1),
		2 * (((safezoneW / safezoneH) min 1.2) / 40),
		((CtrlPosition _ctrlChatUI_Response) select 3)
	];
	_ctrlChatUI_Response_Confirm ctrlSetBackgroundColor [0,0,0,0.3];
	_ctrlChatUI_Response_Confirm ctrlSetText "\a3\3Den\Data\Attributes\ComboPreview\play_ca.paa";
	_ctrlChatUI_Response_Confirm ctrlCommit 0;

	//Assign keybinds
	_display DisplayAddEventHandler ["KeyDown", "if ((_this select 1) in [0x1C, 0x9C, 0x39]) then {call"+(str _chatSection_Next)+(["}; if ((_This select 1) isequalto 0x01) then "+Str _display_Close, "}; True"] select _DisableEsc)];
	[_TalkedToUnit, _TalkingUnit, _display] spawn {
		params ["_TalkedToUnit", "_TalkingUnit", "_display"];
		Waituntil {!alive _TalkedToUnit || !alive _TalkingUnit || _TalkedToUnit distance _TalkingUnit > MAXDISTANCE || isnull _display};
		if (!alive _TalkedToUnit || !alive _TalkingUnit || _TalkedToUnit distance _TalkingUnit > MAXDISTANCE) then {call _display_Close};
	};

	//Add Draging of ChatUI
	_ctrlChatUI ctrlAddEventHandler ["MouseButtonDown", {
		params [
			"_Control",
			"_Button",
			"_display",
			"_ctrlChatUI",
			"_ctrlChatUI_TitleBar_TextRight",
			"_ctrlChatUI_TitleBar_TextRight",
			"_ctrlChatUI_TitleBar_TextRight",
			"_ctrlsTopbar",
			"_ctrlChatUI_Pos",
			"_mousePos",
			"_isMouseOnTopBar",
			"_Ctrl",
			"_Pos",
			"_Center"
		];

		if (_Button != 0) exitwith {};

		_display = ctrlParent _Control;
		_ctrlChatUI = _display displayCtrl IDC_ChatUI;
		_ctrlChatUI_TitleBar_Background = _display displayCtrl IDC_TitleBar_Background;
		_ctrlChatUI_TitleBar_TextLeft = _display displayCtrl IDC_TitleBar_TextLeft;
		_ctrlChatUI_TitleBar_TextRight = _display displayCtrl IDC_TitleBar_TextRight;
		_ctrlsTopbar = [_ctrlChatUI_TitleBar_Background, _ctrlChatUI_TitleBar_TextLeft, _ctrlChatUI_TitleBar_TextRight];

		_ctrlChatUI_Pos = Ctrlposition _ctrlChatUI;
		_mousePos = getMousePosition;
		_isMouseOnTopBar = false;

		//Check if the mouse is over topbar
		{
			_Ctrl = _x;
			_Pos = Ctrlposition _Ctrl;

			//Offset Ctrlposition from reletive to ControlGroup to reletive to display
			_Pos = [
				(_Pos select 0) + (_ctrlChatUI_Pos select 0),
				(_Pos select 1) + (_ctrlChatUI_Pos select 1)
			] + [_Pos select 2, _Pos select 3];

			_Pos params ["_X","_Y","_W","_H"];
			_Center = [_X+(_W/2), _Y+(_H/2)];
			If (_mousePos inArea [_Center, _W/2, _H/2, 0, true]) exitWith {_isMouseOnTopBar = true};
		} foreach _ctrlsTopbar;

		if !(_isMouseOnTopBar) exitwith {};

		_Control setvariable ["MouseDown", true];
		_Control spawn {
			params ["_Control", "_Offset"];
			sleep 0.01;

			_Offset = [(ctrlposition _Control select 0)-(getmouseposition select 0), (ctrlposition _Control select 1)-(getmouseposition select 1)];
			while {_Control Getvariable ["MouseDown", false]} do {
				_Control ctrlsetposition [(getmouseposition select 0)+(_Offset select 0), (getmouseposition select 1)+(_Offset select 1)];
				_Control ctrlcommit 0;
			};
		};
	}];

	_ctrlChatUI ctrlAddEventHandler ["MouseButtonUp", {
		params ["_Control", "_Button"];
		if (_Button != 0) exitwith {};
		_Control setvariable ["MouseDown", false]
	}];

	_ctrlChatUI_Response ctrlAddEventHandler ["LBDblClick", _chatSection_Next];
	_ctrlChatUI_Response_Confirm ctrlAddEventHandler ["ButtonClick", _chatSection_Next];
	ctrlsetfocus _ctrlChatUI_Response;

	//Set Apropitate width of name text to apear on the left (Ctrl is centered)
	_ctrlChatUI_TitleBar_TextLeft ctrlSetText ([name _TalkingUnit, _TalkingUnitName] select !(_TalkingUnitName isequalto ""));
	_ctrlChatUI_TitleBar_TextLeft_Position = CtrlPosition _ctrlChatUI_TitleBar_TextLeft;
	_CurrentWidth = ctrlTextWidth _ctrlChatUI_TitleBar_TextLeft;
	_MaxWidth = _ctrlChatUI_TitleBar_TextLeft_Position select 2;

	_ctrlChatUI_TitleBar_TextLeft_Position set [2, (_CurrentWidth Min _MaxWidth)];
	_ctrlChatUI_TitleBar_TextLeft CtrlSetPosition _ctrlChatUI_TitleBar_TextLeft_Position;
	_ctrlChatUI_TitleBar_TextLeft CtrlCommit 0;

	//Position UI were it was last closed
	_ctrlChatUI_Position = ctrlPosition _ctrlChatUI;
	_SavedPosition = MissionNameSpace getvariable ["Phobos_fnc_Chat_SavedPosition", [_ctrlChatUI_Position select 0, _ctrlChatUI_Position select 1]];
	_ctrlChatUI ctrlSetPosition _SavedPosition;
	_ctrlChatUI ctrlCommit 0;

	{if ((_x select 0) isequalto 0) exitwith {_x call _chatSection_Show}} foreach _ChatParams;
}] remoteExecCall ["call", _TalkedToUnit];
