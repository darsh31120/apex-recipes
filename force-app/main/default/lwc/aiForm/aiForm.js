import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AiForm extends LightningElement {
    @track formDescription = '';
    @track formData = '';
    @track generatedSteps = [];
    @track workflowName = '';
    @track savedWorkflows = [];

    get isValidGenerateInput() {
        return this.formDescription && this.formData;
    }

    get isValidSaveInput() {
        return this.workflowName && this.generatedSteps.length > 0;
    }

    handleFormDescriptionChange(event) {
        this.formDescription = event.target.value;
    }

    handleFormDataChange(event) {
        this.formData = event.target.value;
    }

    handleWorkflowNameChange(event) {
        this.workflowName = event.target.value;
    }

    handleGenerateSteps() {
        // Generate mock steps
        this.generatedSteps = [
            {
                stepId: 'step-1',
                stepNumber: 1,
                stepType: 'navigate',
                selector: '',
                value: 'https://example.com/form',
                waitTime: 0
            },
            {
                stepId: 'step-2',
                stepNumber: 2,
                stepType: 'input',
                selector: '#firstName',
                value: 'John',
                waitTime: 0
            },
            {
                stepId: 'step-3',
                stepNumber: 3,
                stepType: 'input',
                selector: '#lastName',
                value: 'Doe',
                waitTime: 0
            },
            {
                stepId: 'step-4',
                stepNumber: 4,
                stepType: 'click',
                selector: '#saveButton',
                value: '',
                waitTime: 0
            }
        ];
        
        this.showToast('Success', 'Steps generated successfully! Including save step.', 'success');
    }

    handleSaveWorkflow() {
        if (!this.isValidSaveInput) {
            this.showToast('Error', 'Please provide a workflow name and generate steps first.', 'error');
            return;
        }

        const workflow = {
            id: Date.now().toString(),
            name: this.workflowName,
            description: this.formDescription,
            formData: this.formData,
            steps: this.generatedSteps,
            createdAt: new Date().toISOString()
        };

        // Save to localStorage for persistence
        const existingWorkflows = JSON.parse(localStorage.getItem('aiFormWorkflows') || '[]');
        existingWorkflows.push(workflow);
        localStorage.setItem('aiFormWorkflows', JSON.stringify(existingWorkflows));
        
        this.savedWorkflows = existingWorkflows;
        
        this.showToast('Success', `Workflow "${this.workflowName}" saved successfully!`, 'success');
        
        // Clear the form after saving
        this.workflowName = '';
        this.formDescription = '';
        this.formData = '';
        this.generatedSteps = [];
    }

    handleLoadWorkflow(event) {
        const workflowId = event.target.dataset.workflowId;
        const workflow = this.savedWorkflows.find(w => w.id === workflowId);
        
        if (workflow) {
            this.workflowName = workflow.name;
            this.formDescription = workflow.description;
            this.formData = workflow.formData;
            this.generatedSteps = workflow.steps;
            
            this.showToast('Success', `Workflow "${workflow.name}" loaded successfully!`, 'success');
        }
    }

    handleDeleteWorkflow(event) {
        const workflowId = event.target.dataset.workflowId;
        this.savedWorkflows = this.savedWorkflows.filter(w => w.id !== workflowId);
        localStorage.setItem('aiFormWorkflows', JSON.stringify(this.savedWorkflows));
        
        this.showToast('Success', 'Workflow deleted successfully!', 'success');
    }

    handleExecuteAndSave() {
        // First generate steps if not already generated
        if (this.generatedSteps.length === 0) {
            this.handleGenerateSteps();
        }
        
        // Then save the workflow
        setTimeout(() => {
            this.handleSaveWorkflow();
        }, 1000);
        
        this.showToast('Info', 'Generating steps and saving workflow...', 'info');
    }

    // Load saved workflows on component initialization
    connectedCallback() {
        const saved = localStorage.getItem('aiFormWorkflows');
        if (saved) {
            this.savedWorkflows = JSON.parse(saved);
        }
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
