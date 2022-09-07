trigger EventDeletionDisableForUser on Event (before delete) {
    Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()];
    for(Event e: Trigger.old){
        if(ProfileName.Name!='Системный администратор'){
            e.addError('Недостаточно полномочий для удаления записи. Пожалуйста, обратитесь к администратору');
        }
    }
}