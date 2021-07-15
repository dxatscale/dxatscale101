@isTest
public class TestPropertyController {
    private final static String MOCK_PICTURE_NAME = 'MockPictureName';
    @TestSetup
    static void makeData(){

        User sysAdminUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator'].Id,
            LastName = 'lastname',
            Email = 'testSysAdUser@test.com',
            Username = 'testSysAdUser@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Australia/Sydney',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_AU'
        );     	

        insert sysAdminUser;

        List<PermissionSet> permSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'dreamhouse'];
        if(!permSet.isEmpty()){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = permSet[0].Id;
            psa.AssigneeId = sysAdminUser.Id;

            insert psa;
        }

    }
    public static void createProperties(Integer amount) {
        List<Property__c> properties = new List<Property__c>();
        for (Integer i = 0; i < amount; i++) {
            properties.add(
                new Property__c(
                    Title__c = 'Name ' + i,
                    Price__c = 20000,
                    Beds__c = 3,
                    Baths__c = 3
                )
            );
        }
        insert properties;
    }
    static testMethod void testGetPropertyList() {
        User sysAdminUser = [SELECT Id FROM User WHERE Email = 'testSysAdUser@test.com' LIMIT 1];
		system.runAs(sysAdminUser) { 
        TestPropertyController.createProperties(5);
        Test.startTest();
        Property__c[] properties = PropertyController.getPropertyList(
            '',
            999999,
            0,
            0
        );
        Test.stopTest();
        System.assertEquals(5, properties.size());
        }
    }
    static testMethod void testGetPagedPropertyList() {
        User sysAdminUser = [SELECT Id FROM User WHERE Email = 'testSysAdUser@test.com' LIMIT 1];
		system.runAs(sysAdminUser) { 
        TestPropertyController.createProperties(5);
        Test.startTest();
        PagedResult result = PropertyController.getPagedPropertyList(
            '',
            999999,
            0,
            0,
            10,
            1
        );
        Test.stopTest();
        System.assertEquals(5, result.records.size());
        }
    }

    static testMethod void testGetPicturesNoResults() {
        User sysAdminUser = [SELECT Id FROM User WHERE Email = 'testSysAdUser@test.com' LIMIT 1];
		system.runAs(sysAdminUser) { 
        Property__c property = new Property__c(Name = 'Name');
        insert property;

        Test.startTest();
        List<ContentVersion> items = PropertyController.getPictures(
            property.Id
        );
        Test.stopTest();

        System.assertEquals(null, items);
        }
    }

    static testMethod void testGetPicturesWithResults() {
        User sysAdminUser = [SELECT Id FROM User WHERE Email = 'testSysAdUser@test.com' LIMIT 1];
		system.runAs(sysAdminUser) { 
        Property__c property = new Property__c(Name = 'Name');
        insert property;

        // Insert mock picture
        ContentVersion picture = new Contentversion();
        picture.Title = MOCK_PICTURE_NAME;
        picture.PathOnClient = 'picture.png';
        picture.Versiondata = EncodingUtil.base64Decode('MockValue');
        insert picture;

        // Link picture to property record
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument
            LIMIT 1
        ];
        ContentDocumentLink link = new ContentDocumentLink();
        link.LinkedEntityId = property.Id;
        link.ContentDocumentId = documents[0].Id;
        link.shareType = 'V';
        insert link;

        Test.startTest();
        List<ContentVersion> items = PropertyController.getPictures(
            property.Id
        );
        Test.stopTest();

        System.assertEquals(1, items.size());
        System.assertEquals(MOCK_PICTURE_NAME, items[0].Title);
        }
    }
}