#pragma semicolon 1
#include <sourcemod>
#include <clientprefs>

#pragma newdecls required
#define PLUGIN_DESCRIPTION  "Configurable multiple announces on TOP HUD"
#define PLUGIN_AUTHOR 		"Kewaii"
#define PLUGIN_VERSION 		"1.2.0"
#define PLUGIN_NAME     	"HudAnnouncer"

public Plugin myinfo = {
 name =  PLUGIN_NAME,
 author = PLUGIN_AUTHOR,
 description = PLUGIN_DESCRIPTION,
 version = PLUGIN_VERSION
};

ConVar g_CvarMessages;
ConVar g_CvarHudsayChannel;
ConVar g_CvarTimeHeld;
ConVar g_CvarTimeBetweenMessages;

ConVar g_CvarColorRedValue;
ConVar g_CvarColorGreenValue;
ConVar g_CvarColorBlueValue;
ConVar g_CvarColorTransparencyValue;

ConVar g_CvarEffectType;

ConVar g_CvarEffectDuration;
ConVar g_CvarFadeInDuration;
ConVar g_CvarFadeOutDuration;

char g_sMessages[1024];
char currentMessage[128];
char parts[16][128];

int messagesAmt;
float g_fTimeHeld;
int g_iNextMessage;
public void OnPluginStart()
{
	g_CvarMessages = CreateConVar("kewaii_hudannouncer_messages", "First;Second;Third;Fourth", "Defines all messages, separated by semicolons.");
	g_CvarHudsayChannel = CreateConVar("kewaii_hudannouncer_channel", "2", "Hudannouncer channel to prevent overriding from other plugins.");
	g_CvarTimeHeld = CreateConVar("kewaii_hudannouncer_timeheld", "2.0", "Amount of time in seconds messages are held.");
	g_CvarTimeBetweenMessages = CreateConVar("kewaii_hudannouncer_timebetweenmessages", "2.0", "Amount of time in seconds between messages.");	
	g_CvarColorRedValue = CreateConVar("kewaii_hudannouncer_color_red", "0", "Message Red Color Value.");	
	g_CvarColorGreenValue = CreateConVar("kewaii_hudannouncer_color_green", "0", "Message Green Color Value.");	
	g_CvarColorBlueValue = CreateConVar("kewaii_hudannouncer_color_blue", "0", "Message Blue Color Value.");
	g_CvarColorTransparencyValue = CreateConVar("kewaii_hudannouncer_color_red", "100", "Message Transparency Value.");	
	g_CvarEffectType = CreateConVar("kewaii_hudannouncer_effect_type", "1.0", "0 - Fade In; 1 - Fade out; 2 - Flash", _, true, 0.0, true, 2.0);
	g_CvarEffectDuration = CreateConVar("kewaii_hudannouncer_effect_duration", "0.5", "Duration of the selected effect. Not always aplicable");
	g_CvarFadeInDuration = CreateConVar("kewaii_hudannouncer_fadein_duration", "0.5", "Duration of the selected effect.");
	g_CvarFadeOutDuration = CreateConVar("kewaii_hudannouncer_fadeout_duration", "0.5", "Duration of the selected effect.");
	AutoExecConfig(true, "kewaii_hudannouncer");
	Format(g_sMessages, sizeof(g_sMessages), "");
}

public void OnConfigsExecuted() 
{
	GetConVarString(g_CvarMessages, g_sMessages, sizeof(g_sMessages));
	Format(g_sMessages, sizeof(g_sMessages), "%s", g_sMessages);
	messagesAmt = ExplodeString(g_sMessages, ";", parts, sizeof(parts), sizeof(parts[]));
	float timeBetweenMessages = GetConVarFloat(g_CvarTimeBetweenMessages);
	g_fTimeHeld = GetConVarFloat(g_CvarTimeHeld);
	g_iNextMessage = 0;
	CreateTimer(g_fTimeHeld + timeBetweenMessages, FirstHUD, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action FirstHUD(Handle timer)
{
	Format(currentMessage, sizeof(currentMessage), parts[g_iNextMessage]);
	
	int channel = GetConVarInt(g_CvarHudsayChannel);	
	int red = GetConVarInt(g_CvarColorRedValue);
	int green = GetConVarInt(g_CvarColorGreenValue);
	int blue = GetConVarInt(g_CvarColorBlueValue);
	int alpha = GetConVarInt(g_CvarColorTransparencyValue);
	int effect = GetConVarInt(g_CvarEffectType);
	float effectDuration = GetConVarFloat(g_CvarEffectDuration);
	float fadeIn = GetConVarFloat(g_CvarFadeInDuration);
	float fadeOut = GetConVarFloat(g_CvarFadeOutDuration);	
	
	
	// Since the Text Parameters are now supported in CS:GO, it's better to use this way.
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			
			SetHudTextParams(-1.0, 0.1, g_fTimeHeld, red, green, blue, alpha, effect, effectDuration, fadeIn, fadeOut);
			ShowHudText(i, channel, currentMessage);
		}
	}
	if (g_iNextMessage != messagesAmt - 1) {
		g_iNextMessage++;
	}
	else
	{
		g_iNextMessage = 0;
	}
}