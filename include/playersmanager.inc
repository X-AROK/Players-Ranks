#if defined _playersmanager_included
 #endinput
#endif
#define _playersmanager_included


/**
 * Set client's balance to newBalance.
 *
 * @param client
 * @param newBalance
 * 
 */
native void PM_setClientBalance(int client, int newBalance);

/**
 * Add addBalance to client's balance.
 *
 * @param client
 * @param addBalance
 * 
 */
native void PM_addToClientBalance(int client, int addBalance);

/**
 * Get client's balance.
 *
 * @param client
 * 
 */
native int PM_getClientBalance(int client);

/**
 * Set client's time to newTime.
 *
 * @param client
 * @param newTime
 * 
 */
native void PM_setClientTime(int client, int newTime);

/**
 * Add addTime to client's time.
 *
 * @param client
 * @param addTime
 * 
 */
native void PM_addToClientTime(int client, int addTime);

/**
 * Get client's time.
 *
 * @param client
 * 
 */
native int PM_getClientTime(int client);

/**
 * Set client's rank to newRank.
 *
 * @param client
 * @param newRank
 * 
 */
native void PM_setClientRank(int client, int newRank);

/**
 * Increase client rank by 1
 *
 * @param client
 * 
 */
native void PM_IncreaseClientRank(int client);

/**
 * Get client's rank.
 *
 * @param client
 * 
 */
native int PM_getClientRank(int client);

/**
 * Get client's id.
 *
 * @param client
 * 
 */
native int PM_getClientId(int client);

/**
 * Update client in db.
 *
 * @param client
 * 
 */
native void PM_updateClient(int client);

/**
 * Check load status of client
 *
 * @param client
 * 
 */
native bool PM_isClientLoaded(int client);