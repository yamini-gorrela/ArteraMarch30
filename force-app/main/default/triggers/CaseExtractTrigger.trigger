trigger CaseExtractTrigger on Case (before insert, before update) {
    if (Trigger.isBefore) {
        CaseExtractHandler.extractSixDigits(Trigger.new);
    }
}