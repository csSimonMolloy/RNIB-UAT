public with sharing class RoleController {

    // the soql without the order and limit
    private String soql {get;set;}
    // the collection of contacts to display
    public List<Role_Opportunity__c> roles {get;set;}

  // the current field to sort by. defaults to last name
  public String sortField {
    get  { if (sortField == null) {sortField = 'location'; } return sortField;  }
    set;
  }

    // format the soql for display on the visualforce page
    public String debugSoql {
        get { return soql; }
        set;
    }

    // init the controller and display some sample data when the page loads
    public RoleController() {
        soql = 'select id, Active_on_Website__c, Availability__c, Capacity__c, DBS_Check_required__c, End_Date__c, Work_Location__c, Interests__c, Location__c, Role_Description__c, Role_Title__c, Service__c, Skills__c, Start_Date__c, Waiting_List__c, Role_Type__c from Role_Opportunity__c where Role_Title__c != null AND Active_on_Website__c= true ORDER BY CreatedDate DESC';
        runQuery();
    }

    // runs the actual query
    public void runQuery() {

        try {
            roles = Database.query(soql);
            } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unfortunately there is an error please try back later'));
        }
    }

    // runs the search with parameters passed via Javascript
    public PageReference runSearch() {

        String location = Apexpages.currentPage().getParameters().get('location');
        system.debug('*** -- location = ' + location + ' -- ***');
        String skills = Apexpages.currentPage().getParameters().get('skills');
        String availability = Apexpages.currentPage().getParameters().get('availability');
        system.debug('*** -- availability = ' + availability + ' -- ***');
        String home = apexpages.currentpage().getParameters().get('home');
        String interests = apexpages.currentpage().getParameters().get('interests');
        system.debug('*** -- interests = ' + interests + ' -- ***');
        String service = apexpages.currentpage().getParameters().get('service');
        String worklocation = apexpages.currentpage().getParameters().get('worklocation');

        soql = 'select id, Active_on_Website__c, Availability__c, Capacity__c, DBS_Check_required__c, End_Date__c, Work_Location__c, Interests__c, Location__c, Role_Description__c, Role_Title__c, Service__c, Skills__c, Start_Date__c, Waiting_List__c, Role_Type__c from Role_Opportunity__c where Role_Title__c != null AND Active_on_Website__c= true';
        if (!location.equals('')){
        	soql += ' and Location__c includes (';
        	String[] valSplit = location.split(',');
        	for (String s : valSplit){
        		soql += '\''+s+'\',';	
        	}
        	soql = soql.substring(0,soql.length()-1);
        	soql += ')';
        }
        //soql += ' and Location__c includes (\''+location+'\')';
        if (!availability.equals('')){
        	if ('FLEXIBLE'.equalsIgnoreCase(availability)){
        		//We don't need to filter on Availability if its Flexible
        	}else {
        		soql += ' and Availability__c includes (';
	        	String[] valSplit = availability.split(',');
	        	for (String s : valSplit){
	        		soql += '\''+s+'\',';	
	        	}
	        	soql = soql.substring(0,soql.length()-1);
	        	soql += ')';	
        	}
        	
        }
          
        if (!interests.equals('')){
        	soql += ' and Interests__c includes (';
        	String[] valSplit = interests.split(',');
        	for (String s : valSplit){
        		soql += '\''+s+'\',';	
        	}
        	soql = soql.substring(0,soql.length()-1);
        	soql += ')';
        }
        
        if (!worklocation.equals('')){
        	soql += ' and Work_Location__c LIKE \''+String.escapeSingleQuotes(worklocation)+'%\'';
        }
        
        soql += ' ORDER BY CreatedDate DESC';
        
		system.debug('*** -- soql = ' + soql + ' -- ***');
        // run the query again
        runQuery();

        return null;
    }

    // use apex describe to build the picklist values
    public List<String> locations {
        get {
            if (locations == null) {
                locations = new List<String>();
                Schema.DescribeFieldResult field = Role_Opportunity__c.Location__c.getDescribe();
                for (Schema.PicklistEntry f : field.getPicklistValues())
                locations.add(f.getLabel());
            }
            return locations;          
        }
        set;
    }
    
    // use apex describe to build the picklist values
    public List<String> skills {
        get {
            if (skills == null) {
                skills = new List<String>();
                Schema.DescribeFieldResult field = Role_Opportunity__c.skills__c.getDescribe();
                for (Schema.PicklistEntry f : field.getPicklistValues())
                skills.add(f.getLabel());
            }
            return skills;          
        }
        set;
    }

    // use apex describe to build the picklist values
    public List<String> availability {
        get {
            if (availability == null) {
                availability = new List<String>();
                Schema.DescribeFieldResult field = Role_Opportunity__c.Availability__c.getDescribe();
                for (Schema.PicklistEntry f : field.getPicklistValues())
                availability.add(f.getLabel());
            }
            return availability;          
        }
        set;
    }

    // use apex describe to build the picklist values
    public List<String> interests {
        get {
            if (interests == null) {
                interests = new List<String>();
                Schema.DescribeFieldResult field = Role_Opportunity__c.interests__c.getDescribe();
                for (Schema.PicklistEntry f : field.getPicklistValues())
                interests.add(f.getLabel());
            }
            return interests;          
        }
        set;
    }

    // use apex describe to build the picklist values
    public List<String> service {
        get {
            if (service == null) {
                service = new List<String>();
                Schema.DescribeFieldResult field = Role_Opportunity__c.service__c.getDescribe();
                for (Schema.PicklistEntry f : field.getPicklistValues())
                service.add(f.getLabel());
            }
            return service;          
        }
        set;
    }

    // use apex describe to build the picklist values
    public List<String> worklocation {
        get {
            if (worklocation == null) {
                worklocation = new List<String>();
                Schema.DescribeFieldResult field = Role_Opportunity__c.Work_Location__c.getDescribe();
                for (Schema.PicklistEntry f : field.getPicklistValues())
                worklocation.add(f.getLabel());
            }
            return worklocation;          
        }
        set;
    }

}