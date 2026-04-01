import { LightningElement } from 'lwc';

export default class ApexRecipesContainer extends LightningElement {
    selectedRecipe;
    quoteGenerated = false;
    quoteText = '';
    quoteAuthor = '';

    handleRecipeSelect(event) {
        this.selectedRecipe = event.detail;
    }

    handleGenerateQuote() {
        const quotes = [
            { text: "The only way to do great work is to love what you do.", author: "Steve Jobs" },
            { text: "Innovation distinguishes between a leader and a follower.", author: "Steve Jobs" },
            { text: "Code is like humor. When you have to explain it, it's bad.", author: "Cory House" },
            { text: "First, solve the problem. Then, write the code.", author: "John Johnson" },
            { text: "Experience is the name everyone gives to their mistakes.", author: "Oscar Wilde" },
            { text: "The best way to predict the future is to invent it.", author: "Alan Kay" }
        ];
        
        const randomQuote = quotes[Math.floor(Math.random() * quotes.length)];
        this.quoteText = randomQuote.text;
        this.quoteAuthor = randomQuote.author;
        this.quoteGenerated = true;
    }
}
