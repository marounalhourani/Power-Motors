trigger Quote_Email_PDF_SEND on Quote (after update) {
    new Quote_Email_Trigger_Handler().run();
}