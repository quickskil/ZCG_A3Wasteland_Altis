/**
 * Décharger un objet d'un transporteur - appelé deuis l'interface listant le contenu du transporteur
 * 
 * Copyright (C) 2010 madbull ~R3F~
 * 
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

if (R3F_LOG_mutex_local_verrou) then
{
	player globalChat STR_R3F_LOG_mutex_action_en_cours;
}
else
{
	R3F_LOG_mutex_local_verrou = true;
	
	#include "dlg_constantes.h"
	private ["_transporteur", "_objets_charges", "_type_objet_a_decharger", "_objet_a_decharger", "_i"];
	
	_objet_a_decharger = _this select 0;
	_actionId = _this select 2;
	
	_transporteur = attachedTo _objet_a_decharger;
	_objets_charges = _transporteur getVariable "R3F_LOG_objets_charges";
	
	if !(isNull _objet_a_decharger) then
	{
		// On mémorise sur le réseau le nouveau contenu du transporteur (càd avec cet objet en moins)
		_objets_charges = _objets_charges - [_objet_a_decharger];
		_transporteur setVariable ["R3F_LOG_objets_charges", _objets_charges, true];
		_objet_a_decharger setVariable ["R3F_LOG_est_transporte_par", objNull, true];
		_objet_a_decharger enableSimulationGlobal true;
		R3F_LOG_PUBVAR_point_attache enableSimulationGlobal true;
		
		detach _objet_a_decharger;
		
		_objet_a_decharger removeAction _actionId;
		
		if ({_objet_a_decharger isKindOf _x} count R3F_LOG_CFG_objects_movables > 0) then
		{
			[_objet_a_decharger] execVM "addons\R3F_ARTY_AND_LOG\R3F_LOG\objet_deplacable\deplacer.sqf";
		}
		else
		{
			private ["_dimension_max"];
			_dimension_max = (((boundingBox _objet_a_decharger select 1 select 1) max (-(boundingBox _objet_a_decharger select 0 select 1))) max ((boundingBox _objet_a_decharger select 1 select 0) max (-(boundingBox _objet_a_decharger select 0 select 0))));
			
			player globalChat STR_R3F_LOG_action_decharger_en_cours;
			
			sleep 2;
			
			// On pose l'objet au hasard vers l'arrière du transporteur
			_objet_a_decharger setPos [
				(getPos _transporteur select 0) - ((_dimension_max+5+(random 10)-(boundingBox _transporteur select 0 select 1))*sin (getDir _transporteur - 90+random 180)),
				(getPos _transporteur select 1) - ((_dimension_max+5+(random 10)-(boundingBox _transporteur select 0 select 1))*cos (getDir _transporteur - 90+random 180)),
				0
			];
			_objet_a_decharger setVelocity [0,0,0];
			
			player globalChat STR_R3F_LOG_action_decharger_fait;
		};
	}
	else
	{
		player globalChat STR_R3F_LOG_action_decharger_deja_fait;
	};
	
	R3F_LOG_mutex_local_verrou = false;
};