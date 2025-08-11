import { LightningElement, wire } from 'lwc';
import getProductDetails from '@salesforce/apex/ShowProductsController.getProductDetails';
import { register, unregister } from 'c/pubsub';

export default class ShowProductDetails extends LightningElement {
    // Store the bound handler so we can unregister it properly
    boundHandler = this.handleEvent.bind(this);
    productId;
    product;
    error;

connectedCallback() {
    register('myCustomEvent', this.boundHandler);
    console.log('message from publisher to subscriber in subscriber: ');
}
disconnectedCallback() {
    unregister('myCustomEvent', this.boundHandler);
}

handleEvent(payload){
    console.log('message receive in subscriber',payload);
    console.log('Actual data:', payload.data);  
    this.productId = payload.data;
}

@wire(getProductDetails, {productId: '$productId'} )
wiredProduct({ data, error }) {
        if (data) {
            console.log('Wired product data:', data);
            this.product = data;
            this.error = undefined;
        } else if (error) {
            console.error('Error fetching product:', error);
            this.error = error;
            this.product = undefined;
        }
    }

}