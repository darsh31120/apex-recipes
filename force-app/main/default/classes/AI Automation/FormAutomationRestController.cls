/**
 * @description REST API controller for AI form automation
 * @group AI Automation
 */
@RestResource(urlMapping='/form-automation/*')
global with sharing class FormAutomationRestController {
    
    /**
     * @description Endpoint to generate form steps using AI
     */
    @HttpPost
    global static void generateSteps() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Parse request body
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            String formDescription = (String) requestData.get('formDescription');
            String formData = (String) requestData.get('formData');
            String formHtml = (String) requestData.get('formHtml');
            
            // Initialize AI step generator
            AIFormAutomation.AIStepGenerator generator = new AIFormAutomation.OpenAIStepGenerator();
            
            // Generate steps
            List<AIFormAutomation.FormStep> steps;
            if(String.isNotBlank(formHtml)) {
                // Analyze form structure first
                String analysis = generator.analyzeFormStructure(formHtml);
                steps = generator.generateSteps(formDescription, formData);
            } else {
                steps = generator.generateSteps(formDescription, formData);
            }
            
            // Convert steps to JSON response
            List<Map<String, Object>> stepsJson = new List<Map<String, Object>>();
            for(AIFormAutomation.FormStep step : steps) {
                Map<String, Object> stepJson = new Map<String, Object>{
                    'stepType' => step.stepType,
                    'selector' => step.selector,
                    'value' => step.value,
                    'waitTime' => step.waitTime,
                    'metadata' => step.metadata
                };
                stepsJson.add(stepJson);
            }
            
            Map<String, Object> response = new Map<String, Object>{
                'success' => true,
                'steps' => stepsJson,
                'message' => 'Steps generated successfully'
            };
            
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
            
        } catch(Exception e) {
            Map<String, Object> errorResponse = new Map<String, Object>{
                'success' => false,
                'error' => e.getMessage(),
                'message' => 'Failed to generate steps'
            };
            
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            res.statusCode = 500;
        }
    }
    
    /**
     * @description Endpoint to execute form automation workflow
     */
    @HttpPost
    global static void executeWorkflow() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            // Parse workflow data
            String workflowName = (String) requestData.get('workflowName');
            String targetUrl = (String) requestData.get('targetUrl');
            List<Object> stepsData = (List<Object>) requestData.get('steps');
            
            // Create workflow
            AIFormAutomation.FormWorkflow workflow = new AIFormAutomation.FormWorkflow(workflowName, targetUrl);
            
            // Convert steps
            for(Object stepObj : stepsData) {
                Map<String, Object> stepMap = (Map<String, Object>) stepObj;
                AIFormAutomation.FormStep step = new AIFormAutomation.FormStep(
                    (String) stepMap.get('stepType'),
                    (String) stepMap.get('selector'),
                    (String) stepMap.get('value')
                );
                
                if(stepMap.containsKey('waitTime')) {
                    step.waitTime = (Integer) stepMap.get('waitTime');
                }
                if(stepMap.containsKey('metadata')) {
                    step.metadata = (Map<String, Object>) stepMap.get('metadata');
                }
                
                workflow.steps.add(step);
            }
            
            // Execute workflow
            AIFormAutomation.AIStepGenerator generator = new AIFormAutomation.OpenAIStepGenerator();
            AIFormAutomation.FormExecutor executor = new AIFormAutomation.FormExecutor(generator);
            executor.executeWorkflow(workflow);
            
            // Return execution result
            Map<String, Object> response = new Map<String, Object>{
                'success' => true,
                'workflowId' => workflow.workflowName,
                'status' => workflow.status,
                'startTime' => workflow.startTime,
                'endTime' => workflow.endTime,
                'message' => 'Workflow executed successfully'
            };
            
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
            
        } catch(Exception e) {
            Map<String, Object> errorResponse = new Map<String, Object>{
                'success' => false,
                'error' => e.getMessage(),
                'message' => 'Failed to execute workflow'
            };
            
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            res.statusCode = 500;
        }
    }
    
    /**
     * @description Endpoint to get available workflow templates
     */
    @HttpGet
    global static void getTemplates() {
        RestResponse res = RestContext.response;
        
        try {
            // Get all templates
            Map<String, AIFormAutomation.FormWorkflow> templates = new Map<String, AIFormAutomation.FormWorkflow>{
                'contact_form' => AIFormAutomation.WorkflowTemplateManager.getTemplate('contact_form'),
                'registration_form' => AIFormAutomation.WorkflowTemplateManager.getTemplate('registration_form'),
                'survey_form' => AIFormAutomation.WorkflowTemplateManager.getTemplate('survey_form')
            };
            
            // Convert to JSON
            Map<String, Object> templatesJson = new Map<String, Object>();
            for(String key : templates.keySet()) {
                AIFormAutomation.FormWorkflow workflow = templates.get(key);
                if(workflow != null) {
                    List<Map<String, Object>> stepsJson = new List<Map<String, Object>>();
                    for(AIFormAutomation.FormStep step : workflow.steps) {
                        Map<String, Object> stepJson = new Map<String, Object>{
                            'stepType' => step.stepType,
                            'selector' => step.selector,
                            'value' => step.value,
                            'waitTime' => step.waitTime,
                            'metadata' => step.metadata
                        };
                        stepsJson.add(stepJson);
                    }
                    
                    templatesJson.put(key, new Map<String, Object>{
                        'workflowName' => workflow.workflowName,
                        'targetUrl' => workflow.targetUrl,
                        'steps' => stepsJson,
                        'status' => workflow.status
                    });
                }
            }
            
            Map<String, Object> response = new Map<String, Object>{
                'success' => true,
                'templates' => templatesJson,
                'message' => 'Templates retrieved successfully'
            };
            
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
            
        } catch(Exception e) {
            Map<String, Object> errorResponse = new Map<String, Object>{
                'success' => false,
                'error' => e.getMessage(),
                'message' => 'Failed to retrieve templates'
            };
            
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            res.statusCode = 500;
        }
    }
    
    /**
     * @description Endpoint to process form data in different formats
     */
    @HttpPost
    global static void processData() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            String dataFormat = (String) requestData.get('format'); // 'json', 'csv', 'xml'
            String rawData = (String) requestData.get('data');
            
            AIFormAutomation.FormDataProcessor processor = new AIFormAutomation.FormDataProcessor();
            Map<String, String> processedData;
            
            switch on dataFormat.toLowerCase() {
                when 'json' {
                    processedData = processor.processJsonData(rawData);
                }
                when 'csv' {
                    processedData = processor.processCsvData(rawData);
                }
                when else {
                    throw new AIFormAutomation.FormAutomationException('Unsupported data format: ' + dataFormat);
                }
            }
            
            Map<String, Object> response = new Map<String, Object>{
                'success' => true,
                'processedData' => processedData,
                'message' => 'Data processed successfully'
            };
            
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
            
        } catch(Exception e) {
            Map<String, Object> errorResponse = new Map<String, Object>{
                'success' => false,
                'error' => e.getMessage(),
                'message' => 'Failed to process data'
            };
            
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            res.statusCode = 500;
        }
    }
    
    /**
     * @description Endpoint to analyze form structure
     */
    @HttpPost
    global static void analyzeForm() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            String formHtml = (String) requestData.get('html');
            
            // Analyze form structure using AI
            AIFormAutomation.AIStepGenerator generator = new AIFormAutomation.OpenAIStepGenerator();
            String analysis = generator.analyzeFormStructure(formHtml);
            
            Map<String, Object> response = new Map<String, Object>{
                'success' => true,
                'analysis' => analysis,
                'message' => 'Form analyzed successfully'
            };
            
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
            
        } catch(Exception e) {
            Map<String, Object> errorResponse = new Map<String, Object>{
                'success' => false,
                'error' => e.getMessage(),
                'message' => 'Failed to analyze form'
            };
            
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            res.statusCode = 500;
        }
    }
}
