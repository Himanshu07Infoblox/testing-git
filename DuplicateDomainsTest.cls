@isTest
public class DuplicateDomainsTest {

    @isTest
    static void testCheckDuplicateDomain_NoDuplicates() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
    
        // Create a test Domain record
        Related_Domain__c testDomain = new Related_Domain__c(Account__c = testAccount.Id, Name = 'testdomain.com');
        insert testDomain;

        // Create a test DomainWrapper
        DuplicateDomains.DomainWrapper testWrapper = new DuplicateDomains.DomainWrapper();
        testWrapper.accountId = testAccount.Id;
        testWrapper.accountDomain = 'testaccountdomain.com';
        testWrapper.contactEmailDomain = 'testcontactdomain.com';

        // Call the checkDuplicateDomain method
        DuplicateDomains.ResultWrapper[] results = DuplicateDomains.checkDuplicateDomain(new List<DuplicateDomains.DomainWrapper>{testWrapper});

        // Verify the result
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isDuplicate);
    }

    @isTest
    static void testCheckDuplicateDomain_WithDuplicates() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Domain record
        Related_Domain__c testDomain = new Related_Domain__c(Account__c = testAccount.Id, Name = 'testcontactdomain.com');
        insert testDomain;

        // Create a test DomainWrapper
        DuplicateDomains.DomainWrapper testWrapper = new DuplicateDomains.DomainWrapper();
        testWrapper.accountId = testAccount.Id;
        testWrapper.accountDomain = 'testaccountdomain.com';
        testWrapper.contactEmailDomain = 'testcontactdomain.com';

        // Call the checkDuplicateDomain method
        DuplicateDomains.ResultWrapper[] results = DuplicateDomains.checkDuplicateDomain(new List<DuplicateDomains.DomainWrapper>{testWrapper});

        // Verify the result
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].isDuplicate);
    }

    @isTest
    static void testCheckDuplicateDomain_CreateNewDomain() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test DomainWrapper
        DuplicateDomains.DomainWrapper testWrapper = new DuplicateDomains.DomainWrapper();
        testWrapper.accountId = testAccount.Id;
        testWrapper.accountDomain = 'testaccountdomain.com';
        testWrapper.contactEmailDomain = 'testcontactdomain.com';

        // Call the checkDuplicateDomain method
        DuplicateDomains.ResultWrapper[] results = DuplicateDomains.checkDuplicateDomain(new List<DuplicateDomains.DomainWrapper>{testWrapper});

        // Verify the result
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isDuplicate);

        // Verify that a new Domain record was created
        List<Related_Domain__c> newDomains = [SELECT Id FROM Related_Domain__c WHERE Account__c = :testAccount.Id AND Name = :testWrapper.contactEmailDomain];
        System.assertEquals(1, newDomains.size());
    }
}