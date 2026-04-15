import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

import createPaymentrecord from '@salesforce/apex/PaymentController.createPaymentrecord';

export default class Initialpaymentscreen extends NavigationMixin(LightningElement) {
    @api recordId;
    refundreason = '';
    refundamount;

    handleNoteChange(event) {
        this.refundreason = event.target.value;
    }

   handleAmountChange(event) {
    const value = event.target.value;
    this.refundamount = value === '' || value === null ? null : parseFloat(value);
}


    handlecancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave() {
        const isValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, input) => {
                input.reportValidity();
                return validSoFar && input.checkValidity();
            }, true);

        if (!isValid) return;

        createPaymentrecord({
            parentPaymentId: this.recordId,
            refundreason: this.refundreason,
            refundamount: this.refundamount
        })
        .then(newPaymentId => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Payment created successfully',
                variant: 'success'
            }));

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: newPaymentId,
                    objectApiName: 'Payment__c',
                    actionName: 'view'
                }
            });
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error?.body?.message || error?.message || 'Unknown error',
                variant: 'error'
            }));
        });
    }
}