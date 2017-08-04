public without sharing class OpportunityTrgHandler 
{		
	public static void onAfterUpdate(List<Opportunity> trgNew,Map<Id,Opportunity> oldMap)
	{		
		Opportunity oldOpp;
		Set<Id> closedOppIdSet = new Set<Id>();
		for(Opportunity opp : trgNew)
		{
			oldOpp = oldMap.get(opp.Id);
			if(opp.IsWon && !oldOpp.IsWon)
				closedOppIdSet.add(opp.Id);
		}
		
		if(!closedOppIdSet.isEmpty())
		{
			AllocationHandler.doAllocation(closedOppIdSet);
		}
	}	
}