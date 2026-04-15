public class ValidationSchema {

	public class Payment {
		public String type {get;set;} 
		public String qty {get;set;} 
		public String amount_type {get;set;} 
		public String amount {get;set;} 

        public Payment(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'qty') {
							qty = parser.getText();
						} else if (text == 'amount_type') {
							amount_type = parser.getText();
						} else if (text == 'amount') {
							amount = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Payment consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String name {get;set;} 
	public List<Data> data {get;set;} 
	
	public ValidationSchema(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'name') {
						name = parser.getText();
					} else if (text == 'data') {
						data = arrayOfData(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'ValidationSchema consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Details {
		public String category_code {get;set;} 
		public String status_code {get;set;} 
		public String date_Z {get;set;} // in json: date
		public String amount {get;set;} 
		public String note {get;set;} 

		public Details(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'category_code') {
							category_code = parser.getText();
						} else if (text == 'status_code') {
							status_code = parser.getText();
						} else if (text == 'date') {
							date_Z = parser.getText();
						} else if (text == 'amount') {
							amount = parser.getText();
						} else if (text == 'note') {
							note = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Details consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Data {
		public String file {get;set;} 
		public String claim_id {get;set;} 
		public Message message {get;set;} 
		public String uniqueReference {get;set;} 
		
		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'file') {
							file = parser.getText();
						} else if (text == 'claim_id') {
							claim_id = parser.getText();
						} else if (text == 'message') {
							message = new Message(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*public class Data_Z {
		public String file {get;set;} 
		public String claim_id {get;set;} 
		public Message_Z message {get;set;} 

		public Data_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'file') {
							file = parser.getText();
						} else if (text == 'claim_id') {
							claim_id = parser.getText();
						} else if (text == 'message') {
							message = new Message_Z(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Data_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}*/
	
	public class Message {
		public String status {get;set;} 
		public List<Items> items {get;set;}

		public Message(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'status') {
							status = parser.getText();
						} else if (text == 'items') {
							items = arrayOfItems(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Message_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	/*public class Message_Z {
		public String status {get;set;} 
		public List<Items> items {get;set;} 

		public Message_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'status') {
							status = parser.getText();
						} else if (text == 'items') {
							items = arrayOfItems(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Message_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}*/
	
	public class References {
		public String type {get;set;} 
		public String number_Z {get;set;} // in json: number

		public References(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'number') {
							number_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'References_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*public class References {

		public References(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'References consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}*/
	
	
	
	public class Items {
		public String name {get;set;} 
		public String first_name {get;set;} 
		public String identification_code {get;set;} 
		public String entity {get;set;} 
		public String type {get;set;} 
		public String code_qualifier {get;set;} 
		public String trace_number {get;set;} 
		public List<References> references {get;set;} 
		public List<Details> details {get;set;} 
		public Payment payment {get;set;} 
		public String service_date_from {get;set;} 
		public String service_date_to {get;set;} 

		public Items(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'first_name') {
							first_name = parser.getText();
						} else if (text == 'identification_code') {
							identification_code = parser.getText();
						} else if (text == 'entity') {
							entity = parser.getText();
						} else if (text == 'type') {
							type = parser.getText();
						} else if (text == 'code_qualifier') {
							code_qualifier = parser.getText();
						} else if (text == 'trace_number') {
							trace_number = parser.getText();
						} else if (text == 'references') {
							references = arrayOfReferences(parser);
						} else if (text == 'details') {
							details = arrayOfDetails(parser);
						} else if (text == 'payment') {
							payment = new Payment(parser);
						} else if (text == 'service_date_from') {
							service_date_from = parser.getText();
						} else if (text == 'service_date_to') {
							service_date_to = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Items consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	
	
	public static List<ValidationSchema> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfValidationSchema(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<Details> arrayOfDetails(System.JSONParser p) {
        List<Details> res = new List<Details>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Details(p));
        }
        return res;
    }








    private static List<Data> arrayOfData(System.JSONParser p) {
        List<Data> res = new List<Data>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Data(p));
        }
        return res;
    }


    private static List<References> arrayOfReferences(System.JSONParser p) {
        List<References> res = new List<References>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new References(p));
        }
        return res;
    }





    /*private static List<References_Z> arrayOfReferences_Z(System.JSONParser p) {
        List<References_Z> res = new List<References_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new References_Z(p));
        }
        return res;
    }*/




    /*private static List<Data_Z> arrayOfData_Z(System.JSONParser p) {
        List<Data_Z> res = new List<Data_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Data_Z(p));
        }
        return res;
    }*/



    private static List<ValidationSchema> arrayOfValidationSchema(System.JSONParser p) {
        List<ValidationSchema> res = new List<ValidationSchema>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ValidationSchema(p));
        }
        return res;
    }




    private static List<Items> arrayOfItems(System.JSONParser p) {
        List<Items> res = new List<Items>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Items(p));
        }
        return res;
    }
}