trigger TaskDeletionDisableForUser on Task (before delete) {
    Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()];
    for(Task t: Trigger.old){
        if(ProfileName.Name!='Системный администратор'){
            t.addError('Недостаточно полномочий для удаления записи. Пожалуйста, обратитесь к администратору');
        }
    }
}