#include <amxmodx>
#include <amxmisc>
#include <cstrike>
//
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <fun>
//

#pragma tabsize 0

#define PLUGIN  "Server_Menu"
#define VERSION "2.5"
#define AUTHOR  "Kveda"

new bool:g_water_entity[1386], bool:g_water_found, bool:g_invisible[33];
new point2[33], g_spectated[33];


new keys3 = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_9|MENU_KEY_0



public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_menu("Menu 3", keys3, "settings_keys")
	register_clcmd("say /settings", "settings")
	register_clcmd("settings", "settings")
	register_forward(FM_AddToFullPack, "fw_fullpack");
	register_forward(FM_PlayerPreThink, "fw_prethink");
}

public client_putinserver(id)
{
	point2[id] = false;
	g_invisible[id] = false;
	g_spectated[id] = 0;
}

public settings(id)
{								
	static menu[1024], iLen
	iLen = 0
	iLen = formatex(menu[iLen], charsmax(menu) - iLen, "^n\yНастройки:^n^n")

	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r1. \wЗрители \d[\rSPECLIST\d]^n")
	keys3 |= MENU_KEY_1

	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r2. \wЗатемнение экрана \d[\rCOLORS\d]^n")
	keys3 |= MENU_KEY_2
	 
	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r3. \wИгроки \d[\rPLAYERS\d]^n")
	keys3 |= MENU_KEY_3
	 
	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r4. \wВода \d[\rWATER\d]^n")
	keys3 |= MENU_KEY_4

	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r5. \wСменить язык \d[\rRUS/ENG\d]^n^n^n^n^n")
	keys3 |= MENU_KEY_5
	 
//	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r9. \wHaзaд^n")
//	keys3 |= MENU_KEY_9

	iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r0. \wBыxoд^n")
	keys3 |= MENU_KEY_0

	show_menu(id, keys3, menu, -1, "Menu 3")
	return PLUGIN_HANDLED
}

public settings_keys(id, key)
{
	switch(key)
	{
		case 0:
		  {
		  client_cmd(id, "say /speclist")
		  settings(id)
		  }
		case 1: client_cmd(id, "colors")
//		  case 2: client_cmd(id, "say /soundmenu")
		case 2:
		{
			client_cmd(id,"spk buttons/blip1");
			settings(id);
			//g_invisible[id] = !g_invisible[id];
			if(g_invisible[id])
			{
				g_invisible[id] = false;
				client_print_color(id, print_team_default, "^4[ESC]^1 Игроки включены!");
			}
			else
			{
				g_invisible[id] = true;
				client_print_color(id, print_team_default, "^4[ESC]^1 Игроки убраны!");
			}
		}
		  case 3:
		{
			client_cmd(id,"spk buttons/blip1");
			settings(id);
			if(g_water_found)
			{
				if(point2[id])
				{
					point2[id] = false;
					client_print_color(id, print_team_default, "^4[ESC]^1 Вода вновь видна!");
				}
				else
				{
					point2[id] = true;
					client_print_color(id, print_team_default, "^4[ESC]^1 Вода убрана!");
				}
			}
			else
			{
				client_print_color(id, print_team_default, "^4[ESC]^1 На этой карте нет воды!");
			}
		}
		  case 4: 
		  {
		  client_cmd(id, "say /rus")
		  settings(id)
		  }
//		case 8: server_menu2(id)
	}
	return PLUGIN_HANDLED
}

public plugin_cfg()
{
   	new ent = engfunc(EngFunc_FindEntityByString, -1, "classname", "func_water");

	while(ent > 0)
	{
	 		if(!g_water_found)
	 		{
	    		g_water_found = true;
		}

	 		g_water_entity[ent] = true;
	 		ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_water");
   	}
}

public fw_fullpack(es_handle, e, ent, host, hostflags, player, pset)
{
	if(player)
	{
		if(g_invisible[host] && host != ent)
		{
			if(!is_user_connected(ent)) return FMRES_IGNORED;
			if(ent != g_spectated[host])
			{
				set_es(es_handle, ES_Origin, {999999999.0, 999999999.0, 999999999.0});
				set_es(es_handle, ES_RenderMode, kRenderTransAlpha);
				set_es(es_handle, ES_RenderAmt, 0);
				return FMRES_SUPERCEDE;
			}
		}
	}
	else if(point2[host])
	{
		if(g_water_entity[ent])
		{
			set_es(es_handle, ES_Effects, EF_NODRAW);
			return FMRES_SUPERCEDE;
      		}
   	}
   	return FMRES_IGNORED;
}