import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generateSteps from '@salesforce/apex/FormAutomationRestController.generateSteps';
import executeWorkflow from '@salesforce/apex/FormAutomationRestController.executeWorkflow';
import getTemplates from '@salesforce/apex/FormAutomationRestController.getTemplates';

export default class AiFormAutomation extends LightningElement {
    @api cardTitle = 'AI Form Automation';

    // Generate Steps Tab Properties
    @track formDescription = '';
    @track formData = '';
    @track formHtml = '';
    @track generatedSteps = [];
    @track isGenerating = false;

    // Templates Tab Properties
    @track templates = [];

    // Execute Tab Properties
    @track targetUrl = '';
    @track workflowName = '';
    @track isExecuting = false;
    @track executionStatus = '';
    @track executionMessage = '';
    @track executionLog = [];

    // Computed Properties
    get isValidGenerateInput() {
        return this.formDescription && this.formData;
    }

    get isValidExecuteInput() {
        return this.targetUrl && this.workflowName && this.generatedSteps.length > 0;
    }

    get executionStatusClass() {
        switch(this.executionStatus) {
            case 'success': return 'slds-theme_success';
            case 'error': return 'slds-theme_error';
            case 'warning': return 'slds-theme_warning';
            default: return 'slds-theme_info';
        }
    }

    get executionIcon() {
        switch(this.executionStatus) {
            case 'success': return 'utility:success';
            case 'error': return 'utility:error';
            case 'warning': return 'utility:warning';
            default: return 'utility:info';
        }
    }

    // Event Handlers
    handleFormDescriptionChange(event) {
        this.formDescription = event.target.value;
    }

    handleFormDataChange(event) {
        this.formData = event.target.value;
    }

    handleFormHtmlChange(event) {
        this.formHtml = event.target.value;
    }

    handleTargetUrlChange(event) {
        this.targetUrl = event.target.value;
    }

    handleWorkflowNameChange(event) {
        this.workflowName = event.target.value;
    }

    // Tab Handlers
    handleGenerateTabActive() {
        // Load any necessary data when generate tab is activated
    }

    handleTemplatesTabActive() {
        this.loadTemplates();
    }

    handleExecuteTabActive() {
        // Load any necessary data when execute tab is activated
    }

    // Generate Steps
    async handleGenerateSteps() {
        this.isGenerating = true;
        
        try {
            const requestData = {
                formDescription: this.formDescription,
                formData: this.formData,
                formHtml: this.formHtml || null
            };

            const result = await generateSteps({ requestBody: JSON.stringify(requestData) });
            
            if (result.success) {
                this.generatedSteps = result.steps.map((step, index) => ({
                    stepId: `step-${index}`,
                    stepNumber: index + 1,
                    stepType: step.stepType,
                    selector: step.selector,
                    value: step.value,
                    waitTime: step.waitTime || 0,
                    metadata: step.metadata || {}
                }));
                
                this.showToast('Success', 'Steps generated successfully!', 'success');
            } else {
                this.showToast('Error', result.message || 'Failed to generate steps', 'error');
            }
        } catch (error) {
            console.error('Error generating steps:', error);
            this.showToast('Error', 'Failed to generate steps: ' + error.body.message, 'error');
        } finally {
            this.isGenerating = false;
        }
    }

    // Delete Step
    handleDeleteStep(event) {
        const stepId = event.target.dataset.stepId;
        this.generatedSteps = this.generatedSteps.filter(step => step.stepId !== stepId);
    }

    // Load Templates
    async loadTemplates() {
        try {
            const result = await getTemplates();
            
            if (result.success) {
                this.templates = Object.entries(result.templates).map(([key, template]) => ({
                    id: key,
                    name: template.workflowName,
                    description: `Template for ${template.workflowName}`,
                    steps: template.steps
                }));
            } else {
                this.showToast('Error', result.message || 'Failed to load templates', 'error');
            }
        } catch (error) {
            console.error('Error loading templates:', error);
            this.showToast('Error', 'Failed to load templates: ' + error.body.message, 'error');
        }
    }

    // Use Template
    handleUseTemplate(event) {
        const templateId = event.target.dataset.templateId;
        const template = this.templates.find(t => t.id === templateId);
        
        if (template) {
            this.generatedSteps = template.steps.map((step, index) => ({
                stepId: `step-${index}`,
                stepNumber: index + 1,
                stepType: step.stepType,
                selector: step.selector,
                value: step.value,
                waitTime: step.waitTime || 0,
                metadata: step.metadata || {}
            }));
            
            this.showToast('Success', 'Template loaded successfully!', 'success');
        }
    }

    // Execute Workflow
    async handleExecuteWorkflow() {
        this.isExecuting = true;
        this.executionLog = [];
        this.executionStatus = '';
        this.executionMessage = '';
        
        this.addLogEntry('info', 'Starting workflow execution...');
        
        try {
            const requestData = {
                workflowName: this.workflowName,
                targetUrl: this.targetUrl,
                steps: this.generatedSteps.map(step => ({
                    stepType: step.stepType,
                    selector: step.selector,
                    value: step.value,
                    waitTime: step.waitTime,
                    metadata: step.metadata
                }))
            };

            this.addLogEntry('info', 'Sending workflow to server...');
            const result = await executeWorkflow({ requestBody: JSON.stringify(requestData) });
            
            if (result.success) {
                this.executionStatus = 'success';
                this.executionMessage = 'Workflow executed successfully!';
                this.addLogEntry('success', `Workflow completed: ${result.status}`);
                this.addLogEntry('info', `Start time: ${result.startTime}`);
                this.addLogEntry('info', `End time: ${result.endTime}`);
                
                this.showToast('Success', 'Workflow executed successfully!', 'success');
            } else {
                this.executionStatus = 'error';
                this.executionMessage = result.message || 'Failed to execute workflow';
                this.addLogEntry('error', this.executionMessage);
                
                this.showToast('Error', this.executionMessage, 'error');
            }
        } catch (error) {
            console.error('Error executing workflow:', error);
            this.executionStatus = 'error';
            this.executionMessage = 'Failed to execute workflow: ' + error.body.message;
            this.addLogEntry('error', this.executionMessage);
            
            this.showToast('Error', this.executionMessage, 'error');
        } finally {
            this.isExecuting = false;
        }
    }

    // Add Log Entry
    addLogEntry(type, message) {
        const logEntry = {
            id: `log-${Date.now()}-${Math.random()}`,
            timestamp: new Date().toLocaleTimeString(),
            type: type.toUpperCase(),
            message: message
        };
        
        this.executionLog = [...this.executionLog, logEntry];
    }

    // Show Toast
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
