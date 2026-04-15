@isTest
private class ValidationSchemaTest {
    
    @isTest
    static void testParseValidJson() {
        // Comprehensive JSON with all fields
        String jsonString = '[' +
            '{' +
            '  "name": "TestSchema",' +
            '  "data": [' +
            '    {' +
            '      "file": "file1.txt",' +
            '      "claim_id": "CLM001",' +
            '      "uniqueReference": "REF001",' +
            '      "message": {' +
            '        "status": "Processed",' +
            '        "items": [' +
            '          {' +
            '            "name": "Item1",' +
            '            "first_name": "John",' +
            '            "identification_code": "ID123",' +
            '            "entity": "Patient",' +
            '            "type": "Claim",' +
            '            "code_qualifier": "CQ1",' +
            '            "trace_number": "TN001",' +
            '            "service_date_from": "2023-10-01",' +
            '            "service_date_to": "2023-10-02",' +
            '            "references": [' +
            '              {"type": "RefType1", "number": "Ref001"},' +
            '              {"type": "RefType2", "number": "Ref002"}' +
            '            ],' +
            '            "details": [' +
            '              {"category_code": "CAT01", "status_code": "ST01", "date": "2023-10-01", "amount": "100.00", "note": "Note1"},' +
            '              {"category_code": "CAT02", "status_code": "ST02", "date": "2023-10-02", "amount": "200.00", "note": "Note2"}' +
            '            ],' +
            '            "payment": {' +
            '              "type": "PaymentType1",' +
            '              "qty": "2",' +
            '              "amount_type": "Fixed",' +
            '              "amount": "200.00"' +
            '            }' +
            '          },' +
            '          {' +
            '            "name": "Item2",' +
            '            "first_name": "Jane",' +
            '            "identification_code": "ID124",' +
            '            "entity": "Provider",' +
            '            "type": "Service",' +
            '            "code_qualifier": "CQ2",' +
            '            "trace_number": "TN002",' +
            '            "service_date_from": "2023-10-03",' +
            '            "service_date_to": "2023-10-04",' +
            '            "references": [],' +
            '            "details": [],' +
            '            "payment": null' +
            '          }' +
            '        ]' +
            '      }' +
            '    }' +
            '  ]' +
            '}' +
            ']';

        Test.startTest();
        List<ValidationSchema> schemas = ValidationSchema.parse(jsonString);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, schemas, 'Parsed schemas should not be null');
        System.assertEquals(1, schemas.size(), 'Expected one schema');
        
        ValidationSchema schema = schemas[0];
        System.assertEquals('TestSchema', schema.name, 'Schema name should match');
        System.assertNotEquals(null, schema.data, 'Data should not be null');
        System.assertEquals(1, schema.data.size(), 'Expected one data entry');

        ValidationSchema.Data data = schema.data[0];
        System.assertEquals('file1.txt', data.file, 'Data file should match');
        System.assertEquals('CLM001', data.claim_id, 'Data claim_id should match');
        
        ValidationSchema.Message message = data.message;
        System.assertNotEquals(null, message, 'Message should not be null');
        System.assertEquals('Processed', message.status, 'Message status should match');
        System.assertEquals(2, message.items.size(), 'Expected two items');

        // First Item
        ValidationSchema.Items item1 = message.items[0];
        System.assertEquals('Item1', item1.name, 'Item1 name should match');
        System.assertEquals('John', item1.first_name, 'Item1 first_name should match');
        System.assertEquals('ID123', item1.identification_code, 'Item1 identification_code should match');
        System.assertEquals('Patient', item1.entity, 'Item1 entity should match');
        System.assertEquals('Claim', item1.type, 'Item1 type should match');
        System.assertEquals('CQ1', item1.code_qualifier, 'Item1 code_qualifier should match');
        System.assertEquals('TN001', item1.trace_number, 'Item1 trace_number should match');
        System.assertEquals('2023-10-01', item1.service_date_from, 'Item1 service_date_from should match');
        System.assertEquals('2023-10-02', item1.service_date_to, 'Item1 service_date_to should match');

        System.assertEquals(2, item1.references.size(), 'Expected two references');
        ValidationSchema.References ref1 = item1.references[0];
        System.assertEquals('RefType1', ref1.type, 'Reference1 type should match');
        System.assertEquals('Ref001', ref1.number_Z, 'Reference1 number should match');
        ValidationSchema.References ref2 = item1.references[1];
        System.assertEquals('RefType2', ref2.type, 'Reference2 type should match');
        System.assertEquals('Ref002', ref2.number_Z, 'Reference2 number should match');

        System.assertEquals(2, item1.details.size(), 'Expected two details');
        ValidationSchema.Details detail1 = item1.details[0];
        System.assertEquals('CAT01', detail1.category_code, 'Detail1 category_code should match');
        System.assertEquals('ST01', detail1.status_code, 'Detail1 status_code should match');
        System.assertEquals('2023-10-01', detail1.date_Z, 'Detail1 date should match');
        System.assertEquals('100.00', detail1.amount, 'Detail1 amount should match');
        System.assertEquals('Note1', detail1.note, 'Detail1 note should match');

        ValidationSchema.Payment payment1 = item1.payment;
        System.assertNotEquals(null, payment1, 'Payment1 should not be null');
        System.assertEquals('PaymentType1', payment1.type, 'Payment1 type should match');
        System.assertEquals('2', payment1.qty, 'Payment1 qty should match');
        System.assertEquals('Fixed', payment1.amount_type, 'Payment1 amount_type should match');
        System.assertEquals('200.00', payment1.amount, 'Payment1 amount should match');

        // Second Item
        ValidationSchema.Items item2 = message.items[1];
        System.assertEquals('Item2', item2.name, 'Item2 name should match');
        System.assertEquals(0, item2.references.size(), 'Item2 references should be empty');
        System.assertEquals(0, item2.details.size(), 'Item2 details should be empty');
        System.assertEquals(null, item2.payment, 'Item2 payment should be null');
    }

    @isTest
    static void testParseNullValues() {
        String jsonString = '[' +
            '{' +
            '  "name": null,' +
            '  "data": [' +
            '    {' +
            '      "file": null,' +
            '      "claim_id": null,' +
            '      "uniqueReference": null,' +
            '      "message": {' +
            '        "status": null,' +
            '        "items": [' +
            '          {' +
            '            "name": null,' +
            '            "first_name": null,' +
            '            "identification_code": null,' +
            '            "entity": null,' +
            '            "type": null,' +
            '            "code_qualifier": null,' +
            '            "trace_number": null,' +
            '            "service_date_from": null,' +
            '            "service_date_to": null,' +
            '            "references": [],' +
            '            "details": [],' +
            '            "payment": null' +
            '          }' +
            '        ]' +
            '      }' +
            '    }' +
            '  ]' +
            '}' +
            ']';

        Test.startTest();
        List<ValidationSchema> schemas = ValidationSchema.parse(jsonString);
        Test.stopTest();

        System.assertNotEquals(null, schemas, 'Parsed schemas should not be null');
        System.assertEquals(1, schemas.size(), 'Expected one schema');

        ValidationSchema schema = schemas[0];
        System.assertEquals(null, schema.name, 'Schema name should be null');
        System.assertEquals(1, schema.data.size(), 'Expected one data entry');

        ValidationSchema.Data data = schema.data[0];
        System.assertEquals(null, data.file, 'Data file should be null');
        System.assertEquals(null, data.claim_id, 'Data claim_id should be null');
        System.assertEquals(null, data.uniqueReference, 'Data uniqueReference should be null');

        ValidationSchema.Message message = data.message;
        System.assertEquals(null, message.status, 'Message status should be null');
        System.assertEquals(1, message.items.size(), 'Expected one item');

        ValidationSchema.Items item = message.items[0];
        System.assertEquals(null, item.name, 'Item name should be null');
        System.assertEquals(null, item.first_name, 'Item first_name should be null');
        System.assertEquals(null, item.identification_code, 'Item identification_code should be null');
        System.assertEquals(null, item.entity, 'Item entity should be null');
        System.assertEquals(null, item.type, 'Item type should be null');
        System.assertEquals(null, item.code_qualifier, 'Item code_qualifier should be null');
        System.assertEquals(null, item.trace_number, 'Item trace_number should be null');
        System.assertEquals(null, item.service_date_from, 'Item service_date_from should be null');
        System.assertEquals(null, item.service_date_to, 'Item service_date_to should be null');
        System.assertEquals(0, item.references.size(), 'Expected empty references');
        System.assertEquals(0, item.details.size(), 'Expected empty details');
        System.assertEquals(null, item.payment, 'Item payment should be null');
    }

    @isTest
    static void testParseEmptyArrays() {
        String jsonString = '[' +
            '{' +
            '  "name": "EmptySchema",' +
            '  "data": []' +
            '}' +
            ']';

        Test.startTest();
        List<ValidationSchema> schemas = ValidationSchema.parse(jsonString);
        Test.stopTest();

        System.assertNotEquals(null, schemas, 'Parsed schemas should not be null');
        System.assertEquals(1, schemas.size(), 'Expected one schema');
        System.assertEquals('EmptySchema', schemas[0].name, 'Schema name should match');
        System.assertEquals(0, schemas[0].data.size(), 'Expected empty data array');
    }

    @isTest
    static void testParseUnrecognizedProperties() {
        String jsonString = '[' +
            '{' +
            '  "name": "TestSchema",' +
            '  "unknown_field": "ignored",' +
            '  "data": [' +
            '    {' +
            '      "file": "file1.txt",' +
            '      "claim_id": "CLM001",' +
            '      "uniqueReference": "REF001",' +
            '      "unknown_field": "ignored",' +
            '      "message": {' +
            '        "status": "Processed",' +
            '        "unknown_field": "ignored",' +
            '        "items": [' +
            '          {' +
            '            "name": "Item1",' +
            '            "first_name": null,' +
            '            "identification_code": null,' +
            '            "entity": null,' +
            '            "type": null,' +
            '            "code_qualifier": null,' +
            '            "trace_number": null,' +
            '            "service_date_from": null,' +
            '            "service_date_to": null,' +
            '            "unknown_field": "ignored",' +
            '            "references": [ { "type": null, "number": null, "unknown_field": "ignored" } ],' +
            '            "details": [ { "category_code": null, "status_code": null, "date": null, ' +
            '                           "amount": null, "note": null, "unknown_field": "ignored" } ],' +
            '            "payment": { "type": null, "qty": null, "amount_type": null, "amount": null, ' +
            '                         "unknown_field": "ignored" }' +
            '          }' +
            '        ]' +
            '      }' +
            '    }' +
            '  ]' +
            '}' +
            ']';

        Test.startTest();
        List<ValidationSchema> schemas = ValidationSchema.parse(jsonString);
        Test.stopTest();

        System.assertNotEquals(null, schemas, 'Parsed schemas should not be null');
        System.assertEquals(1, schemas.size(), 'Expected one schema');
        System.assertEquals('TestSchema', schemas[0].name, 'Schema name should match');

        ValidationSchema.Data data = schemas[0].data[0];
        System.assertEquals('file1.txt', data.file, 'Data file should match');
        System.assertEquals('CLM001', data.claim_id, 'Data claim_id should match');

        ValidationSchema.Message message = data.message;
        System.assertEquals('Processed', message.status, 'Message status should match');
        System.assertEquals(1, message.items.size(), 'Expected one item');

        ValidationSchema.Items item = message.items[0];
        System.assertEquals('Item1', item.name, 'Item name should match');
        System.assertEquals(1, item.references.size(), 'Expected one reference');
        System.assertEquals(1, item.details.size(), 'Expected one detail');
        System.assertNotEquals(null, item.payment, 'Payment should not be null');
    }

    @isTest
    static void testParseInvalidJson() {
        String jsonString = '{ invalid json }';

        Test.startTest();
        try {
            ValidationSchema.parse(jsonString);
            System.assert(false, 'Expected JSONException for invalid JSON');
        } catch (System.JSONException e) {
            System.assert(true, 'Caught expected JSONException');
        }
        Test.stopTest();
    }

    @isTest
    static void testConsumeObject() {
        String jsonString = '{ "unknown_object": { "nested": { "key": "value" }, "array": [1, 2, 3] } }';
        System.JSONParser parser = System.JSON.createParser(jsonString);
        parser.nextToken(); // START_OBJECT
        parser.nextToken(); // FIELD_NAME "unknown_object"
        parser.nextToken(); // START_OBJECT

        Test.startTest();
        ValidationSchema.consumeObject(parser);
        Test.stopTest();

        System.assertEquals(System.JSONToken.END_OBJECT, parser.getCurrentToken(), 'Should have consumed the entire object');
    }

    @isTest
    static void testMinimalJson() {
        String jsonString = '[{}]'; // Minimal valid JSON

        Test.startTest();
        List<ValidationSchema> schemas = ValidationSchema.parse(jsonString);
        Test.stopTest();

        System.assertNotEquals(null, schemas, 'Parsed schemas should not be null');
        System.assertEquals(1, schemas.size(), 'Expected one schema');
        System.assertEquals(null, schemas[0].name, 'Schema name should be null');
        System.assertEquals(null, schemas[0].data, 'Schema data should be null');
    }
}