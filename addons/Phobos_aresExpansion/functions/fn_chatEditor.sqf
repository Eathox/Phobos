//WIP make its so you can move the chat sections aria for more chat sections
//WIP Make it so you cant export while there is a probleme like Double ID Next ID not leading anywere ID 0 not used ect.
//WIP Make a ui that tells user wich ids are refranced but dont exsist yet
//WIP Add import
//WIP change everything to grid so its a constant size
//WIP change it so color paterns are the same as 3Den
//Add Option to set name of talking unit
//Add option to export in add action format
//make sayed blur out if no soundconfig was given
//show that sound congif was not found
//add option for direct char distance
//Make Top bar have full alhpa
/*
	Author: Eathox

	Description:
	A chat editor that allows for easyer configuration of my Chat function

	Parameters:
	0: String - Mode: Open

	Returns:
	none

	Example:
	[] call BIS_fnc_recompile; //In order to open it in Eden
	"Open" Call ETO_fnc_ChatEditor;
*/

disableserialization;

//#include "\chatsystem\UI\DefineResInclDesign.inc" WIP
//#include "\chatsystem\UI\DefineDikCodes.inc" WIP

#define ColorFormat [0.2,0.5,1,1]
#define ColorSilent [0.95,0.95,0.95,0.5]
#define ColorDefault [0.95,0.95,0.95,1]

params [
	["_Mode", "open", [""]],
	["_Arguments", [], [[]]],
	"_ParseNumber",
	"_MouseOverScript"
];

_ParseNumber = {
	params [
		["_String", "", [""]],
		"_Valid",
		"_AllowedChars",
		"_CountDots"
	];

	_Valid = True;
	_AllowedChars = [".","-","+","0","1","2","3","4","5","6","7","8","9"];
	_CountDots = 0;

	If (count _String == 1 && !(_String in ["0","1","2","3","4","5","6","7","8","9"])) exitwith {-1};
	{
		If (_x isequalto ".") then {_CountDots = _CountDots+1};
		If (_CountDots > 1) exitwith {_Valid = False};
		If !(_x in _AllowedChars) exitwith {_Valid = False};
		If (_ForeachIndex > 0 && _x in ["-","+"]) exitwith {_Valid = False};
	} foreach (_String splitstring "");

	If (_Valid) then {call compile _String} else {-1};
};

_MouseOverScript = {
	Params [
		["_CheckHidden", True, [True]],
		"_Display",
		"_ChatSectionCtrlIdcs",
		"_CtrlIdcs",
		"_MousePos",
		"_IfStateMent",
		"_Idc",
		"_Ctrl",
		"_Pos",
		"_Center"
	];

	_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
	_ChatSectionCtrlIdcs = _Display getvariable ["_ChatSectionCtrlIdcs", []];
	_CtrlIdcs = [IDC_ETO_fnc_ChatEditor_PopupMenu, IDC_ETO_fnc_ChatEditor_ExportMenu, IDC_ETO_fnc_ChatEditor_AttributesMenu, IDC_ETO_fnc_ChatEditor_TopBar, IDC_ETO_fnc_ChatEditor_RightClickMenu] +_ChatSectionCtrlIdcs+ [IDC_ETO_fnc_ChatEditor_Background];
	_MousePos = getMousePosition;
	_IfStateMent = "_MousePos inArea [_Center, _W/2, _H/2, 0, true]" ;
	if !(_CheckHidden) then {_IfStateMent = _IfStateMent + " && Ctrlshown _Ctrl"};

	{
		_Idc = _x;
		_Ctrl = _Display DisplayCtrl _Idc;
		_Pos = Ctrlposition _Ctrl;
		_Pos = if (_Idc in _ChatSectionCtrlIdcs) then {
			[
				(_Pos select 0) + safezoneXAbs+0 * (((safezoneW / safezoneH) min 1.2) / 40),
				(_Pos select 1) + safezoneY+0 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
			] + [_Pos select 2, _Pos select 3]
		} else {_Pos};

		_Pos params ["_X","_Y","_W","_H"];
		_Center = [_X+(_W/2), _Y+(_H/2)];
		If (call compile _IfStateMent) exitWith {_Idc};
	} foreach _CtrlIdcs;
};

switch (tolower _Mode) do {
	case "open": {
		params [
			"_Display",
			"_CtrlButtonExit",
			"_CtrlButtonImport",
			"_CtrlButtonExport",
			"_CtrlButtonCreate",
			"_CtrlButtonDelete",
			"_CtrlButtonEdit",
			"_CtrlButtonCopy",
			"_CtrlButtonPaste",
			"_CtrlPopup_ButtonOk",
			"_CtrlAttributesMenu_Id_IdEdit",
			"_CtrlAttributesResponse_ResponsesList",
			"_CtrlAttributesResponse_ResponsesAdd",
			"_CtrlAttributesResponse_ResponsesDelete",
			"_CtrlAttributesResponse_ConditionArgumentsEdit",
			"_CtrlExport_TalkingUnitEdit",
			"_CtrlExport_OnCloseCodeArgumentsEdit"
		];

		_Display = [findDisplay 46, findDisplay 313] select Is3den;
		_Display = _Display createDisplay "ConversationEditorDisplay";

		UINamespace setvariable ["ETO_fnc_ChatEditor_Display", _Display];
		showHUD [false,false,false,false,false,false,false,false,false];
		ShowChat True;
		if !(Is3Den) then {player switchMove "HubSpectator_stand"} else {["ShowInterface", False] spawn bis_fnc_3DENInterface};

		_Display displayAddEventHandler ["KeyDown", {["KeyDown", _This] Call ETO_fnc_ChatEditor}];
		_Display displayAddEventHandler ["MouseButtonDown", {["MouseButtonDown", _This] Call ETO_fnc_ChatEditor}];

		_CtrlButtonExit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_TopBar_ButtonExit;
		_CtrlButtonExit ctrladdeventhandler ["ButtonClick", {"Close" Call ETO_fnc_ChatEditor}];

		_CtrlButtonImport = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_TopBar_ButtonImport;
		_CtrlButtonImport ctrladdeventhandler ["ButtonClick", {"OpenImport" Call ETO_fnc_ChatEditor}];

		_CtrlButtonExport = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_TopBar_ButtonExport;
		_CtrlButtonExport ctrladdeventhandler ["ButtonClick", {"OpenExport" Call ETO_fnc_ChatEditor}];

		{
			(_Display DisplayCtrl _x) ctrladdeventhandler ["ButtonClick", format ["['CloseExport', [%1]] Call ETO_fnc_ChatEditor", ([True, False] select _ForeachIndex)]];
		} Foreach [IDC_ETO_fnc_ChatEditor_ExportMenu_ButtonOk, IDC_ETO_fnc_ChatEditor_ExportMenu_ButtonCancel];

		_CtrlButtonCreate = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu_ButtonCreate;
		_CtrlButtonCreate ctrladdeventhandler ["ButtonClick", {
			Private _CtrlPos = CtrlPosition CtrlParentControlsGroup (_This Select 0);
			["ButtonCreate", [_CtrlPos]] Call ETO_fnc_ChatEditor
		}];

		_CtrlButtonDelete = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu_ButtonDelete;
		_CtrlButtonDelete ctrladdeventhandler ["ButtonClick", {"ButtonDelete" Call ETO_fnc_ChatEditor}];

		_CtrlButtonEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu_ButtonEdit;
		_CtrlButtonEdit ctrladdeventhandler ["ButtonClick", {"OpenAttributes" call ETO_fnc_ChatEditor}];

		_CtrlButtonCopy = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu_ButtonCopy;
		_CtrlButtonCopy ctrladdeventhandler ["ButtonClick", {"ButtonCopy" Call ETO_fnc_ChatEditor}];

		_CtrlButtonPaste = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu_ButtonPaste;
		_CtrlButtonPaste ctrladdeventhandler ["ButtonClick", {"ButtonPaste" Call ETO_fnc_ChatEditor}];

		{
			(_Display DisplayCtrl _x) ctrladdeventhandler ["ButtonClick", format ["['ClosePopup', [%1]] Call ETO_fnc_ChatEditor", ([True, False] select _ForeachIndex)]];
		} Foreach [IDC_ETO_fnc_ChatEditor_PopupMenu_ButtonOk, IDC_ETO_fnc_ChatEditor_PopupMenu_ButtonCancel];

		_CtrlPopup_ButtonOk = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_PopupMenu_ButtonOk;
		_CtrlPopup_ButtonOk ctrladdeventhandler ["KillFocus", {
			Private _Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
			If (CtrlShown (_Display displayCtrl 196000)) Then {CtrlSetFocus (_Display displayCtrl 196009)}
		}];

		{
			(_Display DisplayCtrl _x) ctrladdeventhandler ["ButtonClick", format ["['CloseAttributes', [%1]] Call ETO_fnc_ChatEditor", ([True, False] select _ForeachIndex)]];
		} Foreach [IDC_ETO_fnc_ChatEditor_AttributesMenu_ButtonOk, IDC_ETO_fnc_ChatEditor_AttributesMenu_ButtonCancel];

		_CtrlAttributesMenu_Id_IdEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Id_IdEdit;
		_CtrlAttributesMenu_Id_IdEdit ctrladdeventhandler ["SetFocus", {UINamespace Getvariable "ETO_fnc_ChatEditor_Display" setvariable ["TabDisabled", "up"]}];
		_CtrlAttributesMenu_Id_IdEdit ctrladdeventhandler ["KillFocus", {UINamespace Getvariable "ETO_fnc_ChatEditor_Display" setvariable ["TabDisabled", ""]}];

		_CtrlAttributesResponse_ResponsesList = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ResponsesList;
		_CtrlAttributesResponse_ResponsesList ctrladdeventhandler ["LBSelChanged", {["LBSelChanged", _This] Call ETO_fnc_ChatEditor}];

		_CtrlAttributesResponse_ResponsesAdd = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ResponsesAdd;
		_CtrlAttributesResponse_ResponsesAdd ctrladdeventhandler ["ButtonClick", {"LBAdd" Call ETO_fnc_ChatEditor}];

		_CtrlAttributesResponse_ResponsesDelete = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ResponsesDelete;
		_CtrlAttributesResponse_ResponsesDelete ctrladdeventhandler ["ButtonClick", {"LBDelete" Call ETO_fnc_ChatEditor}];
		_CtrlAttributesResponse_ResponsesDelete CtrlEnable False;

		_CtrlAttributesResponse_ConditionArgumentsEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ConditionArgumentsEdit;
		_CtrlAttributesResponse_ConditionArgumentsEdit ctrladdeventhandler ["SetFocus", {UINamespace Getvariable "ETO_fnc_ChatEditor_Display" setvariable ["TabDisabled", "down"]}];
		_CtrlAttributesResponse_ConditionArgumentsEdit ctrladdeventhandler ["KillFocus", {UINamespace Getvariable "ETO_fnc_ChatEditor_Display" setvariable ["TabDisabled", ""]}];

		_CtrlExport_TalkingUnitEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu_TalkingUnitEdit;
		_CtrlExport_TalkingUnitEdit ctrladdeventhandler ["SetFocus", {UINamespace Getvariable "ETO_fnc_ChatEditor_Display" setvariable ["TabDisabled", "up"]}];
		_CtrlExport_TalkingUnitEdit ctrladdeventhandler ["KillFocus", {UINamespace Getvariable "ETO_fnc_ChatEditor_Display" setvariable ["TabDisabled", ""]}];

		_CtrlExport_OnCloseCodeArgumentsEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu_OnCloseCodeArgumentsEdit;
		_CtrlExport_OnCloseCodeArgumentsEdit ctrladdeventhandler ["SetFocus", {UINamespace Getvariable "ETO_fnc_ChatEditor_Display" setvariable ["TabDisabled", "down"]}];
		_CtrlExport_OnCloseCodeArgumentsEdit ctrladdeventhandler ["KillFocus", {UINamespace Getvariable "ETO_fnc_ChatEditor_Display" setvariable ["TabDisabled", ""]}];

		{
			Private _Ctrl = _Display DisplayCtrl _x;
			_Ctrl ctrladdeventhandler ["KeyDown", {["ColorEdit", [_This select 0]] Call ETO_fnc_ChatEditor}];
			_Ctrl ctrladdeventhandler ["KeyUp", {["ColorEdit", [_This select 0]] Call ETO_fnc_ChatEditor}];
		} foreach [IDC_ETO_fnc_ChatEditor_AttributesMenu_Text_TextEdit, IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_TextEdit, IDC_ETO_fnc_ChatEditor_AttributesMenu_Text_SoundConfigEdit, IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_SoundConfigEdit];

		{(_Display DisplayCtrl _x) ctrladdeventhandler ["KillFocus", {"StoreResponse" Call ETO_fnc_ChatEditor}]} Foreach [
			IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_NextIdEdit,
			IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_TextEdit,
			IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_SoundConfigEdit,
			IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_Say3DCheckbox,
			IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_CodeEdit,
			IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_CodeArgumentsEdit,
			IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ConditionEdit,
			IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ConditionArgumentsEdit
		];

		{(_Display DisplayCtrl _x) ctrlSetPixelPrecision 2} foreach [196000,196001,196002,196003,196004,196005,196006,196007,196008,196009,196010, 191000,191001,191002,191003,191004,191005,191006];

		nil
	};

	case "close": {
		["OpenPopup", ["Do you want to close the Chat Editor?",{
			UINamespace Getvariable "ETO_fnc_ChatEditor_Display" closeDisplay 1;
			UINamespace Setvariable ["ETO_fnc_ChatEditor_Display", nil];
			showHUD [true,true,true,true,true,true,true,true,true];
			if !(Is3Den) then {player SwitchMove "AidlPercMstpSlowWrflDnon_AI"} else {["ShowInterface", True] spawn bis_fnc_3DENInterface};
		}]] Call ETO_fnc_ChatEditor;
	};

	case "keydown": {
		_Arguments params [
			["_Display", DisplayNull, [DisplayNull]],
			["_Key", -1, [-1]],
			["_Shift", False, [False]],
			["_Ctrl", False, [False]],
			["_Alt", False, [False]],
			"_CtrlAttributesMenu",
			"_CtrlExportMenu",
			"_CtrlPopupMenu",
			"_TabDisabled",
			"_InAtributes",
			"_InExport",
			"_InPopup",
			"_Return"
		];

		_CtrlAttributesMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu;
		_CtrlExportMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu;
		_CtrlPopupMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_PopupMenu;
		_TabDisabled = _Display Getvariable ["TabDisabled", ""];
		_InAtributes = CtrlShown _CtrlAttributesMenu;
		_InExport = Ctrlshown _CtrlExportMenu;
		_InPopup = Ctrlshown _CtrlPopupMenu;
		_Return = True;

		switch (True) do {
			case (_key == DIK_ESCAPE): {
				switch (True) do {
					case _InPopup: {["ClosePopup", [False]] Call ETO_fnc_ChatEditor};
					case _InAtributes: {["CloseAttributes", [False]] Call ETO_fnc_ChatEditor};
					case _InExport: {["CloseExport", [False]] Call ETO_fnc_ChatEditor};
					default {"Close" Call ETO_fnc_ChatEditor};
				};
			};

			case (_key == DIK_C && _Ctrl): {
				if (!_InAtributes && !_InExport && !_InPopup) then {
					_Display setvariable ["MouseOver", false call _MouseOverScript];
					"ButtonCopy" Call ETO_fnc_ChatEditor;
				};
				_Return = False;
			};

			case (_key == DIK_V && _Ctrl): {
				if (!_InAtributes && !_InExport && !_InPopup) then {
					"ButtonPaste" Call ETO_fnc_ChatEditor;
				};
				_Return = False;
			};

			case (_key == DIK_X && _Ctrl): {
				if (!_InAtributes && !_InExport && !_InPopup) then {
					_Display setvariable ["MouseOver", false call _MouseOverScript];
					"ButtonCopy" Call ETO_fnc_ChatEditor;
					"ButtonDelete" Call ETO_fnc_ChatEditor;
				};
				_Return = False;
			};

			case (_key == DIK_D && _Ctrl): {
				if (!_InAtributes && !_InExport && !_InPopup) then {
					_Display setvariable ["MouseOver", false call _MouseOverScript];
					"ButtonDelete" Call ETO_fnc_ChatEditor;
				};
				_Return = False;
			};

			case (_key == DIK_E && _Ctrl): {
				if (!_InAtributes && !_InExport && !_InPopup) then {
					_Display setvariable ["MouseOver", false call _MouseOverScript];
					"OpenAttributes" Call ETO_fnc_ChatEditor;
				};
				_Return = False;
			};

			case (_key == DIK_A && _Ctrl): {
				_Return = False;
			};

			case (_key in [DIK_RETURN, DIK_NUMPADENTER]): {
				if (_Shift) ExitWith {_Return = False;};
				switch (True) do {
					case _InPopup: {["ClosePopup", [True]] Call ETO_fnc_ChatEditor};
					case _InAtributes: {["CloseAttributes", [True]] Call ETO_fnc_ChatEditor};
					case _InExport: {["CloseExport", [True]] Call ETO_fnc_ChatEditor};
				};
			};

			case (_key in [DIK_BACK,DIK_UP,DIK_LEFT,DIK_RIGHT,DIK_DOWN,DIK_DELETE,DIK_HOME,DIK_END]): {
				_Return = False;
			};

			case (_Key == DIK_TAB): {
				_Return = False;
				if !(_TabDisabled isequalto "") then {
					params ["_CtrlNextCtrl"];
					switch (True) do {
						case _InPopup: {_Return = True};

						case _InAtributes: {
							if (_TabDisabled isequalto "up") then {
								_CtrlNextCtrl = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ConditionArgumentsEdit;
								if (_Shift) then {CtrlsetFocus _CtrlNextCtrl; _Return = True};
							} else {
								_CtrlNextCtrl = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Id_IdEdit;
								if !(_Shift) then {CtrlsetFocus _CtrlNextCtrl; _Return = True};
							};
							_Return = True
						};

						case _InExport: {
							if (_TabDisabled isequalto "up") then {
								_CtrlNextCtrl = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu_OnCloseCodeArgumentsEdit;
								if (_Shift) then {CtrlsetFocus _CtrlNextCtrl; _Return = True};
							} else {
								_CtrlNextCtrl = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu_TalkingUnitEdit;
								if !(_Shift) then {CtrlsetFocus _CtrlNextCtrl; _Return = True};
							};
						};
					};
				};
			};
		};

		_Return
	};

	case "mousebuttondown": {
		_Arguments params [
			["_Display", DisplayNull, [DisplayNull]],
			["_Button", -1, [-1]],
			["_xPos", -1, [-1]],
			["_yPos", -1, [-1]],
			["_Shift", False, [False]],
			["_Ctrl", False, [False]],
			["_Alt", False, [False]],
			"_CtrlRightClickMenu",
			"_MouseOver",
			"_OverChatSection"
		];

		_CtrlRightClickMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu;
		_MouseOver = false call _MouseOverScript;
		_OverChatSection = _MouseOver in (_Display Getvariable ["_ChatSectionCtrlIdcs", []]);

		if (_MouseOver in [IDC_ETO_fnc_ChatEditor_TopBar, IDC_ETO_fnc_ChatEditor_RightClickMenu, IDC_ETO_fnc_ChatEditor_AttributesMenu, IDC_ETO_fnc_ChatEditor_ExportMenu, IDC_ETO_fnc_ChatEditor_PopupMenu]) exitwith {};

		switch (True) do {
			case (_Button isequalto 1): {
				_Display setvariable ["MouseOver", _MouseOver];
				Private _CtrlChatSection = _Display displayCtrl _MouseOver;
				Private _CtrlChatSectionId = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_ChatSectionID;
				if (_CtrlChatSectionId getvariable ["MouseDown", false]) exitwith {};

				_CtrlRightClickMenu ctrlsetposition [_xPos, _yPos];
				_CtrlRightClickMenu ctrlcommit 0;
				_CtrlRightClickMenu Ctrlshow True;
				ctrlsetfocus _CtrlRightClickMenu;

				Private _CtrlButtonCreate = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu_ButtonCreate;
				_CtrlButtonCreate CtrlEnable !_OverChatSection;

				Private _CtrlButtonDelete = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu_ButtonDelete;
				_CtrlButtonDelete CtrlEnable _OverChatSection;

				Private _CtrlButtonEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu_ButtonEdit;
				_CtrlButtonEdit CtrlEnable _OverChatSection;

				Private _CtrlButtonCopy = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu_ButtonCopy;
				_CtrlButtonCopy CtrlEnable _OverChatSection;

				Private _CtrlButtonPaste = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu_ButtonPaste;
				_CtrlButtonPaste CtrlEnable (!_OverChatSection && !(_Display Getvariable ["CopyData", []] isequalto []));
			};

			case (_Button isequalto 0): {
				_CtrlRightClickMenu Ctrlshow False;
				Ctrlsetfocus (_Display DisplayCtrl IDC_ETO_fnc_ChatEditor_TopBar);
			};
		};
	};

	case "buttoncreate": {
		_Arguments params [
			["_CtrlPos", [], [[]]],
			["_Id", "", [""]],
			["_Text", "Place Holder", ["", []]],
			["_ResponseNextId", "-1", [""]],
			["_ResponseText", "Place Holder", [""]],
			"_Display",
			"_CtrlRightClickMenu",
			"_UsedIds",
			"_CtrlChatSectionIdc",
			"_ChatSectionCtrlIdcs",
			"_CtrlChatSection",
			"_CtrlChatSectionId",
			"_CtrlChatSectionText",
			"_CtrlChatSectionResponse"
		];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlRightClickMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu;
		_CtrlRightClickMenu Ctrlshow False;
		Ctrlsetfocus (_Display DisplayCtrl IDC_ETO_fnc_ChatEditor_TopBar);

		_UsedIds = [];
		{_UsedIds Pushback (CtrlText ((_Display DisplayCtrl _x) controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_ChatSectionID) call _ParseNumber)} foreach (_Display Getvariable ["_ChatSectionCtrlIdcs", []]);

		_CtrlChatSectionIdc = (_Display Getvariable ["_CtrlChatSectionIdc", 200000])+1;
		_Display Setvariable ["_CtrlChatSectionIdc", _CtrlChatSectionIdc];

		_ChatSectionCtrlIdcs = _Display Getvariable ["_ChatSectionCtrlIdcs", []];
		_ChatSectionCtrlIdcs pushback _CtrlChatSectionIdc;
		_Display Setvariable ["_ChatSectionCtrlIdcs", _ChatSectionCtrlIdcs];

		_CtrlChatSection = _Display ctrlCreate ["ChatSection", _CtrlChatSectionIdc, (_Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ChatSections)];
		_CtrlChatSection ctrlsetposition [
			(_CtrlPos select 0) - safezoneXAbs+0 * (((safezoneW / safezoneH) min 1.2) / 40),
			(_CtrlPos select 1) - safezoneY+0 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
		];
		_CtrlChatSection ctrlcommit 0;

		_CtrlChatSectionId = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_ChatSectionID;
		_CtrlChatSectionId CtrlSetText ([_Id, str (for "_i" from 0 to 1000 do {If !(_i in _UsedIds) exitwith {_i}})] select (_Id isequalto ""));

		_Text = [_Text, [_Text]] select !(_Text isequaltype []);
		_CtrlChatSectionText = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_Text_Text;
		_CtrlChatSectionText ctrlsetstructuredtext parsetext (_Text joinstring "<br/>");
		_CtrlChatSectionText CtrlSetTextColor ([ColorDefault, ColorFormat] select ((["IsSpecialText", [(_Text joinstring "<br/>")]] call ETO_fnc_ChatEditor) isequalto "format"));
		_CtrlChatSection Setvariable ["Text", _Text];
		["ResizeTextGroup", [_CtrlChatSection]] Call ETO_fnc_ChatEditor;

		_CtrlChatSectionResponse = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_Response;
		_CtrlChatSectionResponse lnbAddRow [_ResponseNextId, format ["1. %1", _ResponseText]];
		_CtrlChatSectionResponse setvariable ["Response 1_Data", ["", True, "", "", "True", ""]];

		{(_CtrlChatSection controlsGroupCtrl _x) ctrlSetPixelPrecision 2} foreach [10,11,12,13,14,15,16,17];

		_CtrlChatSection
	};

	case "buttondelete": {
		params ["_Display","_MouseOver","_CtrlRightClickMenu","_ChatSectionCtrlIdcs"];
		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_MouseOver = _Display Getvariable "MouseOver";

		_CtrlRightClickMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu;
		_CtrlRightClickMenu Ctrlshow False;
		Ctrlsetfocus (_Display DisplayCtrl IDC_ETO_fnc_ChatEditor_TopBar);

		ctrlDelete (_Display DisplayCtrl _MouseOver);
		_ChatSectionCtrlIdcs = _Display Getvariable ["_ChatSectionCtrlIdcs", []];
		_ChatSectionCtrlIdcs Deleteat (_ChatSectionCtrlIdcs Find _MouseOver);
		_Display Setvariable ["_ChatSectionCtrlIdcs", _ChatSectionCtrlIdcs];
	};

	case "buttoncopy": {
		params [
			"_Display",
			"_MouseOver",
			"_CtrlRightClickMenu",
			"_CtrlChatSection",
			"_CtrlChatSectionID",
			"_ID",
			"_Text",
			"_SoundConfig",
			"_Say3D",
			"_Response_Data",
			"_CtrlChatSectionResponse",
			"_NextId",
			"_ResponseText",
			"_Data"
		];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_MouseOver = _Display Getvariable "MouseOver";

		_CtrlRightClickMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu;
		_CtrlRightClickMenu Ctrlshow False;
		Ctrlsetfocus (_Display DisplayCtrl IDC_ETO_fnc_ChatEditor_TopBar);

		_CtrlChatSection = _Display DisplayCtrl _MouseOver;
		_CtrlChatSectionID = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_ChatSectionID;
		_ID = CtrlText _CtrlChatSectionID;
		_Text = _CtrlChatSection getvariable "Text";
		_SoundConfig = _CtrlChatSection getvariable ["SoundConfig", ""];
		_Say3D = _CtrlChatSection getvariable ["Say3D", True];

		_Response_Data = [];
		_CtrlChatSectionResponse = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_Response;
		for "_i" from 0 to (lnbsize _CtrlChatSectionResponse select 0)-1 do {
			_NextId = _CtrlChatSectionResponse LnbText [_I, 0];
			_ResponseText = _CtrlChatSectionResponse LnbText [_I, 1];
			_ResponseText = _ResponseText select [(_ResponseText find " ")+1, (Count _ResponseText)-3];
			_Data = _CtrlChatSectionResponse getvariable [format ["Response %1_Data", _I+1], ["",True,"","","",""]];

			_Response_Data pushback ([_NextId, _ResponseText] + _Data);
		};

		_Display Setvariable ["CopyData", [_ID, _Text, _SoundConfig, _Say3D, _Response_Data]];
	};

	case "buttonpaste": {
		params ["_Display","_CtrlRightClickMenu","_ShortcutUsed","_CtrlPos","_CtrlChatSection","_CtrlChatSectionResponse","_State","_ResponseNumber"];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlRightClickMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu;
		_ShortcutUsed = CtrlShown _CtrlRightClickMenu;
		_CtrlRightClickMenu Ctrlshow False;
		Ctrlsetfocus (_Display DisplayCtrl IDC_ETO_fnc_ChatEditor_TopBar);

		(_Display Getvariable "CopyData") params ["_ID","_Text","_SoundConfig","_Say3D","_Response_Data"];

		_CtrlPos = [GetMousePosition, CtrlPosition _CtrlRightClickMenu] select (_ShortcutUsed);
		if !(_ShortcutUsed) then {_CtrlPos = [(_CtrlPos select 0) - 0.6 * (((safezoneW / safezoneH) min 1.2) / 40), (_CtrlPos select 1) - 0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)]};
		_CtrlChatSection = ["ButtonCreate", [
			_CtrlPos,
			_ID,
			_Text,
			(_Response_Data select 0) select 0,
			(_Response_Data select 0) select 1
		]] Call ETO_fnc_ChatEditor;

		_CtrlChatSection setvariable ["SoundConfig", _SoundConfig];
		_CtrlChatSection setvariable ["Say3D", _Say3D];

		_CtrlChatSectionResponse = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_Response;
		{
			_x params ["_NextId","_ResponseText","_SoundConfig","_Say3D","_Code","_CodeArguments","_Condition","_ConditionArguments"];
			_State = ["IsSpecialText", [_ResponseText]] call ETO_fnc_ChatEditor;
			_ResponseNumber = _ForeachIndex+1;

			if (_ForeachIndex > 0) then {_CtrlChatSectionResponse LnbAddRow [_NextId, format ["%1. %2", _ResponseNumber, _ResponseText]]};
			if (_State isequalto "format") then {_CtrlChatSectionResponse lnbSetColor [[_ForeachIndex, 1], ColorFormat]};
			if (_State isequalto "silent") then {_CtrlChatSectionResponse lnbSetColor [[_ForeachIndex, 1], ColorSilent]};
			_CtrlChatSectionResponse setvariable [format ["Response %1_Data", _ResponseNumber], [_SoundConfig, _Say3D, _Code, _CodeArguments, _Condition, _ConditionArguments]];
		} Foreach _Response_Data;
	};

	case "openpopup": {
		_Arguments Params [
			["_Text", "", [""]],
			["_OnOkCode", {}, [{}]],
			["_CenterOk", False, [False]],
			"_Display",
			"_CtrlPopup",
			"_CtrlPopup_Menu",
			"_CtrlPopupText",
			"_CtrlPopupButtonCancel"
		];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlPopup = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_PopupMenu;

		_CtrlPopup_Menu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_PopupMenu_Menu;
		_CtrlPopup_Menu CtrlSetposition [(safezoneWAbs/2) - (17/2) * (((safezoneW / safezoneH) min 1.2) / 40), (safezoneH/2) - (5/2) * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)];
		_CtrlPopup_Menu CtrlCommit 0;

		_CtrlPopup setvariable ["_OnOkCode", _OnOkCode];
		_CtrlPopup Ctrlshow True;

		_CtrlPopupText = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_PopupMenu_Text;
		_CtrlPopupText CtrlSetText _Text;

		_CtrlPopupButtonCancel = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_PopupMenu_ButtonCancel;
		_CtrlPopupButtonCancel Ctrlshow !_CenterOk;

		_Display Setvariable ["TabDisabled", "True"];
		CtrlSetFocus (_Display DisplayCtrl IDC_ETO_fnc_ChatEditor_PopupMenu_ButtonOk);
	};

	case "closepopup": {
		_Arguments Params [
			["_Ok", False, [False]],
			"_Display",
			"_CtrlPopup",
			"_OnOkCode"
		];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlPopup = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_PopupMenu;
		_OnOkCode = _CtrlPopup Getvariable ["_OnOkCode", {}];

		_Display Setvariable ["TabDisabled", ""];
		_CtrlPopup Ctrlshow False;
		if (_Ok) then {Call _OnOkCode};
	};

	case "openimport": {

	};

	case "closeimport": {

	};

	case "openexport": {
		params ["_Display","_CtrlRightClickMenu","_CtrlDisableEsc","_CtrlExportMenu","_CtrlTalkingUnit"];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";

		_CtrlRightClickMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu;
		_CtrlRightClickMenu Ctrlshow False;

		_CtrlDisableEsc = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu_DisableEscCheckBox;
		_CtrlDisableEsc CbSetChecked True;

		_CtrlExportMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu;
		_CtrlExportMenu Ctrlshow true;

		_CtrlTalkingUnit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu_TalkingUnitEdit;
		CtrlSetfocus _CtrlTalkingUnit
	};

	case "closeexport": {
		_Arguments params [
			["_Export", False, [False]],
			"_Display",
			"_CtrlExportMenu",
			"_CtrlTalkingUnit",
			"_CtrlTalkedToUnit",
			"_CtrlOnCloseCodeEdit",
			"_CtrlOnCloseCodeArgumentsEdit",
			"_UsedIds",
			"_TalkingValid",
			"_TalkedToValid",
			"_ErrorParams",
			"_Error",
			"_CtrlError",
			"_CtrlDisableEsc",
			"_ChatSectionData",
			"_ResponseData",
			"_Export",
			"_StrFormat",
			"_CtrlChatSection",
			"_CtrlChatSectionID",
			"_CtrlChatSectionResponse",
			"_Text",
			"_SoundConfig"
		];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlExportMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu;
		_CtrlTalkingUnit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu_TalkingUnitEdit;
		_CtrlTalkedToUnit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu_TalkedtoUnitEdit;
		_CtrlOnCloseCodeEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu_OnCloseCodeEdit;
		_CtrlOnCloseCodeArgumentsEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu_OnCloseCodeArgumentsEdit;

		_UsedIds = [];
		{_UsedIds Pushback (CtrlText ((_Display DisplayCtrl _x) controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_ChatSectionID) call _ParseNumber)} foreach (_Display Getvariable ["_ChatSectionCtrlIdcs", []]);

		_TalkingValid = ["CheckEmpty", [_CtrlTalkingUnit]] Call ETO_fnc_ChatEditor;
		_TalkedToValid = ["CheckEmpty", [_CtrlTalkedToUnit]] Call ETO_fnc_ChatEditor;

		if (_Export && ((_TalkingValid select 0) || (_TalkedToValid select 0) || !(0 in _UsedIds))) exitwith {
			_ErrorParams = if !(0 in _UsedIds) then {["0", "0"]} else {[_TalkedToValid, _TalkingValid] select (_TalkingValid select 0)};
			_Error = _ErrorParams select 0;
			_CtrlError = _ErrorParams select 1;

			switch (_Error) do
			{
				case true: {_Error = "Variable name not defined"};
				case "0": {_Error = "Chatsection 0 does not exsists"};
			};

			switch (true) do
			{
				case (_CtrlError isequalto _CtrlTalkingUnit): {_CtrlError = "Talking unit"};
				case (_CtrlError isequalto _CtrlTalkedToUnit): {_CtrlError = "Talked to unit"};
				case (_CtrlError isequalto "0"): {_CtrlError = "Chatsections"};
			};

			["OpenPopup", [format ["%1: %2.", _CtrlError, _Error], {}, True]] Call ETO_fnc_ChatEditor;
		};

		_CtrlExportMenu Ctrlshow false;
		Ctrlsetfocus (_Display DisplayCtrl IDC_ETO_fnc_ChatEditor_TopBar);

		if (!_Export) exitwith {};

		_CtrlDisableEsc = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_ExportMenu_DisableEscCheckBox;
		_ChatSectionData = [];
		_ResponseData = [];
		_Export = "";

		_StrFormat = {
			Private _Text = _This;
			Private _IsFormat = (["IsSpecialText", [_Text]] call ETO_fnc_ChatEditor) isequalto "format";

			_Text = [Str _Text, _Text] select (_IsFormat);
			_Text = [_Text, _Text select [0,(count _Text)-1]] select (_Text select [(count _Text)-1, 1] isequalto ";");
			_Text = [_Text, "Format "+_Text] select (_IsFormat && !(tolower (_Text select [0,6]) isequalto "format"));
			_Text
		};

		{
			_ResponseData = [];
			_Export = "";

			_CtrlChatSection = _Display DisplayCtrl _x;
			_CtrlChatSectionID = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_ChatSectionID;
			_CtrlChatSectionResponse = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_Response;

			_Text = ((_CtrlChatSection getvariable ["Text", ""]) joinstring "<br/>") call _StrFormat;
			_SoundConfig = (_CtrlChatSection getvariable ["SoundConfig", ""]) call _StrFormat;

			For "_i" from 0 to (lnbsize _CtrlChatSectionResponse select 0)-1 do {
				(_CtrlChatSectionResponse GetVariable format ["Response %1_Data", _I+1]) Params [
					["_ResponseSoundConfig", "", [""]],
					["_Say3D", True, [True]],
					["_Code", "", [""]],
					["_CodeArguments", "", [""]],
					["_Condition", "True", [""]],
					["_ConditionArguments", "", [""]],
					"_NextId",
					"_ResponseText"
				];

				_NextId = _CtrlChatSectionResponse LnbText [_I, 0];
				_ResponseText = _CtrlChatSectionResponse LnbText [_I, 1];
				_ResponseText = _ResponseText select [(_ResponseText find " ")+1, (Count _ResponseText)-3];
				_ResponseText = _ResponseText call _StrFormat;
				_ResponseSoundConfig = _ResponseSoundConfig call _StrFormat;

				_ResponseData Pushback "["+([_NextId, str _NextId] select (_NextId select [0,1] in ["+","-"]))+", "+_ResponseText+", "+"40"+", ["+_ResponseSoundConfig+", "+str _Say3D+"], [{"+_Code+"}, ["+_CodeArguments+"]], [{"+_Condition+"}, ["+_ConditionArguments+"]]]";
			};

			_Export =
			ToString [10, 9]+"["+CtrlText _CtrlChatSectionID+","+
				ToString [10, 9,9]+"["+_Text+", "+"40"+", ["+_SoundConfig+", "+str(_CtrlChatSection getvariable ["Say3D", True])+"]], ["+
					ToString [10, 9,9,9]+(_ResponseData joinstring (","+ToString [10, 9,9,9]))+
					ToString [10, 9,9]+"]"+
				ToString [10, 9]+"]";
			_ChatSectionData Pushback _Export
		} foreach (_Display Getvariable ["_ChatSectionCtrlIdcs", []]);

		CopyToClipboard ("[["+CtrlText _CtrlTalkingUnit+", "+CtrlText _CtrlTalkedToUnit+"], ["+(_ChatSectionData joinstring (","+ToString [10, 9]))+ToString [10]+"], ["+ToString [10, 9]+"{"+CtrlText _CtrlOnCloseCodeEdit+"}, ["+Ctrltext _CtrlOnCloseCodeArgumentsEdit+"]"+ToString [10]+"], "+Str CbChecked _CtrlDisableEsc+"] call ETO_fnc_Chat;");
	};

	case "openattributes": {
		_Arguments params [
			"_Display",
			"_MouseOver",
			"_CtrlRightClickMenu",
			"_CtrlChatSection",
			"_CtrlChatSectionID",
			"_CtrlChatSectionText",
			"_CtrlChatSectionResponse",
			"_CtrlAttributesMenu",
			"_CtrlAttributesId_IdEdit",
			"_Text",
			"_CtrlAttributesText_TextEdit",
			"_CtrlAttributesText_SoundConfigEdit",
			"_CtrlAttributesText_Say3DCheckBox",
			"_CtrlAttributesResponse_ResponsesList",
			"_CtrlAttributesResponse_ResponsesDelete"
		];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_MouseOver = _Display Getvariable "MouseOver";

		_CtrlRightClickMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_RightClickMenu;
		_CtrlRightClickMenu Ctrlshow False;

		_CtrlChatSection = _Display DisplayCtrl _MouseOver;
		_CtrlChatSectionID = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_ChatSectionID;
		_CtrlChatSectionText = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_Text_Text;
		_CtrlChatSectionResponse = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_Response;

		_CtrlAttributesMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu;
		_CtrlAttributesMenu ctrlshow True;
		_CtrlAttributesMenu setvariable ["_CtrlChatSection", _CtrlChatSection];
		Ctrlsetfocus _CtrlAttributesMenu;

		_CtrlAttributesId_IdEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Id_IdEdit;
		_CtrlAttributesId_IdEdit CtrlSetText CtrlText _CtrlChatSectionID;

		_Text = _CtrlChatSection getvariable ["Text", ""];
		if (_Text isequaltype []) then {_Text = _Text joinstring tostring [10]};
		_CtrlAttributesText_TextEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Text_TextEdit;
		_CtrlAttributesText_TextEdit CtrlSetText _Text;
		["ColorEdit", [_CtrlAttributesText_TextEdit]] Call ETO_fnc_ChatEditor;

		_CtrlAttributesText_SoundConfigEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Text_SoundConfigEdit;
		_CtrlAttributesText_SoundConfigEdit CtrlSetText (_CtrlChatSection getvariable ["SoundConfig", ""]);
		["ColorEdit", [_CtrlAttributesText_SoundConfigEdit]] Call ETO_fnc_ChatEditor;

		_CtrlAttributesText_Say3DCheckBox = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Text_Say3DCheckBox;
		_CtrlAttributesText_Say3DCheckBox CbsetChecked (_CtrlChatSection getvariable ["Say3D", True]);

		_CtrlAttributesResponse_ResponsesList = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ResponsesList;
		LbClear _CtrlAttributesResponse_ResponsesList;

		For "_i" from 0 to (lnbsize _CtrlChatSectionResponse select 0)-1 do {
			(_CtrlChatSectionResponse GetVariable format ["Response %1_Data", _I+1]) Params [
				["_SoundConfig", "", [""]],
				["_Say3D", True, [True]],
				["_Code", "", [""]],
				["_CodeArguments", "", [""]],
				["_Condition", "True", [""]],
				["_ConditionArguments", "", [""]],
				"_NextId",
				"_ResponseText"
			];

			_NextId = _CtrlChatSectionResponse LnbText [_I, 0];
			_ResponseText = _CtrlChatSectionResponse LnbText [_I, 1];
			_ResponseText = _ResponseText select [(_ResponseText find " ")+1, (Count _ResponseText)-3];

			_CtrlAttributesResponse_ResponsesList LbAdd format ["Response %1", _I+1];
			_CtrlAttributesMenu Setvariable [format ["Response %1_Data", _I+1], [_NextId, _ResponseText, _SoundConfig, _Say3D, _Code, _CodeArguments, _Condition, _ConditionArguments]];
		};
		_CtrlAttributesResponse_ResponsesList LbSetCursel 0;

		_CtrlAttributesResponse_ResponsesDelete = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ResponsesDelete;
		_CtrlAttributesResponse_ResponsesDelete CtrlEnable ([False, True] select (LbSize _CtrlAttributesResponse_ResponsesList > 1));
	};

	case "closeattributes": {
		_Arguments params [
			["_ApplyChanges", False, [False]],
			"_Display",
			"_CtrlAttributesMenu",
			"_CtrlAttributesResponse_ResponsesList",
			"_CtrlAttributesId_IdEdit",
			"_CtrlAttributesResponse_NextIdEdit",
			"_IdValid",
			"_NextIdValid",
			"_ErrorParams",
			"_Error",
			"_CtrlError",
			"_CtrlChatSection",
			"_CtrlAttributesText_TextEdit",
			"_CtrlAttributesText_SoundConfigEdit",
			"_CtrlAttributesText_Say3DCheckBox",
			"_CtrlChatSectionID",
			"_Text",
			"_CtrlChatSectionText",
			"_CtrlChatSectionResponse",
			"_State"
		];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlAttributesMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu;
		_CtrlAttributesResponse_ResponsesList = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ResponsesList;
		_CtrlAttributesId_IdEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Id_IdEdit;
		_CtrlAttributesResponse_NextIdEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_NextIdEdit;

		_IdValid = ["ConfirmId", [_CtrlAttributesId_IdEdit]] Call ETO_fnc_ChatEditor;
		For "_i" from 0 to (Lbsize _CtrlAttributesResponse_ResponsesList)-1 do {
			(_CtrlAttributesMenu getvariable Format ["Response %1_Data", _I+1])	Params [
				["_NextId", "", [""]]
			];

			_NextIdValid = If (_I isequalto lbCurSel _CtrlAttributesResponse_NextIdEdit) then {
				["ConfirmId", [_CtrlAttributesResponse_NextIdEdit]] Call ETO_fnc_ChatEditor
			} else {["ConfirmId", [_NextId]] Call ETO_fnc_ChatEditor};
			if !((_NextIdValid select 0) isequalto "") exitwith {_NextIdValid = [_NextIdValid select 0, _I+1]}
		};

		if (_ApplyChanges && (!((_IdValid select 0) isequalto "") || !((_NextIdValid select 0) isequalto ""))) exitwith {
			_ErrorParams = [_IdValid, _NextIdValid] select ((_IdValid select 0) isequalto "");
			_Error = _ErrorParams select 0;
			_CtrlError = _ErrorParams select 1;

			switch (_Error) do
			{
				case "ResChar": {_Error = "Encountered restricted character"};
				case "ManyDots": {_Error = "Encountered to many dots"};
				case "DotEnd": {_Error = "Encountered dot at the end of edit field"};
				case "DotBeg": {_Error = "Encountered dot at the beginning of edit field"};
				case "Duplicate": {_Error = "ID allready in use"};
				case "Empty": {_Error = "ID not defined"};
			};

			switch (true) do
			{
				case (_CtrlError isequalto _CtrlAttributesId_IdEdit): {_CtrlError = "ID"};
				case (_CtrlError isequaltype 0): {_CtrlError = format ["Response %1", _CtrlError]};
			};

			["OpenPopup", [format ["%1: %2.", _CtrlError, _Error], {}, True]] Call ETO_fnc_ChatEditor;
		};

		_CtrlAttributesMenu ctrlshow False;
		Ctrlsetfocus (_Display DisplayCtrl IDC_ETO_fnc_ChatEditor_TopBar);
		_CtrlChatSection = _CtrlAttributesMenu Getvariable "_CtrlChatSection";

		if !(_ApplyChanges) exitwith {};

		_CtrlAttributesText_TextEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Text_TextEdit;
		_CtrlAttributesText_SoundConfigEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Text_SoundConfigEdit;
		_CtrlAttributesText_Say3DCheckBox = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Text_Say3DCheckBox;

		_CtrlChatSectionID = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_ChatSectionID;
		_CtrlChatSectionID CtrlSetText CtrlText _CtrlAttributesId_IdEdit;

		_Text = ctrlText _CtrlAttributesText_TextEdit splitstring ToString [10];
		_CtrlChatSectionText = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_Text_Text;
		_CtrlChatSectionText ctrlsetstructuredtext parsetext (_Text joinstring "<br/>");
		_CtrlChatSectionText CtrlSetTextColor ([ColorDefault, ColorFormat] select ((["IsSpecialText", [(_Text joinstring "<br/>")]] call ETO_fnc_ChatEditor) isequalto "format"));
		_CtrlChatSection Setvariable ["Text", _Text];
		["ResizeTextGroup", [_CtrlChatSection]] Call ETO_fnc_ChatEditor;

		_CtrlChatSection Setvariable ["SoundConfig", CtrlText _CtrlAttributesText_SoundConfigEdit];
		_CtrlChatSection Setvariable ["Say3D", CbChecked _CtrlAttributesText_Say3DCheckBox];

		_CtrlChatSectionResponse = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_Response;
		LnbClear _CtrlChatSectionResponse;

		For "_i" from 0 to (Lbsize _CtrlAttributesResponse_ResponsesList)-1 do {
			(_CtrlAttributesMenu getvariable Format ["Response %1_Data", _I+1])	Params [
				["_NextId", "", [""]],
				["_ResponseText", "", [""]],
				["_SoundConfig", "", [""]],
				["_Say3D", True, [True]],
				["_Code", "", [""]],
				["_CodeArguments", "", [""]],
				["_Condition", "True", [""]],
				["_ConditionArguments", "", [""]]
			];

			_State = ["IsSpecialText", [_ResponseText]] call ETO_fnc_ChatEditor;
			_CtrlChatSectionResponse LnbAddRow [_NextId, format ["%1. %2", _I+1, _ResponseText]];
			if (_State isequalto "format") then {_CtrlChatSectionResponse lnbSetColor [[_I, 1], ColorFormat]};
			if (_State isequalto "silent") then {_CtrlChatSectionResponse lnbSetColor [[_I, 1], ColorSilent]};
			_CtrlChatSectionResponse SetVariable [Format ["Response %1_Data", _I+1], [_SoundConfig, _Say3D, _Code, _CodeArguments, _Condition, _ConditionArguments]];
		};
	};

	case "lbadd": {
		params ["_Display","_CtrlAttributesResponse_ResponsesList","_CtrlAttributesMenu","_CtrlAttributesResponse_ResponsesDelete"];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlAttributesResponse_ResponsesList = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ResponsesList;
		_CtrlAttributesResponse_ResponsesList LbAdd Format ["Response %1", (LbSize _CtrlAttributesResponse_ResponsesList)+1];
		_CtrlAttributesResponse_ResponsesList LbSetCursel LbSize _CtrlAttributesResponse_ResponsesList-1;

		_CtrlAttributesMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu;
		_CtrlAttributesMenu Setvariable [format ["Response %1_Data", (LbSize _CtrlAttributesResponse_ResponsesList)], ["-1","Place Holder","",True,"","","True",""]];

		_CtrlAttributesResponse_ResponsesDelete = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ResponsesDelete;
		_CtrlAttributesResponse_ResponsesDelete CtrlEnable True;

		["LBSelChanged", [_CtrlAttributesResponse_ResponsesList, LbCursel _CtrlAttributesResponse_ResponsesList]] Call ETO_fnc_ChatEditor;
		CtrlSetFocus _CtrlAttributesResponse_ResponsesList;
	};

	case "lbdelete": {
		params ["_Display","_CtrlAttributesResponse_ResponsesList","_ResponseNumber","_CtrlAttributesMenu","_CtrlAttributesResponse_ResponsesDelete"];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlAttributesResponse_ResponsesList = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ResponsesList;
		_ResponseNumber = LbCursel _CtrlAttributesResponse_ResponsesList+1;

		_CtrlAttributesResponse_ResponsesList LbDelete (LbSize _CtrlAttributesResponse_ResponsesList)-1;
		_CtrlAttributesMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu;

		_CtrlAttributesMenu setvariable [format ["Response %1_Data", _ResponseNumber], nil];
		for "_i" from _ResponseNumber to LbSize _CtrlAttributesResponse_ResponsesList do {
			_CtrlAttributesMenu setvariable [format ["Response %1_Data", _I], _CtrlAttributesMenu Getvariable format ["Response %1_Data", _I+1]];
		};

		_CtrlAttributesResponse_ResponsesDelete = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ResponsesDelete;
		if (LbSize _CtrlAttributesResponse_ResponsesList isequalto 1) then {_CtrlAttributesResponse_ResponsesDelete CtrlEnable False};

		["LBSelChanged", [_CtrlAttributesResponse_ResponsesList, LbCursel _CtrlAttributesResponse_ResponsesList]] Call ETO_fnc_ChatEditor;
		CtrlSetFocus _CtrlAttributesResponse_ResponsesList;
	};

	case "lbselchanged": {
		_Arguments params [
			["_CtrlAttributesResponse_ResponsesList", ControlNull, [ControlNull]],
			["_Index", 0, [0]],
			"_Display",
			"_CtrlAttributesMenu",
			"_CtrlAttributesResponse_NextIdEdit",
			"_CtrlAttributesResponse_TextEdit",
			"_CtrlAttributesResponse_SoundConfigEdit",
			"_CtrlAttributessRespons_Say3DCheckBox",
			"_CtrlAttributesResponse_CodeEdit",
			"_CtrlAttributesResponse_CodeArgumentsEdit",
			"_CtrlAttributesResponse_ConditionEdit",
			"_CtrlAttributesResponse_ConditionArgumentsEdit"
		];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlAttributesMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu;

		(_CtrlAttributesMenu getvariable Format ["Response %1_Data", _Index+1]) Params [
			["_NextId", "", [""]],
			["_Text", "", [""]],
			["_SoundConfig", "", [""]],
			["_Say3D", True, [True]],
			["_Code", "", [""]],
			["_CodeArguments", "", [""]],
			["_Condition", "True", [""]],
			["_ConditionArguments", "", [""]]
		];

		_CtrlAttributesResponse_NextIdEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_NextIdEdit;
		_CtrlAttributesResponse_NextIdEdit CtrlSetText _NextId;

		_CtrlAttributesResponse_TextEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_TextEdit;
		_CtrlAttributesResponse_TextEdit CtrlSetText _Text;
		["ColorEdit", [_CtrlAttributesResponse_TextEdit]] Call ETO_fnc_ChatEditor;

		_CtrlAttributesResponse_SoundConfigEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_SoundConfigEdit;
		_CtrlAttributesResponse_SoundConfigEdit CtrlSetText _SoundConfig;
		["ColorEdit", [_CtrlAttributesResponse_SoundConfigEdit]] Call ETO_fnc_ChatEditor;

		_CtrlAttributessRespons_Say3DCheckBox = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_Say3DCheckbox;
		_CtrlAttributessRespons_Say3DCheckBox CbsetChecked _Say3D;

		_CtrlAttributesResponse_CodeEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_CodeEdit;
		_CtrlAttributesResponse_CodeEdit CtrlSetText _Code;

		_CtrlAttributesResponse_CodeArgumentsEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_CodeArgumentsEdit;
		_CtrlAttributesResponse_CodeArgumentsEdit CtrlSetText _CodeArguments;

		_CtrlAttributesResponse_ConditionEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ConditionEdit;
		_CtrlAttributesResponse_ConditionEdit CtrlSetText _Condition;

		_CtrlAttributesResponse_ConditionArgumentsEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ConditionArgumentsEdit;
		_CtrlAttributesResponse_ConditionArgumentsEdit CtrlSetText _ConditionArguments;
	};

	case "storeresponse": {
		_Arguments params [
			"_Display",
			"_CtrlAttributesMenu",
			"_CtrlAttributesResponse_ResponsesList",
			"_Index",
			"_CtrlAttributesResponse_NextIdEdit",
			"_CtrlAttributesResponse_TextEdit",
			"_CtrlAttributesResponse_SoundConfigEdit",
			"_CtrlAttributessRespons_Say3DCheckBox",
			"_CtrlAttributesResponse_CodeEdit",
			"_CtrlAttributesResponse_CodeArgumentsEdit",
			"_CtrlAttributesResponse_ConditionEdit",
			"_CtrlAttributesResponse_ConditionArgumentsEdit",
			"_NextId",
			"_Text",
			"_SoundConfig",
			"_Say3D",
			"_Code",
			"_CodeArguments",
			"_Condition",
			"_ConditionArguments"
		];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlAttributesMenu = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu;
		_CtrlAttributesResponse_ResponsesList = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ResponsesList;
		_Index = LbCursel _CtrlAttributesResponse_ResponsesList;

		_CtrlAttributesResponse_NextIdEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_NextIdEdit;
		_NextId = CtrlText _CtrlAttributesResponse_NextIdEdit;

		_CtrlAttributesResponse_TextEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_TextEdit;
		_Text = CtrlText _CtrlAttributesResponse_TextEdit;

		_CtrlAttributesResponse_SoundConfigEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_SoundConfigEdit;
		_SoundConfig = CtrlText _CtrlAttributesResponse_SoundConfigEdit;

		_CtrlAttributessRespons_Say3DCheckBox = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_Say3DCheckbox;
		_Say3D = CbChecked _CtrlAttributessRespons_Say3DCheckBox;

		_CtrlAttributesResponse_CodeEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_CodeEdit;
		_Code = CtrlText _CtrlAttributesResponse_CodeEdit;

		_CtrlAttributesResponse_CodeArgumentsEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_CodeArgumentsEdit;
		_CodeArguments = CtrlText _CtrlAttributesResponse_CodeArgumentsEdit;

		_CtrlAttributesResponse_ConditionEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ConditionEdit;
		_Condition = CtrlText _CtrlAttributesResponse_ConditionEdit;

		_CtrlAttributesResponse_ConditionArgumentsEdit = _Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_ConditionArgumentsEdit;
		_ConditionArguments = CtrlText _CtrlAttributesResponse_ConditionArgumentsEdit;

		_CtrlAttributesMenu Setvariable [Format ["Response %1_Data", _Index+1], [_NextId, _Text, _SoundConfig, _Say3D, _Code, _CodeArguments, _Condition, _ConditionArguments]];
	};

	case "resizetextgroup": {
		_Arguments params [
			["_CtrlChatSection", ControlNull, [ControlNull]],
			"_Display",
			"_CtrlText_Text",
			"_MinHeight",
			"_CurrentHeight",
			"_Pos"
		];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlText_Text = _CtrlChatSection controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_Text_Text;
		_MinHeight = 3.45 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25);
		_CurrentHeight = CtrlTextHeight _CtrlText_Text + 0.17 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25);

		_Pos = CtrlPosition _CtrlText_Text;
		_Pos set [3, (_MinHeight Max _CurrentHeight)];
		_CtrlText_Text CtrlSetPosition _Pos;
		_CtrlText_Text CtrlCommit 0;
	};

	case "confirmid": {
		_Arguments params [
			["_CtrlEdit", "", ["", Controlnull]],
			"_Display",
			"_CtrlChatSection",
			"_CtrlText",
			"_IsNextId",
			"_ValidateArray",
			"_CountDots",
			"_UsedIds",
			"_Ctrl",
			"_ValidateId"
		];

		_Display = UINamespace Getvariable "ETO_fnc_ChatEditor_Display";
		_CtrlChatSection = (_Display DisplayCtrl IDC_ETO_fnc_ChatEditor_AttributesMenu) Getvariable ["_CtrlChatSection", ControlNull];

		_CtrlText = If (_CtrlEdit isequaltype "") then {_CtrlEdit} else {CtrlText _CtrlEdit};
		_CtrlText = _CtrlText splitstring "";
		_IsNextId = If (_CtrlEdit isequaltype "") then {True} else {CtrlIDC _CtrlEdit isequalto IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_NextIdEdit};
		_ValidateArray = ["0","1","2","3","4","5","6","7","8","9","0","."];
		_CountDots = 0;
		if (_IsNextId) then {_ValidateArray = _ValidateArray + ["-","+"]};

		_UsedIds = [];
		{
			_Ctrl = (_Display DisplayCtrl _x);
			if !(_Ctrl isequalto _CtrlChatSection) then {
				_UsedIds Pushback (CtrlText (_Ctrl controlsGroupCtrl IDC_ETO_fnc_ChatEditor_ChatSection_ChatSectionID) call _ParseNumber)
			};
		} foreach (_Display Getvariable ["_ChatSectionCtrlIdcs", []]);

		_ValidateId = {
			if (_x isequalto ".") then {_CountDots = _CountDots+1};
			if !(_x in _ValidateArray) exitwith {"ResChar"};
			if (_CountDots > 1) exitwith {"ManyDots"};
			if (_ForeachIndex isequalto 0 && _x in ["."]) exitwith {"DotBeg"};
			if (_ForeachIndex isequalto (Count _CtrlText)-1 && _x in ["."]) exitwith {"DotEnd"};
			if (_ForeachIndex > 0 && _x in ["-", "+"]) exitwith {"ResChar"};

			""
		} foreach _CtrlText;
		if ((_CtrlText joinstring "") call _ParseNumber in _UsedIds && !_IsNextId) then {_ValidateId = "Duplicate"};
		if ((_CtrlText joinstring "") isequalto "") then {_ValidateId = "Empty"};
		if (isnil "_ValidateId") then {_ValidateId = ""};

		[_ValidateId, _CtrlEdit]
	};

	case "coloredit": {
		_Arguments Params [
			["_CtrlEdit", Controlnull, [Controlnull]],
			"_State",
			"_IsResponse"
		];

		_State = ["IsSpecialText", [CtrlText _CtrlEdit]] call ETO_fnc_ChatEditor;
		_IsResponse = CtrlIDC _CtrlEdit isequalto IDC_ETO_fnc_ChatEditor_AttributesMenu_Response_TextEdit;

		switch (True) do {
			case (_State isequalto "format"): {_CtrlEdit CtrlsetTextColor ColorFormat};
			case (_State isequalto "silent" && _IsResponse): {_CtrlEdit CtrlsetTextColor ColorSilent};
			Default {_CtrlEdit CtrlsetTextColor ColorDefault};
		};
	};

	case "checkempty": {
		_Arguments params [
			["_CtrlEdit", Controlnull, [Controlnull]]
		];

		[(ctrlText _CtrlEdit isequalto ""), _CtrlEdit]
	};

	case "isspecialtext": {
		_Arguments Params ["_Text"];

		if (_Text select [0,1] isequalto "(" && _Text select [(Count _Text)-1, 1] Isequalto ")") exitwith {"silent"};
		if (Tolower _Text Select [0,6] isequalto "format" || {_Text Select [0,2] isequalto '["' && (_Text Select [(Count _Text)-1,1] isequalto "]" || _Text Select [(Count _Text)-2,2] isequalto "];")}) exitwith {"format"};

		""
	};
};
