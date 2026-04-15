public virtual class MiddlewareSchema {
    Public Class AuthenticationBody{
        Public String ehr_username;
        Public String ehr_password;
        Public String ehr_accountId;
        Public String ehr_channel;
        Public String ehr_clientId;
        Public String ehr_clientSecret;
    }

    Public Class AuthResponse{
        Public String access_token;
    }

	public class Claim{
		public ClaimWithFile claim;
	}
    
    public class ClaimWithFile{
        public String file;
		public ClaimForm body;
    }

    Public Class ClaimForm{
        public String claim_id;	//A123485
        public Date date_created;
        public String submitter_code;
		public Id sfid;
		public ClaimDates claim_dates;
		Public String medical_record_number;
		public String is_patient_condition_related_to_auto_state;
		public Patient patient;
		public Subscriber subscriber;
		public Boolean is_patient_condition_related_to_emp;	//YES
		public Boolean is_patient_condition_related_to_auto;	//NO
		public Boolean is_patient_condition_related_to_other;	//NO
		public Boolean insured_or_authorized_persons_sign;	//
		public String original_ref_number;	//
		public String prior_authorization;	//
		public Integer federal_tax_id_number;	//821687876
		public String accept_assignment;	//YES
		public Services[] services;
		public Provider billing_provider;
		public Provider service_provider;
		public Provider rendering_provider;
        public Provider referring_provider;
		public Payer payer;
    }

	Public Class  Payer {
		public String code;	//3/01/2022
		public String name;	//3/02/2022
		public String address_street;	//
		public String address_city;	//3/07/2022
		public String address_state;	//
		public String address_zip_code;	//
	}

    Public Class  ClaimDates {
		public Date first_symptoms;	//3/01/2022
		public Date accident;	//3/02/2022
		public Date last_seen_by_doctor;	//
		public Date first_treatment;	//3/07/2022
		public Date unable_to_work_from;	//
		public Date unable_to_work_to;	//
		public Date hospitalized_from;	//
		public Date hospitalized_to;	//
	}

	Public Class Patient {
		public String first_name;	//Meghan
		public String last_name;	//Leonhardt
		public Date birth_date;	//01/06/1962
		public String account;	//leo9113167
		public String sex;	//M
		public String address_street;	//66 Church st. northport
		public String address_city;	//New York
		public String address_state;	//NY
		public String address_zip_code;	//11768
		public String relationship_to_the_insured;	//OTHER
	}

	Public Class Subscriber {
		public String id_number;	//vqa449w01913
		public String policy_number;	//123456
		//public string casualty_number;
		public String claim_casualty_number ;
		public String payer_responsibility;	//P
		public String insurance_plan_type;	//BL
		public String insurance_program;	//Silver
		public String first_name;	//Meghan
		public String last_name;	//Keonhardt
		public String sex;	//F
		public Date birth_date;	//02/02/1961
		public String address_street;	//66 Church st. northport
		public String address_city;	//New York
		public String address_state;	//NY
		public String address_zip_code;	//11768
	}

	Public Class Services {
		public String service_id;	//1234
		public Date date_from_of_service;	//3/6/2022
		public Date date_to_of_service;	//3/7/2022
		public String place_of_service;	//11
		public String cptb_hcpcs;	//10010
        public String clia_id;
		public String modifiers;	//
		public String note;	//
		public List<String> diagnosis;
		public Decimal charges;	//225
		public String measure;	//UN
		public Decimal units;	//1
		public Provider rendering_provider;
	}

	Public Class Provider {
		public String type;	//PHYSICIAN
		public String name;	//XXXXX
		public String first_name;	//
		public String address_street;	//XX Columbus ave suite 
		public String address_city;	//New York
		public String address_state;	//NY
		public String address_zip_code;	//100247241
		public String phone;	//
		public String taxonomy_code;	//1024A0702X
		public String npi;	//1881928539
	}


	Public Class ClaimSubmissionResponse{
		Public List<String> processedClaimIds;
		Public String errrorMessage;

		Public ClaimSubmissionResponse(){
			processedClaimIds = new List<String>();
		}
	}
}