-- Server-only. Never redirect a failing DataStore session to memory.
return table.freeze({
	Mode=game.GameId==0 and "StudioMemory" or "DataStoreTest", TestUniverseId=10775037187,
	Name="PaketKilat_TEST_v1", Scope="T16_T20_QA", KeyPrefix="qa:",
	LeaseSeconds=120, LeaseSafety=15, SaveInterval=30, RetryCount=3,
	Backoff=0.5, CloseTimeout=25, MaxCoins=1000000000,
})
