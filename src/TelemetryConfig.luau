-- Server only; no network credentials or user attributes.
return table.freeze({
	Version="T21-v1", AllowedUniverseId=10775037187, LiveEnabled=true,
	JournalLimit=256, QueueLimit=128, MaxCallsPerMinute=100,
	PerSessionCallsPerMinute=24, FlushInterval=0.2, CloseTimeout=3,
	Funnel="PaketKilatTrial_v1",
})
