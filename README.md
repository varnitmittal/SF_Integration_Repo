# Salesforce Project - [Project Name]

## Overview

    This repository contains a Salesforce integration project featuring Apex classes, Lightning Web Components (LWC), Aura components, and Triggers to extend Salesforce functionality.

        - Salesforce API Callout to External Systems



    Certain sub-concepts are also included for quick lookup.
        - Platform Event
        - Platform Cache





## Project Structure


### Apex Classes

**vm_CaseTriggerHandler.cls**  --  handle Case update/create trigger events [**Salesforce Integration Code**]

**VM_ZendeskUtil.cls**  --  holds wrapper classes for Zendesk Create Many tickets API callout json body and response [**Salesforce Integration Code**]

**VM_ZendeskCreateTickets.cls**  --  code for Zendesk Create Ticket callout and Get Status Callout. The class implements Queueable and Database.AllowsCallouts interfaces. [**Salesforce Integration Code**]

**BusScheduleCache.cls**  --  code for creating a new key-value entry in a Platform Cache Org Partition. Then referring back to it. Also includes a timple if-else to handle cache misses. [**Platform Cache Code**]


### Apex Trigger

**CASE** -- **vm_CaseTrigger**
Shows the realtime integration with Zendesk. Creates a ticket with Zendesk as soon as a Case with a particular Record Type is created in Salesforce. [**Salesforce Integration Code**]

**Order Event (Platform Event)**  --  **OrderEventTrigger.trigger**
Shows Platform Event subscription, and creates a task out of it. [**Platform Event Code**]
