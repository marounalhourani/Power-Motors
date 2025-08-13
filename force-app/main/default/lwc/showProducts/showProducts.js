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
    @api recordId;
    @track products;
    error;
    @track selectedRowIds = [];      // array passed to datatable (visible selected ids)
    
    // Keep a Set to remember all selected IDs across filters
    globalSelectedIds = new Set();
    
    @wire(getAvailabledProducts)
    wiredProducts({ error, data }){
        if(data){
            this.products = data.map(prod => ({
                ...prod,
                price: prod.price != null ? `${prod.price}$` : ''
            }));
            this.filteredProducts = [...this.products];
        }
        else if(error){
            this.error = error;
            
        }
    }
    
    selectedCountry = 'All';
    selectedType = 'All';
    
    recortTypeOptions = [{ label: 'All', value: 'All' }, { label: 'Generator', value: 'Generator' }, { label: 'Part', value: 'Part' }];
    countryOptions = [];
    
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
    
    @track filteredProducts = [];
    
    handleChange(event) {
        const { name, value } = event.target; 
        
        if (name === 'country') {
            this.selectedCountry = value;
        } else if (name === 'type') {
            this.selectedType = value;
        }
        // Filter first
        this.filterProducts();
        // Recompute the visible selected IDs from the global Set
        const visibleIds = this.filteredProducts.map(r => r.productId);
        this.selectedRowIds = Array.from(this.globalSelectedIds).filter(id => visibleIds.includes(id));
        
        // this.filterProducts();
        console.log('selected product country:' , this.selectedCountry );
        console.log('selected product type :' , this.selectedType );
        
    }
    
    filterProducts() {
        this.filteredProducts = this.products.filter(product => {
            const matchCountry = this.selectedCountry === 'All' || product.country === this.selectedCountry;
            const matchType = this.selectedType === 'All' || product.recordType === this.selectedType;
            return matchCountry && matchType;
        });
        
    }
    
    @track opportunityName = '';
    handleNameChange(event) {
        this.opportunityName = event.target.value;
        // Now opportunityName always has the latest user input
        console.log('Opportunity Name:', this.opportunityName);
    }
    
    columns = [{ label: 'Name', fieldName: 'name' , type :'button' , typeAttributes: {label: { fieldName: 'name' },name: 'select_product',variant: 'base'}},
        { label: 'Country of Origin', fieldName: 'country' },
        { label: 'Type', fieldName: 'recordType'},
        { label: 'Price USD', fieldName: 'price'}
    ];
    
    selectedRows = [];
    
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
        const visibleNow = event.detail.selectedRows.map(r => r.productId);
        const visibleIds = this.filteredProducts.map(r => r.productId);
        const prevVisibleSelected = visibleIds.filter(id => this.globalSelectedIds.has(id));
        const added = visibleNow.filter(id => !prevVisibleSelected.includes(id));
        const removed = prevVisibleSelected.filter(id => !visibleNow.includes(id));
        // Update global selection set
        added.forEach(id => this.globalSelectedIds.add(id));
        removed.forEach(id => this.globalSelectedIds.delete(id));
        
        console.log('handle row selection fired');
        console.log(event.detail.selectedRows);
        this.selectedRowIds = Array.from(this.globalSelectedIds).filter(id => visibleIds.includes(id));
        
        // ✅ Keep the full row objects for submit logic
        this.selectedRows = Array.from(this.globalSelectedIds)
        .map(id => this.products.find(p => p.productId === id))
        .filter(Boolean);
        // this.selectedRows = event.detail.selectedRows;
    }
    
    selectAllVisible() {
        this.filteredProducts.forEach(p => this.globalSelectedIds.add(p.productId));
        this.selectedRowIds = this.filteredProducts.map(r => r.productId);
    }
    
    handleSubmit() {
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
    
    productIdsToOpp = [];
    selectedProductId;
}