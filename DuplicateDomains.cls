/*
 * Version: 1.0
 * Date: 2024-01-18
 * Owner Name: Himanshu Kumar Tiwary
 * Story No: HD-2201 
 * Description: This Apex class checks for duplicate domains under the same account 
 * and creates records for unique domains. It receives a list of DomainWrapper objects 
 * containing information about the contact email domain, account ID, and account domain. 
 * It returns a list of ResultWrapper objects indicating whether each domain is a duplicate.
 * 
 * Used In The Flow "CreateRelatedDomain"
 */

 public without sharing class DuplicateDomains {

// Inner class to represent input domain information
public class DomainWrapper {
    @InvocableVariable(label='Contact Email Domain' description='The domain name to check for duplicates')
    public String contactEmailDomain;

    @InvocableVariable(label='Account Id' description='Id of the Account to check for duplicate domains')
    public Id accountId;

    @InvocableVariable(label='Account Domain' description='The domain associated with the Account')
    public String accountDomain;
}

// Inner class to represent the result of domain duplication check
public class ResultWrapper {
    @InvocableVariable(label='Is Duplicate' description='Indicates whether the domain is a duplicate')
    public Boolean isDuplicate;
}

// Invocable method to check for duplicate domains
@InvocableMethod(label='Check Duplicate Domain' description='Checks for duplicate domains under the same account and creates records for unique domains.')
public static List<ResultWrapper> checkDuplicateDomain(List<DomainWrapper> domainWrappers) {
    List<ResultWrapper> results = new List<ResultWrapper>();
    Set<String> uniqueDomains = new Set<String>();
    List<Related_Domain__c> domainsToInsert = new List<Related_Domain__c>(); // Accumulate records to be inserted

    // Iterate over each domain wrapper object
    for (DomainWrapper domainWrapper : domainWrappers) {
        ResultWrapper result = new ResultWrapper();

        // Ensure contactEmailDomain and accountId are not null before performing the duplicate check
        if (domainWrapper.contactEmailDomain != null && domainWrapper.accountId != null) {
            String key = domainWrapper.accountId + '-' + domainWrapper.contactEmailDomain;

            // Check if the domain has already been processed
            if (!uniqueDomains.contains(key)) {
                // Check for duplicate domains using a single query
                Boolean isDuplicate = [SELECT count() FROM Related_Domain__c WHERE Account__c = :domainWrapper.accountId AND Name = :domainWrapper.contactEmailDomain] > 0;

                // Compare AccountDomain and ContactEmailDomain
                if (!isDuplicate && !domainWrapper.accountDomain.equals(domainWrapper.contactEmailDomain)) {
                    // Accumulate record to be inserted
                    Related_Domain__c newDomain = new Related_Domain__c();
                    newDomain.Account__c = domainWrapper.accountId;
                    newDomain.Name = domainWrapper.contactEmailDomain;
                    domainsToInsert.add(newDomain);

                    // Set isDuplicate to false since we just created a new record
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
            // Handle null values if needed
            result.isDuplicate = false;
            results.add(result);
        }
    }

    // Perform DML outside the loop
    insert domainsToInsert;

    return results;
}
}
