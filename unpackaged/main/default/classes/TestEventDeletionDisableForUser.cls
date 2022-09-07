@isTest
private class TestEventDeletionDisableForUser {

    static testMethod void myUnitTest() {
        Event e = new Event();
        e.OwnerId = '005b0000000cZOk';
        e.Subject = 'Test';
        e.ActivityDateTime = System.now();
        e.DurationInMinutes = 15;
        insert e;
        
        try
        {
            delete e;
        }
        catch(System.DMLException ex)
        {
            System.assert(ex.getMessage().contains('Недостаточно полномочий для удаления записи. Пожалуйста, обратитесь к администратору'));
        }
    }
}