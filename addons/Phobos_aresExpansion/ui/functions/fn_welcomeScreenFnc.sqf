#define CHANGELOG_DIALOG_IDD 340100

(findDisplay CHANGELOG_DIALOG_IDD) closeDisplay 0;
profileNamespace setVariable ["Phobos_version",getText(configfile >> "CfgPatches" >> "Phobos" >> "versionStr")];
saveProfileNamespace;