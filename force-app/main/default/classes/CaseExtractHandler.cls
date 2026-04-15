public class CaseExtractHandler {
    public static void extractSixDigits(List<Case> caseList) {
        if (caseList == null || caseList.isEmpty()) return;

        // Existing: first 6-digit sequence anywhere in Subject
        Pattern sixDigitPattern = Pattern.compile('\\d{6}');

        // New: match subjects like:
        // A fax has arrived from: '(940) 218-1207'
        // Captures what's inside the single quotes after the prefix.
        Pattern faxSubjectPattern = Pattern.compile(
            '^A fax has arrived from:\\s*\\\'([^\\\']+)\\\'$'
        );

        for (Case c : caseList) {
            if (c.Subject == null) {
                c.Extrac__c = null;
                c.Extracted_Fax__c = null;
                continue;
            }

            // --- Existing 6-digit extraction ---
            Matcher m6 = sixDigitPattern.matcher(c.Subject);
            c.Extrac__c = m6.find() ? m6.group(0) : null;

            // --- New fax extraction ---
            Matcher mf = faxSubjectPattern.matcher(c.Subject);
            if (mf.find()) {
                String rawFax = mf.group(1);                 // e.g. (940) 218-1207
                String digitsOnly = rawFax.replaceAll('\\D', ''); // -> 9402181207
                c.Extracted_Fax__c = digitsOnly;
            } else {
                c.Extracted_Fax__c = null;
            }
        }
    }
}