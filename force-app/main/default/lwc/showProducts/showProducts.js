import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getAvailabledProducts from '@salesforce/apex/ShowProductsController.getAvailabledProducts';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import COUNTRY_FIELD from '@salesforce/schema/Product2.Country_Of_Origin__c';
import { fireEvent } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createOpportunity from '@salesforce/apex/ShowProductsController.createOpportunity';
import { NavigationMixin } from 'lightning/navigation';

export default class ShowProducts extends NavigationMixin(LightningElement) {
    @track isLoading = true;
    @track totalRecords = 0; // total number of records after filtering
    @track totalPages = 0; // how many pages will be displayed if we have this number of total records
    @track currentPage = 1; //current page
    pageSize = 5; // Records per page
    
    @track selectedCountry = 'All'; // default comboBox value
    @track selectedType = 'All'; // default comboBox value
    
    // Fetch paginated data from Apex
    connectedCallback() {
        this.loadAccounts();

    }
    
    loadAccounts() {
        getAvailabledProducts({ coutryOfOrigin: this.selectedCountry, recordTypeName: this.selectedType, pageNumber: this.currentPage, pageSize: this.pageSize })
        .then(result => {
            this.totalRecords = result.totalRecords;
            this.totalPages = result.totalPages;
            console.log(this.totalRecords,result.totalRecords, 'total records' )
            
            //put inside if because we dont want to recompute them everytime we can the method
            if(this.allProducts === undefined) {
                if (this.selectedCountry == 'All' && this.selectedType == 'All'){
                    this.allProducts = result.allRecords.map(prod => ({
                        ...prod,
                        price: prod.price != null ? `${prod.price}$` : ''
                    }));
                }
            }
            
            console.log('all products: ', JSON.stringify(this.allProducts));
            this.products = result.records.map(prod => ({
                ...prod,
                price: prod.price != null ? `${prod.price}$` : ''
            }));
            
            this.isLoading = false;
            console.log('those prodycts: ', this.products);
            
            // ⬇️ After new data is loaded, recompute which rows should be selected
            const visibleIds = this.products.map(r => r.productId);
            this.selectedRowIds = Array.from(this.globalSelectedIds).filter(id =>
                visibleIds.includes(id)
            );
        })
        .catch(error => {
            console.error('Error fetching data:', error);
        });
    }
    
    // Navigate to Previous Page
    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadAccounts();
        }
    }
    
    // Navigate to Next Page
    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadAccounts();
        }
    }
    
    // Disable navigation buttons when needed
    get disablePrevious() {
        return this.currentPage === 1;
    }
    
    get disableNext() {
        return this.currentPage === this.totalPages;
    }
    
    
    
    @api recordId; // used to get the Account Id so when create the Opp we create it on the correct Account
    @track products = []; // used to get all the products by the correct filters and paginated
    error; // error if we didnt get the correct products right and apex give error
    @track selectedRowIds = []; // array passed to datatable (visible selected ids)
    
    recortTypeOptions = 
    [{ label: 'All', value: 'All' },
        { label: 'Generator', value: 'Generator' }, 
        { label: 'Part', value: 'Part' }]; //for comboBox recordType
        countryOptions = []; //for comboBox but we will use wire to get it
        @track opportunityName = ''; // oppName lighting field
        columns = 
        [{ label: 'Name', fieldName: 'name' , type :'button' , typeAttributes: 
            {label: { fieldName: 'name' },name: 'select_product',variant: 'base'}},
            { label: 'Country of Origin', fieldName: 'country' },
            { label: 'Type', fieldName: 'recordType'},
            { label: 'Price USD', fieldName: 'price'}
        ]; // column of the dataTable
        allProducts;
        
        productIdsToOpp = []; // which products we will be related to opportunity
        selectedProductId; // when we click button in a row, we get the Id of the product which we will send to the subscriber
        
        selectedRows = []; // hold the complete selected rows 
        // Keep a Set to remember all selected IDs across filters
        globalSelectedIds = new Set(); // set of all selected rows even if hidden
        
        
        
        
        @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
        objectInfo;
        
        @wire(getPicklistValues, {
            recordTypeId: '$objectInfo.data.defaultRecordTypeId',
            fieldApiName: COUNTRY_FIELD
        })
        wiredPicklistValues({ data, error }) {
            if (data) {
                this.countryOptions = [
                    { label: 'All', value: 'All' },
                    ...data.values.map(pick => ({
                        label: pick.label,
                        value: pick.value
                    }))
                ];
            } else if (error) {
                console.error('Error loading picklist values:', error);
            }
        }
        
        
        handleChange(event) {
            this.isLoading = true;
            const { name, value } = event.target; 
            if (name === 'country') {
                this.selectedCountry = value;
            } else if (name === 'type') {
                this.selectedType = value;
            }
            const visibleIds = this.products.map(r => r.productId);
            
            this.currentPage = 1;
            this.loadAccounts();
            
            
            this.selectedRowIds = Array.from(this.globalSelectedIds).filter(id => visibleIds.includes(id));
            console.log('selected Ids row Ids' , JSON.stringify(this.selectedRowIds));
            
            
            //selected type of country
            console.log('selected product country:' , this.selectedCountry );
            console.log('selected product type :' , this.selectedType );
            
        }
        
        
        
        
        handleNameChange(event) {
            this.opportunityName = event.target.value;
            // Now opportunityName always has the latest user input
            console.log('Opportunity Name:', this.opportunityName);
        }
        
        
        
        handleRowAction(event) {
            const action = event.detail.action;
            const row = event.detail.row;
            console.log('hello world');
            if (action.name === 'select_product') {
                this.selectedProductId = row.productId;
                console.log('Selected Product ID:', this.selectedProductId);
                fireEvent('myCustomEvent', { data: this.selectedProductId });
                
            }
        }
        
        handleRowSelection(event) {
            const visibleNow = event.detail.selectedRows.map(r => r.productId); // id of visible selected rows
            console.log('visible now: ', visibleNow, JSON.stringify(visibleNow));
            
            const visibleIds = this.products.map(r => r.productId); // id of all the visible products
            console.log('visible ids:', visibleIds, JSON.stringify(visibleIds));
            
            const prevVisibleSelected = visibleIds.filter(id => this.globalSelectedIds.has(id)); //before we select a new row, which row were selected
            console.log('previous visible selected:', JSON.stringify(prevVisibleSelected));
            
            const added = visibleNow.filter(id => !prevVisibleSelected.includes(id));
            console.log('added:', JSON.stringify(added));
            
            const removed = prevVisibleSelected.filter(id => !visibleNow.includes(id));
            console.log('removed:', JSON.stringify(removed));
            
            // Update global selection set
            added.forEach(id => this.globalSelectedIds.add(id)); // updateGlobal
            removed.forEach(id => this.globalSelectedIds.delete(id)); //updateGlobal
            console.log('globalSelectedIds (json):', JSON.stringify(Array.from(this.globalSelectedIds)));
            
            
            console.log('handle row selection fired');
            console.log(event.detail.selectedRows);
            this.selectedRowIds = Array.from(this.globalSelectedIds).filter(id => visibleIds.includes(id));
            
            // ✅ Keep the full row objects for submit logic
            this.selectedRows = Array.from(this.globalSelectedIds)
            .map(id => this.allProducts.find(p => p.productId === id))
            .filter(Boolean);
            
            console.log('selected rows complete: ', JSON.stringify(this.selectedRows),  ' SIZE : ', this.selectedRows.length)
            console.log('selected Global Ids: ', JSON.stringify(Array.from(this.globalSelectedIds)), 'SIZE :' , Array.from(this.globalSelectedIds).length);
        }
        
        
        handleSubmit() {
            console.log('enter submit:');
            console.log('this selected row length: ', this.selectedRows.length);
            console.log('this opp name ', this.opportunityName);
            
            if (this.selectedRows.length === 0 || this.opportunityName.trim() === '') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Please enter an Opportunity name and select at least one product',
                        variant: 'error'
                    })
                );
                return;
            }
            // Example: process selected products
            const selectedIds = this.selectedRows.map(row => row.Id);
            

            console.log('Submitting products:', selectedIds[0]);
            console.log('selected rows: ', this.selectedRows);
            this.selectedRows.forEach(row => {
                console.log('ID:', row.productId);
                console.log('Name:', row.name);
                console.log('Price:', row.fullUrl);
                console.log('Country:', row.country);
                this.productIdsToOpp.push(row.productId);
            });
            console.log('balbla');
            console.log('data id are jere: ', this.productIdsToOpp, typeof(this.productIdsToOpp));
            
            this.productIdsToOpp.forEach(id => {
                console.log('id: ', id, typeof(id));
            });
            console.log('apex logic will come here');
            // TODO: Send to Apex or perform your logic
            
            
            
            //apex logic  getProductDetails(List<Id> productIds) productIdsToOpp List<Id> productIds, Id accountId, String opportunityName)
            createOpportunity({ 
                productIds: this.productIdsToOpp, 
                accountId: this.recordId, 
                opportunityName: this.opportunityName 
            })
            .then(opportunityId => {  // <-- capture returned opportunityId here
                console.log('Apex method executed successfully, Id:', opportunityId);
                this.productIdsToOpp = [];
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Submitted',
                        message: `${this.selectedRows.length} product(s) submitted.`,
                        variant: 'success'
                    })
                );
                
                this[NavigationMixin.Navigate]({  // <-- fix typo here: "this" not "his"
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: opportunityId,
                        objectApiName: 'Opportunity',
                        actionName: 'view'
                    }
                });
            })
            .catch(error => {
                console.error('Error calling Apex method:', error);
                this.productIdsToOpp = [];
            });
            
            
        }
        
        
    }