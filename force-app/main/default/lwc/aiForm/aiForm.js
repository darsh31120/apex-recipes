import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AiForm extends LightningElement {
    @track formDescription = '';
    @track formData = '';

    get isValidGenerateInput() {
        return this.formDescription && this.formData;
    }

    handleFormDescriptionChange(event) {
        this.formDescription = event.target.value;
    }

    handleFormDataChange(event) {
        this.formData = event.target.value;
    }

    handleGenerateSteps() {
        this.showToast('Success', 'Steps generated successfully!', 'success');
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
