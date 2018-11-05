#include "\Phobos_aresExpansion\module_header.hpp"

_unitUnderCursor = [_logic,false] call Ares_fnc_GetUnitUnderCursor;
[_unitUnderCursor, "Test"] call Phobos_fnc_directChat;

#include "\Phobos_aresExpansion\module_footer.hpp"
