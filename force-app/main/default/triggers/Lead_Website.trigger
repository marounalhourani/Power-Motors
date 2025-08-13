/**
 * Trigger on Lead Object
 * if website field is not empty, a callout function will autocomplete other fields based on the website field
 * @Author: Maroun Al Hourani
 * @Company: EI-Technologies
   @<11/8/2025>
 */
trigger Lead_Website on Lead (after insert, after update) {
new Lead_Website_Trigger_Handler().run();
}