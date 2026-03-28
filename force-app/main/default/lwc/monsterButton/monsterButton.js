import { LightningElement } from 'lwc';
import generateMassiveLogs from '@salesforce/apex/MonsterPayloadRecipe.generateMassiveLogs';

export default class MonsterButton extends LightningElement {
    handleClick() {
        generateMassiveLogs()
            .then(() => console.log('Monster logs generated'));
    }
}
