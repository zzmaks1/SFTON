global class CallTaskGenerationScheduledDaily implements Schedulable {
    public static String CRON_EXP = '0 10 0 * * ?';

    /**
    * Static method used to schedule the default reconciliation
    *
    * @return The jobId from the scheduled run
    */
    global static String scheduleIt() {
        return scheduleIt('Daily Task Generation Based On Auction Ending');
    }

    global static String scheduleIt(String taskName) {
        return System.schedule(taskName, 
                                CRON_EXP, 
                                new CallTaskGenerationScheduledDaily());
    }

    global void execute(SchedulableContext sc) {
        
        List<Opportunity> oppsWithAuctionsToday = [select id, ownerID from opportunity where 
                                                                            AuctionDateDesign__c =: Date.today() or
                                                                            AuctionDateMounting__c =: Date.today()];

        for(Opportunity opp:oppsWithAuctionsToday) {
            Task t = new Task(OwnerId = opp.ownerID,
                                Subject = 'Конкурс состоялся. Позвонить победителю',
                                Type = 'Телефонный звонок исходящий',
                                ActivityDate = Date.today().addDays(7),
                                Description = ' ',
                                WhatId = opp.id,
                                Status = 'Не запущено',
                                Priority = 'Нормальный');
            insert t;
        }
    }
}