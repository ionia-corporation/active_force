class Whizbang < ActiveForce::SObject

  self.mappings = {
    id:                          'Id',
    salutation:                  'Salutation',
    first_name:                  'FirstName',
    last_name:                   'LastName',
    gender:                      'Gender__c',
    date_of_birth:               'PersonBirthdate',
    status:                      'Patient_Status__c',
    username:                    'User_Name__c',
    contact_phone:               'Phone',
    email:                       'Patient_Email__c',
    referral_source:             'Referral_Source__c',
    address:                     'HomeStreet__c',
    city:                        'HomeCity__c',
    state:                       'HomeState__c',
    zip_code:                    'HomePostalCode__c',
    occupation:                  'Ocupation__c',
    assigned_by:                 'Assigned_By__c',
    primary_care_physician:      'Primary_Care_Physician__c',
    referring_physician:         'Referring_Physician__c',
    emergency_contact:           'Emergency_Contact__c',
    questionnaire_completed?:    'HHQ_Questionnaire_Complete__c',
    employer:                    'Employer__c'
  }

  attribute :salutation
  attribute :first_name
  attribute :last_name
  attribute :gender
  attribute :date_of_birth
  attribute :status
  attribute :username
  attribute :contact_phone
  attribute :email
  attribute :referral_source
  attribute :address
  attribute :city
  attribute :state
  attribute :zip_code
  attribute :occupation
  attribute :assigned_by
  attribute :primary_care_physician
  attribute :referring_physician
  attribute :emergency_contact
  attribute :questionnaire_completed?
  attribute :employer
end
