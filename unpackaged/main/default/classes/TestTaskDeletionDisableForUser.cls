@isTest
private class TestTaskDeletionDisableForUser {

    static testMethod void myUnitTest() {
        Task t = new Task();
        t.OwnerId = '005b0000000cZOk';
        t.Subject = 'Test';
        t.Priority = 'Нормальный';
        t.Status = 'Не запущено';
        insert t;
        
        try
        {
            delete t;
        }
        catch(System.DMLException e)
        {
            System.assert(e.getMessage().contains('Недостаточно полномочий для удаления записи. Пожалуйста, обратитесь к администратору'));
        }
    }
}