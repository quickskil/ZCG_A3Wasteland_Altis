//	@file Version: 1.2
//	@file Name: oSave.sqf
//	@file Author: [GoT] JoSchaap, AgentRev
//	@file Description: Basesaving script

if (!isServer) exitWith {};

diag_log "oSave started";
_stepSize = 18;

while {true} do {
	sleep 30;
	
	waitUntil {!isLoadingObjects};
	
	_trigger = "DoSave" call sqlite_getTrigger;
	
	if (_trigger == 1) then {
	
		_PersistentDB_ObjCount = 1;
		
		_saveQuery = "INSERT INTO Objects (SequenceNumber, Name, Position, Direction, SupplyLeft, Weapons, Magazines, Items, IsVehicle, IsSaved, GenerationCount, Owner, Damage, AllowDamage, Texture) VALUES ";
		
		{
			_object = _x;
			
			if (_object getVariable ["objectLocked", false] && {alive _object}) then
			{
				_classname = typeOf _object;
				
				// addition to check if the classname matches the building parts
				// if ({_classname == _x} count _saveableObjects > 0) then
				// {
					_pos = getPosATL _object;
					_dir = [vectorDir _object] + [vectorUp _object];

					_supplyleft = 0;

					switch (true) do
					{
						case (_object isKindOf "Land_Sacks_goods_F"):
						{
							_supplyleft = _object getVariable ["food", 20];
						};
						case (_object isKindOf "Land_BarrelWater_F"):
						{ 
							_supplyleft = _object getVariable ["water", 20];
						};
					};
					
					_owner = _object getVariable ["ownerUID", ""];
					_damage = damage _object;
					_allowDamage = if (_object getVariable ["allowDamage", true]) then { 1 } else { 0 };

					// Save weapons & ammo
					_weapons = getWeaponCargo _object;
					_magazines = getMagazineCargo _object;
					_items = getItemCargo _object;
					_isVehicle = 0;
					_texture = _object getVariable ["Texture", ""];
					
					if (_object isKindOf "Car" || _object isKindOf "Air" || _object isKindOf "Ship" || _object isKindOf "Tank" ) then
					{
						_isVehicle = 1;
					};
					
					_saveQuery = _saveQuery + format ["(%1, ''%2'', ''%3'', ''%4'', %5, ''%6'', ''%7'', ''%8'', %9, 0, %10, ''%11'', %12, %13, ''%14''),", _PersistentDB_ObjCount, _classname, _pos, _dir, _supplyleft, _weapons, _magazines, _items, _isvehicle, _object getVariable ["generationCount", 0], _owner, _damage, _allowDamage, _texture];
					
					_PersistentDB_ObjCount = _PersistentDB_ObjCount + 1;
					
					//Save in batches so we don't hit the max 4000 char arma2net string length limit
					if ((_PersistentDB_ObjCount % _stepSize) == 0) then { 
						_saveQuery call sqlite_saveBaseObjects;
						
						_saveQuery = "INSERT INTO Objects (SequenceNumber, Name, Position, Direction, SupplyLeft, Weapons, Magazines, Items, IsVehicle, IsSaved, GenerationCount, Owner, Damage, AllowDamage, Texture) VALUES ";
					};
				// };
			};
		}forEach (allMissionObjects "All");
		
		if ((_PersistentDB_ObjCount > 1) && ((_PersistentDB_ObjCount % _stepSize) != 0)) then {
			_saveQuery call sqlite_saveBaseObjects;
			
			diag_log format["A3Wasteland - %1 parts have been saved with DB", _PersistentDB_ObjCount];
		};
		
		call sqlite_commitBaseObject;
		
		"DoSave" call sqlite_setTrigger;
	};
};
