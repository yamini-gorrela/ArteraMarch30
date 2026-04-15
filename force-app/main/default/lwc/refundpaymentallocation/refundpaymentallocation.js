import { LightningElement,api,wire,track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import paymentRecord from '@salesforce/apex/RefundpaymentAllocationController.getRecordDetails';
import createAppliedPayment from '@salesforce/apex/RefundpaymentAllocationController.createAppliedPayment';
import updateClaimlines from '@salesforce/apex/RefundpaymentAllocationController.updateClaimlines';
//import getClaimLinesData from '@salesforce/apex/RefundpaymentAllocationController.getClaimLinesData';

// import CreateJournalEntry from '@salesforce/apex/RefundpaymentAllocationController.CreateJournalEntry';
import modal from "@salesforce/resourceUrl/custommodalcss";
import { loadStyle } from "lightning/platformResourceLoader";

import { CloseActionScreenEvent } from 'lightning/actions';
import Name from '@salesforce/schema/Account.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import Category_FIELD from '@salesforce/schema/AcctSeed__Journal_Entry__c.Category__c';
import AcctSeed__Journal_Entry__c_OBJECT from '@salesforce/schema/AcctSeed__Journal_Entry__c';
import LightningAlert from 'lightning/alert';

export default class Refundpaymentallocation extends LightningElement {
    @wire(getObjectInfo, { objectApiName: AcctSeed__Journal_Entry__c_OBJECT })
    journalEntryInfo;

    @track categoryTypeOptions;

    @wire(getPicklistValues, {recordTypeId:'$journalEntryInfo.data.defaultRecordTypeId', fieldApiName: Category_FIELD })
    categoryTypeFieldInfo({ data, error }) {
        if (data) this.categoryTypeOptions = data.values;
    }

    @track showInsuranceInHeader = false; 
    @track showpatientInHeader = false; 
    @track showAmerigrpPayer = false; 
    @track showSelfpayPatient = false;
    @track showAttorneyType = false;  
    @track isBalanceZero = false; 
    @track AllocatedMap = new Map();
    @track BalanceMap = new Map();
    @track BalanceClaimMap = new Map();
    @track AmountMap = new Map();
    @track paymentAllocatedMap = new Map();
    @track paymentUnAllocatedMap = new Map();
    @track claimAllocatedAmount = 0; 
    @api glAccountId;
    @api recordId;
    @api paymentlist = [];
    @api balance ;
    @api unalloacte;
    @api amount ;
    @api payertype ;
    @api patienttype ;
    @api attorneytype ;
    @api payertypename ;
    @api patienttypename ;
    @api attorneytypename ;
    @api totalBalance ;
    @api totalcurrentpayment ;
    @api claimLinesList =[];
    @api PaymentName;
    @api searchVal = '';
    @api allocatepercentage;
    @api totalclaimAmount;
    @api BalanceTransferredTo;
    @track claimRowWarning;
    @track minusAmount;
    @track minusCurrentPayments;
    @track balanceMapvalue ;
    @track balanceCurrentPaymentValue;
    disabled = true;
    openWarningMsg = false;
    disableButton = false;
    payervalue = false;
    patientvalue = false;
    attorneyvalue = false;
    payername = false;
    patientname = false;
    attorneyname = false;
    selectedValue;
    glAccountId;
    additionalAmount = 0;
    openWarningAlloacte = false;
    openClaimSelected = false;
    @api allocationAmount;
    @api paymentamount;
    //BalanceTransferredTo = 'None';
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
     if (currentPageReference) {
         this.recordId = currentPageReference.state.recordId;
         console.log(this.recordId + ' is provided');
        }
    }

    // handlecategoryChange(event){
    //  this.selectedValue = event.target.value; 
    // }
    // handleSelectedLookup(event){
    //     this.glAccountId = event.detail;
    // }

    connectedCallback() {
        loadStyle(this, modal);
        const amount = 0;
        this.getRecordsDate();
        
   }
   @api checkPayerType;
   getRecordsDate(){
    paymentRecord({paymentId: this.recordId}).then(response=>{
        this.paymentlist = JSON.parse(JSON.stringify(response.paymentRecords));
        if(response.claimWrapclass){
            this.claimLinesList = JSON.parse(JSON.stringify(response.claimWrapclass));
            // Log the filtered claim lines to verify only related claim lines are returned
            console.log('Filtered claimLinesList based on Payment.Claim__c:', this.claimLinesList);
            for(let i in this.claimLinesList){
               
                this.AllocatedMap.set(i,this.claimLinesList[i]['Payments'])
                this.BalanceMap.set(i,this.claimLinesList[i]['Balance'])
                this.AmountMap.set(i,this.claimLinesList[i]['Amount'])
                if(this.claimLinesList[i]['Balance']==null || this.claimLinesList[i]['Balance']== undefined){
                    this.claimLinesList[i]['Balance'] = 0;
                }
                this.BalanceClaimMap.set(this.claimLinesList[i]['Id'],this.claimLinesList[i]['Balance'])
               // this.claimLinesList[i]['BalanceTransferredTo'] = 'None'

            }
        }
        for(let i in this.paymentlist){
            this.paymentAllocatedMap.set(i,this.paymentlist[i]['Allocation__c'])
            this.paymentUnAllocatedMap.set(i,this.paymentlist[i]['Unallocation__c'])
            console.log('paymentAllocatedMap--->',this.paymentAllocatedMap)
            console.log('paymentUnAllocatedMap---->',this.paymentUnAllocatedMap)
        }
        
        var payName;
        var payerTypeName;
        for(var i=0;i<this.paymentlist.length; i++){
            payName = this.paymentlist[i]['Name'];
            this.unalloacte = this.paymentlist[i]['Unallocation__c'];
            this.amount = this.paymentlist[i]['Amount__c'];
            this.allocationAmount = this.paymentlist[i]['Allocation__c'];
            this.payertype = this.paymentlist[i]['Payer__c'];
            if(this.payertype != null){
                payerTypeName = this.paymentlist[i]['Payer__r']['Name'];
               }
            this.patienttype = this.paymentlist[i]['Patient__c'];
            this.attorneytype = this.paymentlist[i]['Attorney__c'];
        }
        if(this.unalloacte > 0){
            this.isBalanceZero = true;
          
        }
        else{
            LightningAlert.open({
                message: 'Cannot Allocate using this Payment as the Balance is 0',
                theme: 'error', // a red theme intended for error states
                label: 'Warning!', // this is the header text
            });
            this.handleCancel();
        }
if(payerTypeName == 'Self Pay'){
    this.showSelfpayPatient = true;
}
if(payerTypeName == 'Attorney'){
    this.showAttorneyType = true;
}
if(payerTypeName == 'Self Pay'){
    this.showAmerigrpPayer = true;
}
        
        this.PaymentName = payName;
       if(this.patienttype!=null && payerTypeName == 'Self Pay'){
            this.checkPayerType = payerTypeName;
            this.payervalue = false;
            this.patientvalue = true;
            this.attorneyvalue = false;
            this.disableButton = true;
            this.showInsuranceInHeader = false;
            this.showpatientInHeader = true;
            this.payername = false;
            this.patientname = true;
            this.attorneyname = false;
        }else if(this.attorneytype!=null && payerTypeName == 'Attorney'){
            this.checkPayerType = payerTypeName;
            this.payervalue = false;
            this.patientvalue = false;
            this.attorneyvalue = true;
            this.disableButton = true;
            this.showInsuranceInHeader = false;
            this.showpatientInHeader = true;
            this.payername = false;
            this.patientname = false;
            this.attorneyname = true;
        }
        else if(this.payertype!=null && (payerTypeName != 'Self Pay' || payerTypeName != 'Attorney')){
            this.checkPayerType = 'Payer';
            this.payervalue = true;
            this.patientvalue = false;
            this.attorneyvalue = false;
            this.disableButton = true;
            this.showInsuranceInHeader = true;
            this.showpatientInHeader = false;
            this.payername = true;
            this.patientname = false;
            this.attorneyname = false;
        }
      
    })
   }

   handleCancel(){
    this.dispatchEvent(new CloseActionScreenEvent());
   }
    @track isLoaded = false;
    @track lstSelectedClaimLines ;
    @api updatePaymentlist = [];
    handleAllocate(event){
      this.updatePaymentlist = JSON.stringify(this.paymentlist);
      if(this.totalclaimAmount > this.unalloacte){
             this.openWarningAlloacte = true;
            }
         else{
            this.isLoaded = true;
            this.isdefault=true;
            var claimLineRecord =[];
            for(var i=0; i<this.claimLinesList.length;i++){
                if(this.claimLinesList[i]['IsChecked']== true){
                    claimLineRecord.push(this.claimLinesList[i]);
                }
            }
           this.lstSelectedClaimLines = JSON.stringify(claimLineRecord);
            if(claimLineRecord.length){
                updateClaimlines({lstSelectedClaimLines: this.lstSelectedClaimLines,updatePaymentList:this.updatePaymentlist})
                .then(result=>{
                 createAppliedPayment({listofRecords : JSON.stringify(claimLineRecord),paymentId: this.recordId, categoryType:this.selectedValue, glaccount:this.glAccountId, additionalAmount:this.additionalAmount})
                   .then(response=>{
                      const event = new ShowToastEvent({
                           title: 'Success',
                           message: 'Applied Payments created successfully',
                           variant: 'success',
                           mode: 'dismissable'
                       });
                       this.dispatchEvent(event);
                       this.dispatchEvent(new CloseActionScreenEvent());
                       this.isLoaded = false;
                   })
                   .error(error => {
       
                   });
                })
                .catch(error => {
                    });               
                
            }
         }
        
      
    }
    totalAdditionalAmount = 0;
    unChecked = false;
    // handleSelect(event){ 
    //     let rowData3 = Number(event.currentTarget.name);
    //     this.claimLinesList[rowData3].IsChecked = event.currentTarget.checked;
    //     var negativeBalance ; 
    //     console.log('claimlines---->',this.claimLinesList)
    //     if(this.payertype != null && this.checkPayerType == 'Payer'){
    //         var rowIndex = Number(event.target.name);
    //         var ClaimRecords =[];
    //         this.claimRowWarning = rowIndex;
    //         this.balanceMapvalue = this.BalanceMap.get(JSON.stringify(rowIndex));
    //         ClaimRecords = JSON.parse(JSON.stringify(this.claimLinesList));
    //         if(event.target.checked == true){
    //             if(ClaimRecords[rowIndex]['Balance'] == '' || ClaimRecords[rowIndex]['Balance'] == undefined ){
    //                 ClaimRecords[rowIndex]['Amount'] = '0.00';
    //             }else{
    //                 ClaimRecords[rowIndex]['Amount'] = ClaimRecords[rowIndex]['Balance'];
    //             }
            
    //         this.minusAmount = ClaimRecords[rowIndex]['Amount'];
    //         // if(/*ClaimRecords[rowIndex]['Amount'] != null && ClaimRecords[rowIndex]['Amount'] != '' &&*/ ClaimRecords[rowIndex]['AllowedAmount'] != null && ClaimRecords[rowIndex]['AllowedAmount'] != ''){
    //         //     ClaimRecords[rowIndex]['Balance'] = Math.max(0, (ClaimRecords[rowIndex]['AllowedAmount'] - ClaimRecords[rowIndex]['Payments'] - ClaimRecords[rowIndex]['Amount']).toFixed(2));
    //         //     negativeBalance = ClaimRecords[rowIndex]['Balance'];
    //         // }
    //         // else /*if(ClaimRecords[rowIndex]['Payments'] != null && ClaimRecords[rowIndex]['Payments'] != '')*/{
    //         //     if(ClaimRecords[rowIndex]['Amount'] != null && ClaimRecords[rowIndex]['Amount'] !=''){
    //         //     ClaimRecords[rowIndex]['Balance'] = (ClaimRecords[rowIndex]['TotalAmount']-ClaimRecords[rowIndex]['Payments'] - ClaimRecords[rowIndex]['Amount']).toFixed(2);
    //         //     }
    //         //     else{
    //         //         ClaimRecords[rowIndex]['Balance'] = (ClaimRecords[rowIndex]['TotalAmount']-ClaimRecords[rowIndex]['Payments']).toFixed(2);
    //         //        // ClaimRecords[rowIndex]['Amount'] = ClaimRecords[rowIndex]['Balance'];
    //         //         //ClaimRecords[rowIndex]['Balance'] ='0.00';
    //         //     }
    //         //     negativeBalance = ClaimRecords[rowIndex]['Balance'];
    //         //     console.log('balance 2----->',ClaimRecords[rowIndex]['Balance'] )
    //         // }
    //         // else{
    //         //     ClaimRecords[rowIndex]['Balance'] = ClaimRecords[rowIndex]['Amount'].toFixed(2);
    //         //     negativeBalance = ClaimRecords[rowIndex]['Balance'];
    //         // }
    //         }
    //         else if(event.target.checked == false){
    //             ClaimRecords[rowIndex]['Amount'] = null;
    //             ClaimRecords[rowIndex]['Balance'] = this.BalanceMap.get(JSON.stringify(rowIndex));

    //         }
    //         // if(negativeBalance < 0){
    //         //     LightningAlert.open({
    //         //         message : 'Balance becomes negative please check the balance.', 
    //         //         theme: 'warning',
    //         //         label: 'Warning!',
    //         //     }).then((result) => {
        
    //         //     });
    //         // }
    //         // if( event.target.checked == true && ClaimRecords[rowIndex]['Allocate'] ==  true && this.BalanceMap.get(JSON.stringify(rowIndex))==0){
    //         // this.openClaimSelected = true;
            
    //         // setTimeout(() => {
    //         // }, 500);
    //         // ClaimRecords[rowIndex]['Balance'] = this.BalanceMap.get(JSON.stringify(rowIndex));
    //         // }

    //         this.claimLinesList = ClaimRecords;
    //         var checkedClaimLineRecord =[];
    //         const balance = 0;
    //         const claimAmount = 0;
    //         var totalclaimAmount = 0;
    //         var sumOfClaimAmount = 0;
    //         var selectedTotalBalance = 0;
            
    //         for(var i=0; i<this.claimLinesList.length;i++){
    //             if(this.claimLinesList[i]['IsChecked'] == true && this.claimLinesList[i]['Amount'] != null && this.claimLinesList[i]['Amount'] != ''){
    //                 console.log('IsChecked:', this.claimLinesList[i]['IsChecked']);
    //                 console.log('Amount:', this.claimLinesList[i]['Amount']);
    //                 this.claimAmount = parseFloat(this.claimLinesList[i]['Amount']);
    //                 totalclaimAmount += this.claimAmount;
    //                 console.log('totalclaimAmount--',totalclaimAmount);
    //                 checkedClaimLineRecord.push(this.claimLinesList[i]);//JSON.parse(JSON.stringify(this.claimLinesList[i]))
    //                 this.balance = this.claimLinesList[i]['Balance'];
    //                 selectedTotalBalance += this.balance;
    //                 this.totalBalance = selectedTotalBalance;
    //             }
    //           }
    //         if(this.additionalAmount==0 && this.additionalAmount==null){
    //             this.totalAdditionalAmount = totalclaimAmount;
    //         }else{
    //             this.totalAdditionalAmount = totalclaimAmount + parseInt(this.additionalAmount);
    //         }
    //         for(var i=0;i<this.paymentlist.length; i++){
    //             this.paymentlist[i]['Allocation__c'] = checkedClaimLineRecord.length ? this.totalAdditionalAmount+this.allocationAmount : this.allocationAmount; 
    //             this.paymentlist[i]['Unallocation__c'] = parseFloat((this.paymentlist[i]['Amount__c'] - this.paymentlist[i]['Allocation__c']).toFixed(2));
    //             this.paymentlist[i]['Balance__c'] = 
    //             parseFloat(this.paymentlist[i]['Unallocation__c']).toFixed(2);
            
    //         }
            
        
    //         if(this.paymentlist[0]['Balance__c'] == 0){
    //             this.disabled = false;
    //             }
    //             else{
    //                 this.disabled = true; 
    //         }
    //        if(totalclaimAmount > this.unalloacte){
    //             this.openWarningMsg = true;
    //         }
    //     }else if(event.target.checked == true){
    //         this.disableButton = false;
    //         var ClaimRecords =[];
    //         var rowIndex = Number(event.target.name);
    //         ClaimRecords = JSON.parse(JSON.stringify(this.claimLinesList));
    //         ClaimRecords[rowIndex]['IsChecked'] = true;
    //         this.claimLinesList = ClaimRecords;
    //     }else if (event.target.checked == false) {
    //         var rowIndex = Number(event.target.name);
    //         var ClaimRecords = JSON.parse(JSON.stringify(this.claimLinesList));
        
    //         // Update the claim line's IsChecked and Amount
    //         ClaimRecords[rowIndex]['IsChecked'] = false;
    //         ClaimRecords[rowIndex]['Amount'] = null;
    //         ClaimRecords[rowIndex]['Balance'] = this.BalanceMap.get(JSON.stringify(rowIndex));
        
    //         // Update the selected claim lines count
    //         this.selectedClaimLines = ClaimRecords.filter(line => line.IsChecked).length;
        
    //         // Enable or disable the button based on the selected claim lines count
    //         this.disableButton = this.selectedClaimLines === 0;
        
    //         this.claimLinesList = ClaimRecords;
        
        
    //         if( this.minusAmount != undefined &&  this.minusAmount != null){
    //             this.paymentlist[0]['Allocation__c'] = (parseFloat(this.paymentlist[0]['Allocation__c']) - this.minusAmount).toFixed(2);
    //             this.paymentlist[0]['Unallocation__c'] = (parseFloat(this.paymentlist[0]['Unallocation__c']) + this.minusAmount).toFixed(2);
    //             this.paymentlist[0]['Balance__c'] = (parseFloat(this.paymentlist[0]['Balance__c']) + this.minusAmount).toFixed(2);
    //              }
    //     }
    //     let rowData = Number(event.currentTarget.name);
    //     this.claimLinesList[rowData].IsChecked = event.currentTarget.checked;
    // } 

    // handleSelectAll(event) {
    //     this.selectAllChecked = event.target.checked;
    //     this.disableButton = false;
    //     this.claimLinesList = this.claimLinesList.map(row => ({
    //         ...row,
    //         IsChecked: this.selectAllChecked
    //     }));
    //     for(let i in this.claimLinesList){
    //     if(!this.claimLinesList[i]['isSearch']){
    //         this.claimLinesList[i]['IsChecked'] = false ;

    //     }
    //     }
    
    //     if (!this.selectAllChecked) {
    //         this.disableButton = true;
    //         this.claimLinesList = this.claimLinesList.map((row, i) => ({
    //             ...row,
    //             Amount: null,
    //             Balance: this.BalanceMap.get(JSON.stringify(i)) || null
    //         }));
    //         for(var i=0;i<this.paymentlist.length; i++){
    //             this.paymentlist[i]['Allocation__c'] = this.paymentAllocatedMap.get(JSON.stringify(i));
    //             this.paymentlist[i]['Unallocation__c'] = this.paymentUnAllocatedMap.get(JSON.stringify(i));
    //             this.paymentlist[i]['Balance__c'] = this.paymentUnAllocatedMap.get(JSON.stringify(i));
    //             console.log('this.allocationAmount----->',this.paymentlist[i]['Allocation__c'])
    //             console.log(' this.unalloacte --->', this.paymentlist[i]['Unallocation__c'] )
    //         }
    //     }
    //     this.ClaimRecords = this.selectAllChecked
    //         ? JSON.parse(JSON.stringify(this.claimLinesList))
    //         : [];
           
    // }
    
    

    handleSelect2(rowIndex, ClaimRecords){ 
        ClaimRecords[rowIndex]['IsChecked'] = true;
        // if(ClaimRecords[rowIndex]['Allocate'] ==  true && this.BalanceMap.get(JSON.stringify(rowIndex))==0){
        //     this.openClaimSelected = true;
        //     setTimeout(() => {
        //         ClaimRecords[rowIndex]['IsChecked'] = false;
        //     }, 500);
        //     ClaimRecords[rowIndex]['Balance'] = this.BalanceMap.get(JSON.stringify(rowIndex));
        // }
        if(this.allocatepercentage!=null){
        ClaimRecords[rowIndex]['Amount'] = (ClaimRecords[rowIndex]['Amount']*this.allocatepercentage);
        }
        

        this.claimLinesList = ClaimRecords;
        var checkedClaimLineRecord =[];
        const balance = 0;
        const claimAmount = 0;
        var totalclaimAmount = 0;
        var sumOfClaimAmount = 0;
        var selectedTotalBalance = 0;
        
        for(var i=0; i<this.claimLinesList.length;i++){
            console.log("this.claimLinesList[i]['Amount']1----->"+this.claimLinesList[i]['Amount'] );
            if(this.claimLinesList[i]['IsChecked'] == true && this.claimLinesList[i]['Amount'] != null && this.claimLinesList[i]['Amount'] != ''){
                this.claimAmount = parseFloat(this.claimLinesList[i]['Amount']);
                totalclaimAmount += this.claimAmount;
                checkedClaimLineRecord.push(this.claimLinesList[i]);
                this.balance = this.claimLinesList[i]['Balance'];
                selectedTotalBalance += this.balance;
                this.totalBalance = selectedTotalBalance;
            }           
        }
        if(this.additionalAmount==0 && this.additionalAmount==null){
            this.totalAdditionalAmount = totalclaimAmount;
        }else{
            this.totalAdditionalAmount = totalclaimAmount + parseInt(this.additionalAmount);    
        }
       
        for(var i=0;i<this.paymentlist.length; i++){
            this.paymentlist[i]['Allocation__c'] = (checkedClaimLineRecord.length ? this.totalAdditionalAmount+this.allocationAmount : this.allocationAmount).toFixed(2); 
            const unallocatedAmount =   parseFloat(this.paymentlist[i]['Amount__c'] - this.paymentlist[i]['Allocation__c']).toFixed(2); 
            this.paymentlist[i]['Unallocation__c'] = unallocatedAmount;
            this.paymentlist[i]['Balance__c'] =  (this.paymentlist[i]['Unallocation__c']);
            }
       
        if(this.paymentlist[0]['Balance__c'] == 0){
            this.disabled = false;
            }
            else{
                this.disabled = true; 
            }
        if(totalclaimAmount > this.unalloacte){
            this.claimLinesList[rowIndex]['Balance'] = this.BalanceMap.get(JSON.stringify(rowIndex));
            this.openWarningMsg = true;
        }
    }   
    closeWarningModel(event){
        this.openWarningMsg = false;
        this.openWarningAlloacte = false;
        //this.openClaimSelected = false;
        if(this.paymentlist[0]['Balance__c'] == 0){
            this.disabled = false;
            }
       else{
        this.disabled = true;
       }
       if(this.claimRowWarning != undefined && this.claimRowWarning != null){
       this.claimLinesList[this.claimRowWarning].IsChecked = false;
       this.claimLinesList[this.claimRowWarning].Amount = null;
       if(this.balanceMapvalue != undefined && this.balanceMapvalue != null){
        this.claimLinesList[this.claimRowWarning].Balance = this.balanceMapvalue;
       }

       if( this.minusAmount != undefined &&  this.minusAmount != null){
        this.paymentlist[0]['Allocation__c'] = parseFloat(this.paymentlist[0]['Allocation__c']) -parseFloat(this.minusAmount).toFixed(2);
        const unallocation = parseFloat(this.paymentlist[0]['Unallocation__c']);
        const minusAmount = parseFloat(this.minusAmount);
        const sum = unallocation + minusAmount;
        const formattedSum = sum.toFixed(2);
        this.paymentlist[0]['Unallocation__c'] = formattedSum;       
        this.paymentlist[0]['Balance__c'] = formattedSum;  
       }
       if(this.minusCurrentPayments != undefined && this.minusCurrentPayments != null){
        this.paymentlist[0]['Allocation__c'] = parseFloat(this.paymentlist[0]['Allocation__c']) -parseFloat(this.minusCurrentPayments).toFixed(2);
        const unallocation = parseFloat(this.paymentlist[0]['Unallocation__c']);
        const minusCurrentPayments = parseFloat(this.minusCurrentPayments);
        const sum = unallocation + minusCurrentPayments;
        const formattedSum = sum.toFixed(2);
        this.paymentlist[0]['Unallocation__c'] = formattedSum;       
        this.paymentlist[0]['Balance__c'] = formattedSum;
       }
    //    if(balanceCurrentPaymentValue != undefined && balanceCurrentPaymentValue != null){
    //     this.claimLinesList[this.claimRowWarning].Balance = this.balanceCurrentPaymentValue;
    //    }
       }
      
       
    }
    @api caluculatedAmount;
    @api balanceamountmap;
    // handleAllocateClick(event){
    //     var selectedTotalBalance = 0;
    //     var finalAllocatedAmount = 0;
    //     var totalAllocatedAmount = 0;
    //     var checkedpatientClaimLineRecord =[];
    //     var balanceMapAmount = 0;
    //     for(var i=0; i<this.claimLinesList.length;i++){
    //         if(this.claimLinesList[i]['IsChecked']== true){
    //              this.balance = this.BalanceClaimMap.get(this.claimLinesList[i]['Id']);
    //              selectedTotalBalance += this.balance;
    //              checkedpatientClaimLineRecord.push(this.claimLinesList[i]);
    //              balanceMapAmount = this.BalanceMap.get(JSON.stringify(rowIndex));
    //              this.balanceamountmap =  this.BalanceMap.get(JSON.stringify(rowIndex));
    //              console.log('selectedTotalBalance----',selectedTotalBalance);
    //         }
    //     }
    //     console.log('balance----map',this.BalanceClaimMap);
    //     console.log('this.amount---',this.amount);
    //     for(var i=0; i<this.claimLinesList.length;i++){
    //         if(this.claimLinesList[i]['IsChecked'] == true){
    //              finalAllocatedAmount = parseFloat(this.BalanceClaimMap.get(this.claimLinesList[i]['Id'])) / parseFloat(selectedTotalBalance)*(this.amount);
    //              console.log('finalAllocatedAmount---',finalAllocatedAmount);
    //              console.log('BalanceClaimMap---',parseFloat(this.BalanceClaimMap.get(this.claimLinesList[i]['Id'])));
    //              console.log('selectedTotalBalance---',selectedTotalBalance);
    //              console.log('thisamount---',this.amount);
    //              console.log('selectedbalncAmount---',parseFloat(selectedTotalBalance)*(this.amount));
    //              const allocatedAmount = parseFloat(finalAllocatedAmount.toFixed(2));
    //              this.claimLinesList[i]['Amount'] = parseFloat(allocatedAmount);
    //              if(this.claimLinesList[i]['Amount'] > this.BalanceClaimMap.get(this.claimLinesList[i]['Id'])){
    //                 this.claimLinesList[i]['Amount'] = this.BalanceClaimMap.get(this.claimLinesList[i]['Id'])
    //                }
    //           }
    //         else if(this.claimLinesList[i]['IsChecked'] == false){
    //             this.claimLinesList[i]['Amount'] = null;
    //             this.claimLinesList[i]['Balance'] = this.BalanceMap.get(JSON.stringify(i));
    //         }
    //     }
    //     // for(var i=0; i<this.claimLinesList.length;i++){
    //     //     if(this.claimLinesList[i]['IsChecked'] == true){
    //     //         if ( this.claimLinesList[i]['AllowedAmount'] != null && this.claimLinesList[i]['AllowedAmount'] != '') {
    //     //             const balance = this.claimLinesList[i]['AllowedAmount'] - this.claimLinesList[i]['Payments'] - this.claimLinesList[i]['Amount'];
    //     //             this.claimLinesList[i]['Balance'] = Math.max(balance, 0).toFixed(2);
    //     //             console.log('balance 1----->', this.claimLinesList[i]['Balance']);
    //     //           }
                  
    //     //         else /*if(this.claimLinesList[i]['Payments'] != null && this.claimLinesList[i]['Payments'] != '')*/{
    //     //             this.claimLinesList[i]['Balance'] = (this.claimLinesList[i]['TotalAmount']-this.claimLinesList[i]['Payments'] - this.claimLinesList[i]['Amount']).toFixed(2);
    //     //             console.log('balance 2----->',this.claimLinesList[i]['Balance'] )
                    
    //     //         }
    //     //         // else{
    //     //         //     this.claimLinesList[i]['Balance'] = this.claimLinesList[i]['Amount'].toFixed(2);
    //     //         // }
    //     //     }
    //         // if(this.claimLinesList[i]['Balance'] < 0){
    //         //     LightningAlert.open({
    //         //         message : 'Balance becomes negative please check the balance.', 
    //         //         theme: 'warning',
    //         //         label: 'Warning!',
    //         //     }).then((result) => {
        
    //         //     });
    //         // }
    //     // }
       
    //     // for(var i=0; i<this.claimLinesList.length;i++){
    //     //     if(this.claimLinesList[i]['IsChecked'] == true){
    //     //         totalAllocatedAmount += parseFloat(this.claimLinesList[i]['Amount']);
    //     //         console.log('handleamount ---',(this.claimLinesList[i]['Amount']));
    //     //         console.log('totalAllocatedAmount---',totalAllocatedAmount);
    //     //       } 
    //     // }
    //     //  debugger;
    //     // if(totalAllocatedAmount > this.unalloacte){
    //     //     this.openWarningMsg = true;
    //     // }
    //     // for(var i=0; i<this.claimLinesList.length;i++){
    //     // if(this.claimLinesList[i]['Balance'] < 0){
    //     //     LightningAlert.open({
    //     //         message : 'Balance becomes negative please check the balance.', 
    //     //         theme: 'warning',
    //     //         label: 'Warning!',
    //     //     }).then((result) => {
    
    //     //     });
    //     // }
    //     // }
       
    //     for(var i=0;i<this.paymentlist.length; i++){
    //          const allocationamount = parseFloat(totalAllocatedAmount.toFixed(2));
    //          console.log('allocationamount---',allocationamount);
    //          this.paymentlist[i]['Allocation__c'] = checkedpatientClaimLineRecord.length ? allocationamount:allocationamount;
    //          const unallocatedAmount =   parseFloat(this.paymentlist[i]['Amount__c'] - this.paymentlist[i]['Allocation__c']).toFixed(2); 
    //          this.paymentlist[i]['Unallocation__c'] = unallocatedAmount;
    //          this.paymentlist[i]['Balance__c'] =  (this.paymentlist[i]['Unallocation__c']);
    //          this.disableButton = true;
    //      }
    //     var rowIndex = Number(event.target.name);
    //     var ClaimRecords =[];
    //     ClaimRecords = JSON.parse(JSON.stringify(this.claimLinesList));
    //     this.claimLinesList = ClaimRecords;
    //     if(this.paymentlist[0]['Balance__c'] == 0){
    //         this.disabled = false;
    //       }
    //     else
    //     {
    //         this.disabled = true; 
    //     }


    // }
    value = 'None';

    get options() {
        return [
            { label: 'Insurance', value: 'Insurance' },
            { label: 'Patient', value: 'Patient' },
            { label: 'Attorney', value: 'Attorney' },
            { label: 'None', value: 'None' },
        ];
    }
    handleClearALL(event){
        this.getRecordsDate();
        this.selectAllChecked = false;
        this.disableButton = false;
    }

    handleBalncTransferedPicklist(event){
    var rowIndex = (event.target.name);
    var ClaimRecords =[];
    ClaimRecords = JSON.parse(JSON.stringify(this.claimLinesList));
    ClaimRecords[Number(event.target.name)]['BalanceTransferredTo'] = event.target.value;
    this.claimLinesList = ClaimRecords;
        }
    handleAmount(event){
        
    var TotalPaymentBalance ;
    var negativeBalance ; 
    var rowIndex = Number(event.target.name);
    if(this.payertype != null && this.checkPayerType == 'Payer'){
    this.disableButton = true;
    }
    else{
        this.disableButton = false;
    }
    this.claimRowWarning = rowIndex;
    var ClaimRecords =[];
    ClaimRecords = JSON.parse(JSON.stringify(this.claimLinesList));
    console.log('totalamount =---',ClaimRecords[rowIndex]['TotalAmount']);
    ClaimRecords[rowIndex]['Amount'] = event.target.value;
    this.minusCurrentPayments = ClaimRecords[rowIndex]['Amount'];
    console.log('this.minusCurrentPayments------>',this.minusCurrentPayments)
    this.balanceCurrentPaymentValue = this.BalanceMap.get(JSON.stringify(rowIndex));
    if(ClaimRecords[rowIndex]['Amount'] != null && ClaimRecords[rowIndex]['Amount'] != ''){
        ClaimRecords[rowIndex]['IsChecked'] = true;
    if(ClaimRecords[rowIndex]['Amount'] != null && ClaimRecords[rowIndex]['Amount'] != '' && ClaimRecords[rowIndex]['AllowedAmount'] != null && ClaimRecords[rowIndex]['AllowedAmount'] != ''){
        ClaimRecords[rowIndex]['Balance'] = (ClaimRecords[rowIndex]['AllowedAmount'] - ClaimRecords[rowIndex]['Payments'] - ClaimRecords[rowIndex]['Amount']).toFixed(2);
        negativeBalance = ClaimRecords[rowIndex]['Balance'];
        TotalPaymentBalance = ClaimRecords[rowIndex]['Payments'] + parseInt(ClaimRecords[rowIndex]['Amount']);
        }
    else{
        ClaimRecords[rowIndex]['Balance'] = (ClaimRecords[rowIndex]['TotalAmount']-ClaimRecords[rowIndex]['Payments'] - ClaimRecords[rowIndex]['Amount']).toFixed(2);
        negativeBalance = ClaimRecords[rowIndex]['Balance'];
    }
    // else{
    //     ClaimRecords[rowIndex]['Balance'] = ClaimRecords[rowIndex]['Amount'];
    // }
    }
    else{
        ClaimRecords[rowIndex]['IsChecked'] = false;
        ClaimRecords[rowIndex]['Balance'] =  this.BalanceMap.get(JSON.stringify(rowIndex));

    }
    // if(negativeBalance < 0){
    //     LightningAlert.open({
    //         message : 'Balance becomes negative please check the balance.', 
    //         theme: 'warning',
    //         label: 'Warning!',
    //     }).then((result) => {

    //     });
    // }
    // if(TotalPaymentBalance > ClaimRecords[rowIndex]['TotalAmount']){
    //     LightningAlert.open({
    //         message : 'The Total Payment Recieved is greater than the Total Amount, please check the value.', 
    //         theme: 'warning',
    //         label: 'Warning!',
    //     }).then((result) => {

    //     });
    // }
    this.claimLinesList = ClaimRecords;
    if(this.claimLinesList[rowIndex]['IsChecked'] == true){
        this.handleSelect2(rowIndex, ClaimRecords);
    }
    else{
        this.handleSelect2(rowIndex, ClaimRecords);
        ClaimRecords[rowIndex]['IsChecked'] = false;
    }
    }
    handlechangedAllowAmount(event){
        var rowIndex = Number(event.target.name);
        var newClaimRecords =[];
        var newallowedAmount = 0;
        var totalallowedamount = 0;
        var allocateamounte ;
        var balanceAmount ;
        newClaimRecords = JSON.parse(JSON.stringify(this.claimLinesList));
        /*newClaimRecords[rowIndex]['AllowedAmount'] = event.target.value;
       
        if(newClaimRecords[rowIndex]['AllowedAmount'] != undefined && newClaimRecords[rowIndex]['AllowedAmount'] != null && newClaimRecords[rowIndex]['AllowedAmount'] != ''){
            newClaimRecords[rowIndex]['AdjAmount'] = (newClaimRecords[rowIndex]['TotalAmount'] - newClaimRecords[rowIndex]['AllowedAmount']).toFixed(2);

        }else{
            newClaimRecords[rowIndex]['AdjAmount'] = 0;
        }*/
        
        //     if(newClaimRecords[rowIndex]['AllowedAmount'] != undefined && newClaimRecords[rowIndex]['AllowedAmount'] != null && newClaimRecords[rowIndex]['AllowedAmount'] != ''){
        //     newClaimRecords[rowIndex]['Balance'] = 0;
        //     }
        //     else{
        //    newClaimRecords[rowIndex]['Balance'] = this.BalanceMap.get(JSON.stringify(rowIndex));
        //     }
            this.claimLinesList = newClaimRecords;
        // newClaimRecords[rowIndex]['Balance'] = newClaimRecords[rowIndex]['TotalAmount'] - newClaimRecords[rowIndex]['AllowedAmount']- newClaimRecords[rowIndex]['AdjAmount'];
        // newallowedAmount =  parseInt(newClaimRecords[rowIndex]['AllowedAmount']);
        for(var i=0; i<this.claimLinesList.length;i++){
            if(this.claimLinesList[i]['AllowedAmount']!=null && this.claimLinesList[i]['AllowedAmount']!=undefined && this.claimLinesList[i]['AllowedAmount']!='' || this.claimLinesList[i]['IsChecked']== true){
                newallowedAmount +=  parseInt(this.claimLinesList[i]['AllowedAmount']);
                }
                
              }
      }
        // handleChangeAdditionalAmount(event){
        //     var addamount ;
        //     this.additionalAmount = event.target.value;
        //     addamount = this.additionalAmount;
        //     console.log('addamount--',addamount);
        // }
    //     handleAdjustBalance(event){
    //         for(var i=0;i<this.paymentlist.length; i++){
    //         this.additionalAmount =   this.paymentlist[i]['Balance__c'];
    //         for (var i = 0; i < this.paymentlist.length; i++) {
    //             var allocation = parseFloat(this.paymentlist[i]['Allocation__c']);
    //             var additionalAmount = parseFloat(this.additionalAmount);
                
    //             var sum = (allocation * 100 + additionalAmount * 100) / 100; // Multiply by 100 to avoid floating-point issues
                
    //             this.paymentlist[i]['Allocation__c'] = sum.toFixed(2); // Convert to string with 2 decimal places if needed for display
    //             this.paymentlist[i]['Unallocation__c'] =   this.paymentlist[i]['Amount__c'] - this.paymentlist[i]['Allocation__c']  ; 
    //             this.paymentlist[i]['Balance__c'] =  this.paymentlist[i]['Unallocation__c'];
    //             }
    //         if(this.paymentlist[0]['Balance__c'] == 0){
    //             this.disabled = false;
    //             }
    //        else{
    //         this.disabled = true;
    //        }
    //     }
    // }
    // handleSearch(event){
    //     var searchKey = event.target.value;
    //     this.searchVal = event.target.value;

    //     searchKey = searchKey.toLowerCase();
    //     var searchList = this.claimLinesList.filter(rec => {
    //         if((rec.Patient && rec.Patient.toLowerCase().includes(searchKey)) || 
    //           (rec.Claim && rec.Claim.toLowerCase().includes(searchKey)) || 
    //           (rec.ClaimLine && rec.ClaimLine.toLowerCase().includes(searchKey)) || 
    //           (rec.TotalAmount && rec.TotalAmount.toString().includes(searchKey)) || 
    //         //   (rec.AllowedAmount && rec.AllowedAmount.toString().includes(searchKey)) ||
    //         //   (rec.AdjAmount && rec.AdjAmount.toString().includes(searchKey)) || // Check AdjAmount
    //           (rec.Payments && rec.Payments.toString().includes(searchKey)) ||   // Check Payments
    //         //   (rec.Balance && rec.Balance.toString().includes(searchKey)) ||     // Check Balance
    //           (rec.Amount && rec.Amount.toString().includes(searchKey)) || 
    //           (rec.BalanceTransferredTo && rec.BalanceTransferredTo.toLowerCase().includes(searchKey))
    //           ){
    //             rec.isSearch = true;
    //         }else{
    //             rec.isSearch = false;
    //         } 
    //         return rec;
    //     });
    //     this.claimLinesList = searchList
       
    //     }
}