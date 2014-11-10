global class ScheduledApplicationExpiry implements Schedulable {

	global void execute(SchedulableContext sc){
		ApplicationExpiry ae = new ApplicationExpiry();
	}
		


}