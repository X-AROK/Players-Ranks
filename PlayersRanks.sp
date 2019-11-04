#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "X-AROK"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include <playersmanager>
#include <csgo_colors>
#include <vip_core>
#include <scp>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Players Ranks",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

Handle g_hAddTimeTimer;
int g_iTimeToUpdateLeft = 30;
int g_iTimeToRanks[11];
Database g_hDatabase;
bool g_bIsRanksLoaded = false;
Handle g_hCookie;

public void OnPluginStart(){
	g_hAddTimeTimer = CreateTimer(60.0, AddTimeTimer_Func, _, TIMER_REPEAT);
	
	Database.Connect(ConnectCallBack, "excetra");
	
	g_hCookie = RegClientCookie("VIP_Chat_Prefix", "VIP_Chat_Prefix", CookieAccess_Private);
	
	HookEvent("player_footstep", OnPlayerFootstep);
	
	RegConsoleCmd("sm_time", TimeCmd_Callback);
}

public void OnPluginEnd(){
	if(g_hAddTimeTimer != INVALID_HANDLE){
		KillTimer(g_hAddTimeTimer);
		g_hAddTimeTimer = INVALID_HANDLE;
	}
	UnhookEvent("player_footstep", OnPlayerFootstep);
}

void LoadRanks(){
	char szQuery[256];
	FormatEx(szQuery, 256, "SELECT * FROM `ranks`");
	g_hDatabase.Query(SQL_Callback_SelectRanks, szQuery);
}

//Увеличение времени
public Action AddTimeTimer_Func(Handle timer){
	for (int i = 1; i <= MaxClients; i++){
		if(IsClientInGame(i) && !IsFakeClient(i) && PM_isClientLoaded(i)){
			PM_addToClientTime(i, 1);
			if(g_bIsRanksLoaded){
				int rank = PM_getClientRank(i);
				if(rank < 10 && PM_getClientTime(i) >= g_iTimeToRanks[rank + 1]){
					PM_IncreaseClientRank(i);
					char name[100];
					GetClientName(i, name, sizeof(name));
					CGOPrintToChatAll("{RED}[Ranks] {DEFAULT}Игрок {GREEN}%s {DEFAULT}получил {OLIVE}Ранг %i{DEFAULT}!", name, rank + 1);
				}
			}
		}
	}
	
	//Каждые 30 минут обновляем БД
	g_iTimeToUpdateLeft--;
	
	if(g_iTimeToUpdateLeft == 0){
		g_iTimeToUpdateLeft = 30;
		for (int i = 1; i <= MaxClients; i++){
			if(IsClientInGame(i) && !IsFakeClient(i) && PM_isClientLoaded(i)){
				PM_updateClient(i);
			}
		}
	}
	
	return Plugin_Continue;
}

//Получение времени для рангов из БД
public void ConnectCallBack (Database hDB, const char[] szError, any data){
	if (hDB == null || szError[0]){
		SetFailState("Database failure: %s", szError);
		return;
	}
	g_hDatabase = hDB;
	g_hDatabase.SetCharset("utf8");
	
	LoadRanks();
}

public void SQL_Callback_SelectRanks(Database hDatabase, DBResultSet results, const char[] sError, any data){
	if(sError[0]){
		LogError("SQL_Callback_InsertClient: %s", sError);
		return;
	}
	
	while(results.FetchRow()){
		int id = results.FetchInt(0);
		int time = results.FetchInt(1);
		
		g_iTimeToRanks[id] = time;
		
		results.FetchMoreResults();
	}
	
	g_bIsRanksLoaded = true;
}

//Вывод времени (!time)
public Action TimeCmd_Callback(int client, int args){
	if(PM_isClientLoaded(client)){
		int time = PM_getClientTime(client);
		int rank = PM_getClientRank(client);
		
		int minutes = time % 60;
		int hours = time / 60;
		
		CGOPrintToChat(client, "{RED}[Ranks] {DEFAULT}Ваше наигранное время: {OLIVE}%i ч. %i мин.", hours, minutes);
		if(rank == 0){
			CGOPrintToChat(client, "{RED}[Ranks] {DEFAULT}Ваш ранг: {GRAY}Новичок{DEFAULT}.");
		}
		else{
			CGOPrintToChat(client, "{RED}[Ranks] {DEFAULT}Ваш ранг: {OLIVE}Ранг %i{DEFAULT}.", rank);
		}
	}
	else{
		CGOPrintToChat(client, "{RED}[Ranks] {DEFAULT}Ваши данные еще загружаются.");
	}
	
	return Plugin_Handled;
}

//Префикс
public Action OnChatMessage(int &iClient, Handle hRecipients, char[] sName, char[] sMessage){
	if(VIP_IsClientVIP(iClient) && VIP_IsClientFeatureUse(iClient, "Chat")){
		char sBuffer[192];
		char sFeature[192];
		GetClientCookie(iClient, g_hCookie, sBuffer, 192);
		VIP_GetClientFeatureString(iClient, "Chat_Prefix", sFeature, sizeof(sFeature));
		if(!(sBuffer[0] == '0' || (StrEqual(sFeature, "custom") && StrEqual(sBuffer, "")))){
			return Plugin_Continue;
		}
	}
	if(!PM_isClientLoaded(iClient)){
		return Plugin_Continue;
	}
	
	int rank = PM_getClientRank(iClient);
	if(rank == 0){
		Format(sName, MAXLENGTH_NAME, " \x08[Новичок] \x03%s", sName);
	}
	else{
		Format(sName, MAXLENGTH_NAME, " \x10[Ранг %i] \x03%s", rank, sName);
	}
	return Plugin_Changed;
}

//Тэг (обновляется при каждом шаге)
public Action OnPlayerFootstep(Event event, const char [] name, bool dontBroadcast){
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(VIP_IsClientVIP(iClient) && VIP_IsClientFeatureUse(iClient, "Tag")){
		return Plugin_Continue;
	}
	if(!PM_isClientLoaded(iClient)){
		return Plugin_Continue;
	}
	
	int rank = PM_getClientRank(iClient);
	if(rank == 0){
		CS_SetClientClanTag(iClient, "[Newbie] ");
	}
	else{
		char szBuff[32];
		FormatEx(szBuff, 32, "[Rank %i] ", rank);
		CS_SetClientClanTag(iClient, szBuff);
	}
	
	return Plugin_Continue;
}