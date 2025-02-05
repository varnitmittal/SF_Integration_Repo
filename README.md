# Salesforce Project - [Project Name]

## Overview

    This repository contains a Salesforce integration project featuring Apex classes, Lightning Web Components (LWC), Aura components, and Triggers to extend Salesforce functionality.

## Project Structure

### Apex Classes

**vm_CaseTriggerHandler.cls**  --  handle Case update/create trigger events

**VM_ZendeskUtil.cls**  --  holds wrapper classes for Zendesk Create Many tickets API callout json body and response

**VM_ZendeskCreateTickets.cls**  --  code for Zendesk Create Ticket callout and Get Status Callout. The class implements Queueable and Database.AllowsCallouts interfaces.

### Apex Classes

**CASE**
-- **vm_CaseTrigger**
