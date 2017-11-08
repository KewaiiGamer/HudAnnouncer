#pragma semicolon 1
#include <sourcemod>
#include <clientprefs>
#include <csgocolors>

#pragma newdecls required
#define PLUGIN_DESCRIPTION  "Configurable multiple announces on TOP HUD"
#define PLUGIN_AUTHOR 		"Kewaii"
#define PLUGIN_VERSION 		"1.1.1"
#define PLUGIN_TAG			"[HudAnnouncer by Kewaii]"
#define PLUGIN_NAME      "HudAnnouncer"

public Plugin myinfo = {
 name =  PLUGIN_NAME,
 author = PLUGIN_AUTHOR,
 description = PLUGIN_DESCRIPTION,
 version = PLUGIN_VERSION
};

ConVar g_CvarMessages;

char g_sMessages[1024];
char currentMessage[128];
char parts[64][64];

int messagesAmt;

public void OnPluginStart()
{
	g_CvarMessages = CreateConVar("kewaii_hudannouncer_messages", "Primeira;Segunda;Terceira;Quarta", "Defines all messages, separated by semicolons");
	AutoExecConfig(true, "kewaii_hudannouncer");
	Format(g_sMessages, sizeof(g_sMessages), "");
	CreateTimer(1.0, InitMessages);
	CreateTimer(5.0, FirstHUD, 0);
}

public Action InitMessages(Handle timer) 
{
	GetConVarString(g_CvarMessages, g_sMessages, sizeof(g_sMessages));
	Format(g_sMessages, sizeof(g_sMessages), "%s;Hud Announcer Developed By Kewaii", g_sMessages);
	messagesAmt = ExplodeString(g_sMessages, ";", parts, sizeof(parts), sizeof(parts[]));
}

public Action FirstHUD(Handle timer, int nextMessage)
{
	Format(currentMessage, sizeof(currentMessage), parts[nextMessage]);
	// Since the Text Parameters are now supported in CS:GO, it's better to use this way.
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			SetHudTextParams(-1.0, 0.1, 5.0, 26, 16, 94, 100, 0, 0.1, 0.1, 0.1);
			ShowHudText(i, 5, currentMessage);
			PrintToConsole(i, "%i", sizeof(parts));
		}
	}
	if (nextMessage != messagesAmt) {
		nextMessage++;
	}
	else
	{
		nextMessage = 0;
	}
	CreateTimer(5.0, FirstHUD, nextMessage);
}