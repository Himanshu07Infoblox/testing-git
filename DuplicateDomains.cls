Public class DuplicateDomains {

    public class DomainWrapper {
        @InvocableVariable(label='Contact Email Domain' description='The domain name to check for duplicates')
        public String contactEmailDomain;

        @InvocableVariable(label='Account Id' description='Id of the Account to check for duplicate domains')
        public Id accountId;

        @InvocableVariable(label='Account Domain' description='The domain associated with the Account')
        public String accountDomain;
    }

    public class ResultWrapper {
        @InvocableVariable(label='Is Duplicate' description='Indicates whether the domain is a duplicate')
        public Boolean isDuplicate;
    }

    @InvocableMethod(label='Check Duplicate Domain' description='Checks for duplicate domains under the same account and creates records for unique domains.')
    public static List<ResultWrapper> checkDuplicateDomain(List<DomainWrapper> domainWrappers) {
        List<ResultWrapper> results = new List<ResultWrapper>();
        Set<String> uniqueDomains = new Set<String>();

        for (DomainWrapper domainWrapper : domainWrappers) {
            ResultWrapper result = new ResultWrapper();

            // Ensure contactEmailDomain and accountId are not null
            if (domainWrapper.contactEmailDomain != null && domainWrapper.accountId != null) {
                String key = domainWrapper.accountId + '-' + domainWrapper.contactEmailDomain;

                // Check if the domain has already been processed
                if (!uniqueDomains.contains(key)) {
                    // Check for duplicate domains using a single query
                    Boolean isDuplicate = [SELECT count() FROM Related_Domain__c WHERE Account__c = :domainWrapper.accountId AND Name = :domainWrapper.contactEmailDomain] > 0;

                    // Compare AccountDomain and ContactEmailDomain
                    if (!isDuplicate && !domainWrapper.accountDomain.equals(domainWrapper.contactEmailDomain)) {
                        // Create a new record with ContactEmailDomain under the Account
                        Related_Domain__c newDomain = new Related_Domain__c();
                        newDomain.Account__c = domainWrapper.accountId;
                        newDomain.Name = domainWrapper.contactEmailDomain;
                        insert newDomain;

                        // Set isDuplicate to false since we created a new record
                        isDuplicate = false;
                    }

                    uniqueDomains.add(key);
                    result.isDuplicate = isDuplicate;
                    results.add(result);
                } else {
                    // The domain has already been processed, consider it a duplicate
                    result.isDuplicate = true;
                    results.add(result);
                }
            } else {
                // Handle null values
                result.isDuplicate = false;
                results.add(result);
            }
        }

        return results;
    }
}